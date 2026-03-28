import SwiftUI

struct RankingView: View {
    // 1. Connect to our new Smart Middleman!
    @StateObject private var viewModel = RankingViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // 2. Check what the ViewModel is doing and update the screen
                if viewModel.isLoading {
                    ProgressView("Loading Leaderboard...")
                        .scaleEffect(1.2) // Makes the spinner slightly bigger
                }
                else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                else {
                    // 3. Display the data from the ViewModel
                    List(viewModel.leaderboard) { player in
                        HStack {
                            if player.rank == 1 {
                                Image(systemName: "medal.fill").foregroundColor(.yellow).font(.title2).frame(width: 30)
                            } else if player.rank == 2 {
                                Image(systemName: "medal.fill").foregroundColor(.gray).font(.title2).frame(width: 30)
                            } else if player.rank == 3 {
                                Image(systemName: "medal.fill").foregroundColor(.brown).font(.title2).frame(width: 30)
                            } else {
                                Text("\(player.rank)").font(.headline).foregroundColor(.secondary).frame(width: 30)
                            }
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                            
                            Text(player.name).font(.body).fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(player.score) pts").font(.subheadline).fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Leaderboard")
            // 4. Trigger the ViewModel to start downloading when the screen opens
            .task {
                // We only fetch if the list is empty, so it doesn't reload every time you switch tabs
                if viewModel.leaderboard.isEmpty {
                    await viewModel.fetchLeaderboardData()
                }
            }
        }
    }
}

#Preview {
    RankingView()
}
