import Foundation

struct AuthResponse: Codable {
    let success: Bool
    let data: AuthData?
}

struct AuthData: Codable {
    let access_token: String?
    let signup_token: String?
    let user: AuthUserProfile?
}

struct AuthUserProfile: Codable {
    let id: Int
    let email: String
    let username: String?
    let name: String
    let isVerified: Bool
}
