import Foundation
internal import _LocationEssentials
internal import CoreLocation

class AuthService {
    
    func verifyWithBackend(idToken: String) async throws -> Bool {
        let urlString = "https://staging.pathpulse.ai/api/auth/v2/auth/login"
        guard let url = URL(string: urlString) else {
            print("❌ [AuthService] Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "X-Version-Code")
        request.setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        request.setValue("ios", forHTTPHeaderField: "X-Device-Platform")
        
        // 1. Get raw device data
        let rawDeviceInfo = DeviceInfoCollector.shared.getDeviceInfo()
        
        // 2. Fetch location safely
        var locationDict: [String: Double]? = nil
        let locStatus = await LocationManager.shared.requestLocationPermissionIfNeeded()
        if locStatus == .authorizedAlways || locStatus == .authorizedWhenInUse {
            if let loc = await LocationManager.shared.requestSingleLocation() ?? LocationManager.shared.currentLocation {
                locationDict = [
                    "latitude": loc.coordinate.latitude,
                    "longitude": loc.coordinate.longitude
                ]
            }
        }
        
        // 3. Construct the EXACT requested payload
        var payload: [String: Any] = [
            "idToken": idToken, // MUST be the Firebase ID Token
            "authProvider": "google",
            "country_short_name": Locale.current.region?.identifier ?? "US", // Dynamically get country, fallback to US
            "device_platform": "ios",
            "device_fingerprint": rawDeviceInfo.fingerprint ?? "unknown",
            "device_info": [
                "model": rawDeviceInfo.deviceModel,
                "os_version": rawDeviceInfo.osVersion,
                "app_version": rawDeviceInfo.appVersion,
                "build_number": String(rawDeviceInfo.versionCode ?? 1),
                "manufacturer": rawDeviceInfo.manufacturer ?? "Apple"
            ]
        ]
        
        // Append location only if available
        if let locationDict = locationDict {
            payload["location"] = locationDict
        }

        // --- PRINT THE PAYLOAD TO VERIFY ---
        if let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let payloadString = String(data: payloadData, encoding: .utf8) {
            print("🚀 [AuthService] Outgoing Payload:\n\(payloadString)")
        }
        // ------------------------------------

        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [AuthService] Error: Invalid response type")
                return false
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ [AuthService] HTTP Error: Status Code \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ [AuthService] Backend Error Payload: \(errorString)")
                }
                return false
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("✅ [AuthService] API Success! Logged in as: \(authResponse.data?.user?.name ?? "Unknown")")
                return authResponse.success
                
            } catch {
                print("❌ [AuthService] JSON Decoding Error: \(error.localizedDescription)")
                print("❌ [AuthService] Raw Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                return false
            }
            
        } catch {
            print("❌ [AuthService] Network Error: \(error.localizedDescription)")
            throw error
        }
    }
}
