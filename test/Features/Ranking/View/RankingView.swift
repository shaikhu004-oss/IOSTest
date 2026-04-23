import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    @State private var showBeatsRankingInfo = false
    @State private var showRewardPopup = false
    
    // Theme Colors
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5) // Neon Green
    
    var body: some View {
        ZStack {
            themeBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- TOP HEADER ---
                Text("Leaderboard")
                    .font(.custom("ClashDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                
                VStack(spacing: 15) {
                    // --- 1. COUNTDOWN CARD ---
                    CountdownCard(themeGreen: themeGreen, timeRemaining: viewModel.countdownText)
                    
                    // --- 2. REWARDS CARD ---
                    RewardsCardView(viewModel: viewModel, themeGreen: themeGreen, isPopupShowing: $showRewardPopup)
                    
                    // --- 3. CUSTOM TABS ---
                    HStack(spacing: 0) {
                        TabButton(title: "Beats", isSelected: viewModel.selectedTab == "Beats", themeGreen: themeGreen) {
                            viewModel.selectedTab = "Beats"
                        }
                        TabButton(title: "Referrals", isSelected: viewModel.selectedTab == "Referrals", themeGreen: themeGreen) {
                            viewModel.selectedTab = "Referrals"
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // --- SCROLLVIEW & LEADERBOARD LIST ---
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            
                            // --- 4. LEADERBOARD LIST ---
                            VStack(spacing: 12) {
                                // 🛠️ FIXED: Now uses the real API users
                                ForEach(viewModel.users) { user in
                                    PlayerRowView(user: user, themeGreen: themeGreen, isSticky: false, isCurrentUser: false)
                                }
                            }
                            
                            // --- 5. SQUARE PAGINATION ---
                            HStack(spacing: 8) {
                                SquarePaginationButton(icon: "chevron.left", isDisabled: !viewModel.hasPreviousBlock) {
                                    withAnimation { viewModel.previousBlock() }
                                }
                                
                                ForEach(viewModel.visiblePages, id: \.self) { page in
                                    SquarePageNumberButton(page: page, isSelected: viewModel.currentPage == page, themeGreen: themeGreen) {
                                        viewModel.loadPage(page)
                                    }
                                }
                                
                                SquarePaginationButton(icon: "chevron.right", isDisabled: !viewModel.hasNextBlock) {
                                    withAnimation { viewModel.nextBlock() }
                                }
                            }
                            .padding(.top, 25)
                            .padding(.bottom, 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 180)
                    }
                    
                    // --- 6. STICKY CURRENT USER CARD ---
                    // 🛠️ FIXED: Safely unwraps the current user from the API
                    if let currentUser = viewModel.currentUser {
                        PlayerRowView(user: currentUser, themeGreen: themeGreen, isSticky: true, isCurrentUser: true)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 90)
                    }
                }
            }
            
        }
        .navigationBarHidden(true)
                // 🛠️ THE FIX: This breaks the popup out to cover the ENTIRE screen (including the Custom Tab Bar!)
        .fullScreenCover(isPresented: $showRewardPopup) {
            ZStack {
                if viewModel.selectedTab == "Beats" {
                    BeatsRewardsView(
                        isPresented: $showRewardPopup,
                        rewards: viewModel.rewardsData?.beatsRewards ?? []
                    )
                } else if viewModel.selectedTab == "Referrals" {
                    ReferralRewardsView(
                        isPresented: $showRewardPopup,
                        rewards: viewModel.rewardsData?.referralRewards ?? []
                    )
                }
            }
            .presentationBackground(.clear)
        }
    }
}

// MARK: - Reusable Helper Components

struct CountdownCard: View {
    var themeGreen: Color
    var timeRemaining: String // 👈 Add this property
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Leaderboard Resets")
                .font(.custom("ClashDisplay-Medium", size: 14))
                .foregroundColor(.gray)
            Text(timeRemaining) // 👈 Use the variable here instead of "4 Days..."
                .font(.custom("ClashDisplay-Bold", size: 28))
                .foregroundColor(themeGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct RewardsCardView: View {
    @ObservedObject var viewModel: RankingViewModel
    var themeGreen: Color
    @Binding var isPopupShowing: Bool
    
    // 🛠️ FIXED: Computes the subtitle locally based on the selected tab
    var subtitle: String {
        viewModel.selectedTab == "Beats"
        ? "Earn rewards every 7 days by collecting the most data points (Beats)."
        : "Earn rewards by referring friends and growing our community."
    }
    
    // 🛠️ FIXED: Calculates the real total dynamically from the API Rewards Data!
    var totalAmount: String {
            if let data = viewModel.rewardsData {
                // 🛠️ The '?? []' safely defaults to an empty list instead of crashing!
                let rewards = viewModel.selectedTab == "Beats" ? (data.beatsRewards ?? []) : (data.referralRewards ?? [])
                let sum = rewards.reduce(0) { $0 + $1.value }
                return "$\(sum)"
            }
            return viewModel.selectedTab == "Beats" ? "$450" : "$100"
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Rewards")
                    .font(.custom("ClashDisplay-Bold", size: 20))
                    .foregroundColor(.white)
                
                Image("info2")
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isPopupShowing = true
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            
            Text(subtitle)
                .font(.custom("ClashDisplay-Regular", size: 14))
                .foregroundColor(themeGreen.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("Total")
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(totalAmount)
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(themeGreen)
                
                Spacer()
                
                Text(totalAmount)
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(themeGreen)
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeGreen.opacity(0.2), lineWidth: 1))
        }
        .padding(20)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeGreen.opacity(0.2), lineWidth: 1))
    }
}

struct PlayerRowView: View {
    // 🛠️ FIXED: Expects the new API Model "LeaderboardPlayer"
    var user: LeaderboardPlayer
    var themeGreen: Color
    var isSticky: Bool
    var isCurrentUser: Bool // Passed directly to handle styling
    
    var body: some View {
        HStack(spacing: 15) {
            
            ZStack {
                if user.rank == 1 {
                    Image("gold")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                } else if user.rank == 2 {
                    Image("silver")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                } else if user.rank == 3 {
                    Image("bronze")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                } else {
                    Text("\(user.rank)")
                        .font(.custom("ClashDisplay-Bold", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(width: 40, alignment: .center)
            
            // 🛠️ FIXED: Uses user.name instead of username
            Text(user.name)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(isCurrentUser ? themeGreen : .white)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image("triangle")
                .resizable()
                .frame(width: 14, height: 14)
                
                // 🛠️ FIXED: Uses user.displayPoints helper we created earlier
                Text(String(format: "%.1f", user.displayPoints))
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(.white)
            }
        }
        .padding(18)
        .background(isSticky ? Color(red: 0.05, green: 0.07, blue: 0.05) : Color.white.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentUser ? themeGreen : Color.clear, lineWidth: 1.5)
        )
    }
}

struct SquarePageNumberButton: View {
    let page: Int
    let isSelected: Bool
    let themeGreen: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(page)")
                .font(.custom("ClashDisplay-Bold", size: 16))
                .foregroundColor(isSelected ? .black : themeGreen)
                .frame(width: 42, height: 42)
                .background(isSelected ? themeGreen : Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeGreen.opacity(isSelected ? 0 : 0.5), lineWidth: 1.5)
                )
        }
    }
}

struct SquarePaginationButton: View {
    let icon: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isDisabled ? .gray : .white)
                .frame(width: 42, height: 42)
                .background(Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isDisabled ? Color.gray.opacity(0.3) : Color.white.opacity(0.3), lineWidth: 1.5)
                )
        }
        .disabled(isDisabled)
    }
}

struct TabButton: View {
    var title: String
    var isSelected: Bool
    var themeGreen: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(isSelected ? .white : .gray)
                
                Rectangle()
                    .fill(isSelected ? themeGreen : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    RankingView()
        .preferredColorScheme(.dark)
}
