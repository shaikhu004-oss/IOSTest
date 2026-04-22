import Foundation

class LeaderboardService {
    let baseURL = "https://staging.pathpulse.ai/api"
    
    // A helper to easily pack up our request with the security token
    private func createRequest(for endpoint: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Replace this with the actual token you get when the user logs in
        let token = "YOUR_BEARER_TOKEN_HERE" 
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    // Fetch Beats (Page size is now automatically 10)
    func getBeats(page: Int, pageSize: Int = 10) async throws -> LeaderboardResponse {
        let endpoint = "/core/leaderboard/beats?page=\(page)&page_size=\(pageSize)"
        let request = try createRequest(for: endpoint)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(LeaderboardResponse.self, from: data)
    }
    
    // Fetch Referrals (Page size is now automatically 10)
    func getReferrals(page: Int, pageSize: Int = 10) async throws -> LeaderboardResponse {
        let endpoint = "/core/leaderboard/referrals?page=\(page)&page_size=\(pageSize)"
        let request = try createRequest(for: endpoint)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(LeaderboardResponse.self, from: data)
    }
    
    // Fetch Rewards
    func getGlobalRewards() async throws -> GlobalRewardsResponse {
        let endpoint = "/core/leaderboard/global-rewards"
        let request = try createRequest(for: endpoint)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GlobalRewardsResponse.self, from: data)
    }
}