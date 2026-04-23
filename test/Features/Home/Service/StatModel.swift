// test/Features/Home/Service/StatModel.swift
import Foundation

// 🛠️ ADDED: The wrapper that the compiler was looking for
struct StatsAPIWrapper: Codable {
    let data: UserStatsResponse?
}

// Make properties optional so the app doesn't crash if the server omits them
struct UserStatsResponse: Codable {
    let totalBeats: Double?
    let pulsPoints: Double?
    let totalTimeTravelled: Int?
    let totalDistanceKm: Double?
}

struct StatModel {
    var beats: String
    var puls: String
    var time: String
    var distance: String
    
    static let empty = StatModel(beats: "0.0", puls: "0.00", time: "00:00", distance: "0.0")
}
