import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    @State private var showInfoPopup = false
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
                    RewardsCardView(viewModel: viewModel, themeGreen: themeGreen, isPopupShowing: $showRewardPopup, isInfoShowing: $showInfoPopup)
                    
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
                                if viewModel.isLoading && viewModel.users.isEmpty {
                                    ForEach(0..<10, id: \.self) { _ in
                                        SkeletonRowView()
                                    }
                                } else {
                                    ForEach(viewModel.users) { user in
                                        PlayerRowView(
                                            user: user,
                                            themeGreen: themeGreen,
                                            isSticky: false,
                                            isCurrentUser: false,
                                            selectedTab: viewModel.selectedTab
                                        )
                                    }
                                }
                            }
                            
                            // --- 5. SQUARE PAGINATION ---
                            if viewModel.isLoading && viewModel.users.isEmpty {
                                SkeletonPaginationView()
                                    .padding(.top, 25)
                                    .padding(.bottom, 30)
                            } else if !viewModel.users.isEmpty {
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 180)
                    }
                    
                    // --- 6. STICKY CURRENT USER CARD ---
                    if viewModel.isLoading {
                        SkeletonRowView()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 90)
                    } else if let currentUser = viewModel.currentUser {
                        PlayerRowView(
                            user: currentUser,
                            themeGreen: themeGreen,
                            isSticky: true,
                            isCurrentUser: true,
                            selectedTab: viewModel.selectedTab
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 90)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        // Main Reward Popup
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
        // 🛠️ UPDATED: Now points perfectly to the new RewardsInformationPopupView
        .fullScreenCover(isPresented: $showInfoPopup) {
            RewardsInformationPopupView(isPresented: $showInfoPopup, themeGreen: themeGreen)
                .presentationBackground(.clear)
        }
    }
}

// MARK: - Reusable Helper Components

struct CountdownCard: View {
    var themeGreen: Color
    var timeRemaining: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Leaderboard Resets")
                .font(.custom("ClashDisplay-Medium", size: 14))
                .foregroundColor(.gray)
            Text(timeRemaining)
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
    @Binding var isInfoShowing: Bool
    
    var subtitle: String {
        viewModel.selectedTab == "Beats"
        ? "Earn rewards every 7 days by collecting the most data points (Beats)."
        : "Earn rewards by referring friends and growing our community."
    }
    
    var totalAmount: String {
        if let data = viewModel.rewardsData {
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
                
                Button(action: {
                    withAnimation(.spring()) {
                        isInfoShowing = true
                    }
                }) {
                    Image("info2")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                
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

// 🛠️ EXACT POPUP DESIGN YOU PROVIDED
struct RewardsInformationPopupView: View {
    @Binding var isPresented: Bool
    var themeGreen: Color
    
    var body: some View {
        ZStack {
            // Dark Background Dimming
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) { isPresented = false }
                }
            
            VStack(alignment: .leading, spacing: 20) {
                // --- 1. HEADER & CLOSE BUTTON ---
                HStack {
                    Text("Rewards Information")
                        .font(.custom("ClashDisplay-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut) { isPresented = false }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 2. WEEKLY LEADERBOARD REWARDS ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Leaderboard Rewards")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(.white)// EXACT MATCH: Green Header
                            
                            Text("Compete with drivers and win rewards every leaderboard time based on leaderboard ranking")
                                .font(.custom("ClashDisplay-Regular", size: 14))
                                .foregroundColor(Color.white.opacity(0.7))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // --- 3. HOW IT WORKS ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How It Works:")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(themeGreen)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletRowView(text: "Rankings are based on total beats earned during the Leaderboard.")
                                BulletRowView(text: "Rewards are distributed at the end of each Leaderboard.")
                                BulletRowView(text: "Currency conversion uses real-time exchange rates from CoinMarketCap.")
                            }
                        }
                        
                        // --- 4. PAYMENTS ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Payments:")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(themeGreen)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletRowView(text: "Rewards are transferred directly to your registered bank account within 5-7 business days after week end.")
                            }
                        }
                    }
                    .padding(.bottom, 10)
            }
            .padding(24)
            .background(Color(red: 0.07, green: 0.08, blue: 0.07)) // EXACT MATCH: App card background
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 20)
        }
    }
}

// 🛠️ HELPER FOR POPUP
struct BulletRowView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.custom("ClashDisplay-Bold", size: 14))
                .foregroundColor(Color.white.opacity(0.7))
            
            Text(text)
                .font(.custom("ClashDisplay-Regular", size: 14))
                .foregroundColor(Color.white.opacity(0.7))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Remaining Shared Components

struct PlayerRowView: View {
    var user: LeaderboardPlayer
    var themeGreen: Color
    var isSticky: Bool
    var isCurrentUser: Bool
    var selectedTab: String
    
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
            
            Text(user.name)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(isCurrentUser ? themeGreen : .white)
                .lineLimit(1)
            
            Spacer()
            
            // 🛠️ EXACTLY YOUR EXISTING CODE
            HStack(spacing: 4) {
                Image(selectedTab == "Beats" ? "beats" : "triangle")
                    .resizable()
                    .frame(width: 14, height: 14)
                
                Text(String(format: "%.1f", user.displayPoints))
                    .font(.custom("ClashDisplay-Bold", size: 16))
                    .foregroundColor(.white)
            }
            // 🛠️ ONLY ADDED THESE 5 LINES TO CREATE THE BOX
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
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

struct SkeletonRowView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 25, height: 25)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .frame(width: 120, height: 16)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .frame(width: 50, height: 16)
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct SkeletonPaginationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 42, height: 42)
            }
        }
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    RankingView()
        .preferredColorScheme(.dark)
}
