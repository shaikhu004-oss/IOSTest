import Foundation
internal import CoreLocation

class AuthService {
    
    // MARK: - Login Verification
    func verifyWithBackend(idToken: String) async throws -> (success: Bool, onboarding: Bool, token: String?) {
        let urlString = "https://staging.pathpulse.ai/api/auth/v2/auth/login"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Standard headers required by backend
        request.setValue("1", forHTTPHeaderField: "X-Version-Code")
        request.setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        request.setValue("ios", forHTTPHeaderField: "X-Device-Platform")
        
        let rawDeviceInfo = DeviceInfoCollector.shared.getDeviceInfo()
        
        // Fetch Location Safely
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
        
        // Construct full payload
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
        
        if let locationDict = locationDict {
            payload["location"] = locationDict
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        // Debug: Print Payload
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            print("📤 [AuthService] Sending Login Payload:\n\(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            return (false, false, nil)
        }
        
        // Debug: Catch Server Errors
        if !(200...299).contains(httpResponse.statusCode) {
            print("❌ [AuthService] LOGIN API FAILED with status: \(httpResponse.statusCode)")
            if let serverError = String(data: data, encoding: .utf8) {
                print("❌ [AuthService] SERVER SAYS:\n\(serverError)")
            }
            return (false, false, nil)
        }
        
        do {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return (authResponse.success, authResponse.needsOnboarding ?? false, authResponse.accessToken)
        } catch {
            print("❌ [AuthService] JSON Decoding failed during login. Error: \(error)")
            return (false, false, nil)
        }
    }
    
    // MARK: - Username Checks
    func checkIfUsernameExists(username: String) async throws -> Bool {
        let urlString = "https://staging.pathpulse.ai/api/auth/whatsapp/check-username"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["username": username]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return true // Fallback to "exists" to prevent duplicate assignments on error
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let exists = json["exists"] as? Bool {
            return exists
        }
        return false
    }

    // MARK: - Complete Onboarding
    func completeOnboarding(username: String, referralCode: String?) async throws -> Bool {
        let urlString = "https://staging.pathpulse.ai/api/auth/v2/auth/user/onboarding"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        // 1. Retrieve the token saved during login
        guard let token = SecureStorage.shared.getToken() else {
            print("❌ [AuthService] No token found to use for onboarding.")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 🌟 Fix for the 401 Error: Send token in the header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Standard headers
        request.setValue("1", forHTTPHeaderField: "X-Version-Code")
        request.setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        request.setValue("ios", forHTTPHeaderField: "X-Device-Platform")
        
        // 2. Get full device info and location using your collector
        var payload = await DeviceInfoCollector.shared.getFullPayload()
        
        // 3. Add the root properties requested by the backend
        payload["signup_token"] = token // Send token in the body as well
        payload["username"] = username
        payload["device_platform"] = "ios"
        payload["country_short_name"] = Locale.current.region?.identifier ?? "US"
        
        // Extract the device_fingerprint from the collector
        if let deviceInfo = payload["device_info"] as? [String: Any],
           let fingerprint = deviceInfo["device_fingerprint"] as? String {
            payload["device_fingerprint"] = fingerprint
        } else {
            payload["device_fingerprint"] = "unknown"
        }
        
        // Attach referral code if the user didn't skip
        if let code = referralCode, !code.isEmpty {
            payload["referralCode"] = code
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        // Debug: Print what we are sending for Onboarding
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            print("📤 [AuthService] Sending Onboarding Payload:\n\(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        
        if (200...299).contains(httpResponse.statusCode) {
            print("✅ [AuthService] Onboarding Success! Server Replied:")
            if let responseStr = String(data: data, encoding: .utf8) {
                print(responseStr)
            }
            return true
        } else {
            print("❌ [AuthService] ONBOARDING FAILED with status: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) {
                print("❌ [AuthService] SERVER SAYS:\n\(errorBody)")
            }
            return false
        }
    }
}
