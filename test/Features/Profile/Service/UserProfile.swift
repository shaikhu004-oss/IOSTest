//
//  UserProfile.swift
//  test
//
//  Created by Umar Momin on 06/04/26.
//


// test/Features/Profile/Service/ProfileModel.swift
import Foundation

struct UserProfile: Codable, Equatable {
    var id: String?
    var name: String?
    var username: String
    var whatsapp: String?
    var email: String
    var role: String
    var referralCode: String
    var localCurrency: String?
    var defaultCurrency: String?
    var country: String?
    var countryCode: String?
    var region: String?
    var walletAddress: String?
    var createdAt: String
    var updatedAt: String
    var photoUrl: String?
    var isBanned: Bool
    var banReason: String?
    
    var beats: Double?
    var pulsePoints: Double?
    var level: String?
    var tier: String?
    var countryDetectionMethod: String?
    var countryConfidence: String?
    var lastKnownIp: String?
    var currencyDetectionMethod: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username, whatsapp, email, role, country, region, beats, level, tier
        case referralCode = "referral_code"
        case localCurrency = "local_currency"
        case defaultCurrency = "default_currency"
        case countryCode = "country_code"
        case walletAddress = "wallet_address"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case photoUrl = "photo_url"
        case isBanned = "is_banned"
        case banReason = "ban_reason"
        case pulsePoints = "pulse_points"
        case countryDetectionMethod = "country_detection_method"
        case countryConfidence = "country_confidence"
        case lastKnownIp = "last_known_ip"
        case currencyDetectionMethod = "currency_detection_method"
    }
}

struct ProfileResponse: Codable {
    let success: Bool?
    let data: UserProfile?
    let user: UserProfile?
}