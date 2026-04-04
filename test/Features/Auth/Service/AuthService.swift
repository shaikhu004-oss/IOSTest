// test/Features/Auth/Service/AuthService.swift

import Foundation
internal import _LocationEssentials
internal import CoreLocation

class AuthService {
    
    // 🌟 Returns the success flag, the onboarding flag, and the token
    func verifyWithBackend(idToken: String) async throws -> (success: Bool, onboarding: Bool, token: String?) {
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
            "idToken": idToken,
            "authProvider": "google",
            "country_short_name": Locale.current.region?.identifier ?? "US",
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
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [AuthService] Error: Invalid response type")
                return (false, false, nil)
            }
            
            // 🌟 PRINT ERROR RESPONSE (If backend returns 400, 500, etc.)
            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ [AuthService] HTTP Error Status Code: \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ [AuthService] Error Response Body:\n\(errorString)")
                }
                return (false, false, nil)
            }
            
            // 🌟 PRINT SUCCESS RESPONSE (If backend returns 200 OK)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [AuthService] RAW API SUCCESS RESPONSE:")
                print(jsonString)
                print("--------------------------------------------------")
            }
            
            do {
                // Decode using the newly updated AuthResponse model
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("✅ [AuthService] Decoded Successfully! Logged in as: \(authResponse.user?.name ?? "Unknown")")
                
                // Extract the exact properties matching the new JSON
                let isOnboarding = authResponse.needsOnboarding ?? false
                let token = authResponse.accessToken
                
                return (authResponse.success, isOnboarding, token)
                
            } catch {
                // Prints the exact reason why decoding failed (e.g., missing key, wrong type)
                print("❌ [AuthService] JSON Decoding Error: \(error)")
                return (false, false, nil)
            }
            
        } catch {
            print("❌ [AuthService] Network Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // 🌟 NEW: Checks if a generated username already exists on the backend
    func checkIfUsernameExists(username: String) async throws -> Bool {
        let urlString = "https://staging.pathpulse.ai/api/auth/whatsapp/check-username"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "username": username
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("❌ [AuthService] Username check failed with status code.")
            return true // Safest fallback: Assume it exists so we don't accidentally assign a taken name
        }
        
        // 🌟 Look for the "exists" key in the backend JSON response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let exists = json["exists"] as? Bool {
            return exists
        }
        
        return false
    }
}
