import Foundation

// Maps exactly to your top-level JSON
struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let needsOnboarding: Bool?
    let username: String?
    let referralCode: String?
    let user: AuthUserProfile?
    let accessToken: String?
}

// Maps exactly to the "user" object in your JSON
struct AuthUserProfile: Codable {
    let id: String // 🌟 Changed to String to handle UUIDs like "e71f9542..."
    let firebaseUid: String?
    let email: String
    let phone: String?
    let name: String
    let profilePicture: String?
    let walletAddress: String?
    let circleWalletAddress: String?
    let circleWalletId: String?
    let isVerified: Bool
}
