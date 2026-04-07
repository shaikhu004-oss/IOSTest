// test/Features/Ranking/View/RankingView.swift
import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    
    // State for the custom tab switcher (0 = Beats, 1 = Referrals)
    @State private var selectedTab = 0
    
    // Theme colors to match the screenshot
    let themeBlack = Color(red: 0.08, green: 0.1, blue: 0.08)
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    let themeCyan = Color(red: 0.2, green: 0.8, blue: 0.8) // Used for countdown and bottom text
    let lightGreen = Color(red: 0.5, green: 0.9, blue: 0.5) // Lighter green for the middle total
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- 1. COUNTDOWN CARD ---
                    VStack(spacing: 12) {
                        Text("Leaderboard Starts on")
                            .font(.subheadline)
                            .foregroundColor(themeCyan)
                        
                        Text("0 Days . 00:00:00")
                            .font(.title2)
                            .fontWeight(.light)
                            .foregroundColor(themeCyan)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 25)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(themeCyan.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // --- 2. REWARDS CARD ---
                    VStack(alignment: .leading, spacing: 15) {
                        // Header
                        HStack {
                            Text("Rewards")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Image(systemName: "info.circle")
                                .foregroundColor(themeGreen)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        
                        // Subtitle with inline icon
                        HStack(alignment: .top, spacing: 0) {
                            Text("Earn rewards every 22 days by collecting the most data points (")
                                .foregroundColor(themeGreen) +
                            Text(Image(systemName: "square.fill"))
                                .foregroundColor(.blue) +
                            Text(" Beats).")
                                .foregroundColor(themeGreen)
                        }
                        .font(.subheadline)
                        .padding(.bottom, 5)
                        
                        // Divider Line
                        Divider()
                            .background(Color.gray.opacity(0.5))
                        
                        // Totals Row
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("$1850")
                                .font(.headline)
                                .foregroundColor(lightGreen)
                            
                            Spacer()
                            
                            Text("$1,850")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(themeGreen)
                        }
                        .padding(.top, 5)
                    }
                    .padding(20)
                    .background(themeBlack)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // --- 3. CUSTOM TAB SWITCHER ---
                    HStack(spacing: 0) {
                        // Beats Tab
                        VStack(spacing: 8) {
                            Text("Beats")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == 0 ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == 0 ? themeGreen : Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) { selectedTab = 0 }
                        }
                        
                        // Referrals Tab
                        VStack(spacing: 8) {
                            Text("Referrals")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == 1 ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == 1 ? themeGreen : Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) { selectedTab = 1 }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // --- 4. COOLDOWN MESSAGE ---
                    Text("Your rewards will be processed before the\ncooldown period ends.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeCyan)
                        .multilineTextAlignment(.center)
                        .padding(.top, 15)
                        .padding(.horizontal, 20)
                    
                    // --- 5. THE LEADERBOARD LIST (From previous step) ---
                    // I left this here so you don't lose the UI when the leaderboard goes live!
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 20)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.leaderboard) { player in
                                PlayerRowView(player: player, themeBlack: themeBlack, themeGreen: themeGreen)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .applyAppBackground()
            .task {
                if viewModel.leaderboard.isEmpty {
                    await viewModel.fetchLeaderboardData()
                }
            }
        }
    }
}

// --- REUSABLE COMPONENT FOR THE ROW ---
struct PlayerRowView: View {
    var player: Player
    var themeBlack: Color
    var themeGreen: Color
    
    var body: some View {
        HStack {
            // Rank / Medal
            if player.rank == 1 {
                Image(systemName: "medal.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .frame(width: 30)
            } else if player.rank == 2 {
                Image(systemName: "medal.fill")
                    .foregroundColor(Color(white: 0.8)) // Silver
                    .font(.title2)
                    .frame(width: 30)
            } else if player.rank == 3 {
                Image(systemName: "medal.fill")
                    .foregroundColor(.brown) // Bronze
                    .font(.title2)
                    .frame(width: 30)
            } else {
                Text("\(player.rank)")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(width: 30)
            }
            
            // Avatar
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(themeGreen)
                .padding(.horizontal, 8)
            
            // Name
            Text(player.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            // Score
            Text("\(player.score) pts")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeGreen)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(themeBlack)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    RankingView()
        .preferredColorScheme(.dark)
}
