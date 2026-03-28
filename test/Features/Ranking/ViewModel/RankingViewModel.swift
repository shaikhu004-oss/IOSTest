import SwiftUI // <--- Must be SwiftUI
internal import Combine

// @MainActor ensures UI updates happen safely
@MainActor
class RankingViewModel: ObservableObject { // <--- MUST be 'class', not 'struct'!
    
    @Published var leaderboard: [Player] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchLeaderboardData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Wait 1.5 seconds to simulate downloading
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            // Provide the mock data
            self.leaderboard = [
                Player(id: 1, rank: 1, name: "Alex Johnson", score: 14500),
                Player(id: 2, rank: 2, name: "Umar Momin", score: 13200),
                Player(id: 3, rank: 3, name: "Sarah Smith", score: 12800),
                Player(id: 4, rank: 4, name: "Mike Davis", score: 10400),
                Player(id: 5, rank: 5, name: "Emma Wilson", score: 9900)
            ]
            
        } catch {
            errorMessage = "Something went wrong!"
        }
        
        isLoading = false
    }
}
