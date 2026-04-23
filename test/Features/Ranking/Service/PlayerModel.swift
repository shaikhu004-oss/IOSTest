import Foundation

// MARK: - Rewards Models

// 🛠️ The outer wrapper
struct GlobalRewardsResponse: Codable {
    let data: RewardData
    let message: String
    let success: Bool
}

struct RewardData: Codable {
    let beatsRewards: [RewardTier]?
    let referralRewards: [RewardTier]?
    let nextResetTime: String?
    let leaderboardStartTime: String?
    let resetCycleDays: Int?
    let region: String?
    
    enum CodingKeys: String, CodingKey {
        case beatsRewards = "beats_rewards"
        case referralRewards = "referral_rewards"
        case nextResetTime = "next_reset_time"
        case leaderboardStartTime = "leaderboard_start_time"
        case resetCycleDays = "reset_cycle_days"
        case region
    }
}

struct RewardTier: Codable, Identifiable {
    var id: Int { rank }
    let rank: Int
    let value: Int
}
