//
//  ProfileService.swift
//  test
//
//  Created by Umar Momin on 06/04/26.
//


// test/Features/Profile/Service/ProfileService.swift
import Foundation

class ProfileService {
    func fetchProfile() async throws -> UserProfile {
        let urlString = "https://staging.pathpulse.ai/api/core/user/profile"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        guard let token = SecureStorage.shared.getToken() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No auth token found."])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "X-Version-Code")
        request.setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        request.setValue("ios", forHTTPHeaderField: "X-Device-Platform")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            let wrapper = try JSONDecoder().decode(ProfileResponse.self, from: data)
            if let profile = wrapper.data ?? wrapper.user {
                return profile
            } else {
                throw error
            }
        }
    }
}