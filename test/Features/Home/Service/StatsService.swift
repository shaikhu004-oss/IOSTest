// test/Features/Home/Service/StatsService.swift
import Foundation

class StatsService {
    static let shared = StatsService()
    private let baseURL = "https://staging.pathpulse.ai/api"
    
    func fetchUserStats(range: String, startDate: String? = nil, endDate: String? = nil) async throws -> UserStatsResponse {
        guard var components = URLComponents(string: "\(baseURL)/core/user/stats") else {
            throw URLError(.badURL)
        }
        
        // Setup Query Parameters
        var queryItems = [URLQueryItem(name: "range", value: range.lowercased())]
        if range.lowercased() == "custom" {
            if let start = startDate { queryItems.append(URLQueryItem(name: "start_date", value: start)) }
            if let end = endDate { queryItems.append(URLQueryItem(name: "end_date", value: end)) }
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // Setup Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Fetch Token (Uses UserDefaults or your SecureStorage)
        if let token = SecureStorage.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Execute Request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 🛠️ DEBUG: Print the exact JSON the server is sending back
        if let rawJSON = String(data: data, encoding: .utf8) {
            print("📦 RAW API RESPONSE: \(rawJSON)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("❌ [StatsService] API Error: Status Code \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        // Decode JSON Payload
        // Decode JSON Payload
                do {
                    let decoder = JSONDecoder()
                    let wrapper = try decoder.decode(StatsAPIWrapper.self, from: data)
                    
                    // Return the data object, or an empty one if it fails
                    return wrapper.data ?? UserStatsResponse(totalBeats: 0, pulsPoints: 0, totalTimeTravelled: 0, totalDistanceKm: 0)
                } catch {
            print("❌ [StatsService] Failed to decode JSON: \(error)")
            throw error
        }
    }
}
