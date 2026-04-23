import Foundation

// MARK: - Leaderboard Models
struct LeaderboardResponse: Codable {
    let leaderboard: [LeaderboardPlayer]
    let user: LeaderboardPlayer
    let nextResetTime: String?
    let totalPages: Int
    let region: String?
    let isRegional: Bool?
    let availableLeaderboards: [String]?
    
    enum CodingKeys: String, CodingKey {
        case leaderboard, user, region
        case nextResetTime = "next_reset_time"
        case totalPages = "total_pages"
        case isRegional = "is_regional"
        case availableLeaderboards = "available_leaderboards"
    }
}

struct LeaderboardPlayer: Codable, Identifiable {
    var id: String { userId ?? UUID().uuidString }
    
    let rank: Int
    let name: String
    let userId: String?
    let beats: Double?
    let referralPoints: Double?
    
    var displayPoints: Double {
        return beats ?? referralPoints ?? 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case rank, name, beats
        case userId = "user_id"
        case referralPoints = "referral_points"
    }
}

