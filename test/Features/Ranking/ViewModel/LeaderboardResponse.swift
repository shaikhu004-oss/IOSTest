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
    // If the API doesn't send a user_id, we make a temporary one so SwiftUI loops don't break
    var id: String { userId ?? UUID().uuidString } 
    
    let rank: Int
    let name: String
    let userId: String?
    let beats: Double?
    let referralPoints: Double?
    
    // 🧠 SMART HELPER: Gives the UI the right points no matter which tab is open!
    var displayPoints: Double {
        return beats ?? referralPoints ?? 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case rank, name, beats
        case userId = "user_id"
        case referralPoints = "referral_points"
    }
}

// MARK: - Rewards Models
struct GlobalRewardsResponse: Codable {
    let success: Bool
    let message: String
    let data: RewardData
}

struct RewardData: Codable {
    let beatsRewards: [RewardTier]
    let referralRewards: [RewardTier]
    let nextResetTime: String
    let leaderboardStartTime: String
    
    enum CodingKeys: String, CodingKey {
        case beatsRewards = "beats_rewards"
        case referralRewards = "referral_rewards"
        case nextResetTime = "next_reset_time"
        case leaderboardStartTime = "leaderboard_start_time"
    }
}

struct RewardTier: Codable, Identifiable {
    var id: Int { rank } 
    let rank: Int
    let value: Int
}