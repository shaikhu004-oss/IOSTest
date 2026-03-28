import Foundation

// Your Model
struct Player: Identifiable, Codable {
    let id: Int
    let rank: Int
    let name: String
    let score: Int
}
