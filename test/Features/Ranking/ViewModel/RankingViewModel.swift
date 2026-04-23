import Foundation
 internal import Combine

@MainActor // Keeps all UI changes safely on the main thread
class RankingViewModel: ObservableObject {
    
    // The data we will show on the screen
    @Published var users: [LeaderboardPlayer] = []
    @Published var currentUser: LeaderboardPlayer? = nil
    @Published var rewardsData: RewardData? = nil
    
    // Loading state for a loading spinner
    @Published var isLoading: Bool = false
    
    // Pagination trackers
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var countdownText: String = "00:00:00:00"
    private var timer: AnyCancellable?
    
    let pageSize: Int = 10
    
    // When the tab changes, reset to page 1 and fetch fresh data!
    @Published var selectedTab: String = "Beats" {
        didSet {
            currentPage = 1
            Task { await loadLeaderboard() }
        }
    }
    
    private let apiService = LeaderboardService()
    
    init() {
        // Fetch everything the second the view model is created
        Task {
            await fetchRewards()
            await loadLeaderboard()
        }
    }
    
    func startCountdown() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }

    private func updateCountdown() {
        // Uses the nextResetTime from your RewardData model
        guard let dateString = rewardsData?.nextResetTime else { return }
        
        let formatter = ISO8601DateFormatter()
        guard let targetDate = formatter.date(from: dateString) else { return }
        
        let diff = targetDate.timeIntervalSinceNow
        if diff <= 0 {
            countdownText = "00 Days . 00:00:00"
            return
        }
        
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        
        countdownText = String(format: "%d Days . %02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    func loadLeaderboard() async {
        isLoading = true
        
        do {
            let response: LeaderboardResponse
            
            // Look at the tab string to decide which API delivery to ask for
            // 🛠️ UPDATED: We no longer need to pass pageSize here, Swift does it automatically!
            if selectedTab == "Beats" {
                response = try await apiService.getBeats(page: currentPage)
            } else {
                response = try await apiService.getReferrals(page: currentPage)
            }
            
            // Save the data to our screen variables
            self.users = response.leaderboard
            self.currentUser = response.user
            self.totalPages = response.totalPages
            
        } catch {
            print("Failed to load leaderboard: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchRewards() async {
        do {
            let response = try await apiService.getGlobalRewards()
            self.rewardsData = response
            startCountdown() // 👈 Add this line here
        } catch {
            print("Failed to fetch rewards: \(error)")
        }
    }
    // MARK: - Pagination Logic
    
    func loadPage(_ page: Int) {
        guard page != currentPage, page > 0, page <= totalPages else { return }
        currentPage = page
        Task { await loadLeaderboard() }
    }
    
    var visiblePages: [Int] {
        let start = ((currentPage - 1) / 5) * 5 + 1
        let end = min(start + 4, totalPages)
        return Array(start...end)
    }
    
    var hasNextBlock: Bool {
        return visiblePages.last ?? 1 < totalPages
    }
    
    var hasPreviousBlock: Bool {
        return visiblePages.first ?? 1 > 1
    }
    
    func nextBlock() {
        if let lastVisible = visiblePages.last, lastVisible < totalPages {
            loadPage(lastVisible + 1)
        }
    }
    
    func previousBlock() {
        if let firstVisible = visiblePages.first, firstVisible > 1 {
            loadPage(firstVisible - 5)
        }
    }
}
