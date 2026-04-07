// test/Application/View/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @EnvironmentObject var authViewModel: AuthViewModel

    // Exact Theme Colors mapped from the screenshot
    let themeGreen = Color(red: 0.2, green: 0.85, blue: 0.45) // Bright neon green outline
    let darkGreenFill = Color(red: 0.05, green: 0.15, blue: 0.08) // Dark inner circle
    let tabBackground = Color(red: 0.02, green: 0.02, blue: 0.02) // Deepest black
    
    init() {
        // Hide the default iOS TabBar so we can use our custom one
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // --- MAIN SCREENS ---
            TabView(selection: $selectedTab) {
                RankingView()
                    .tag(0)
                
                HomeView(selectedTab: $selectedTab)
                    .tag(1)
                
                ProfileView()
                    .tag(2)
            }
            
            // --- PIXEL-PERFECT CUSTOM TAB BAR ---
            VStack(spacing: 0) {
                // Subtle top border line
                Divider().background(Color.white.opacity(0.1))
                
                HStack(alignment: .bottom) {
                    
                    // 1. LEADERBOARD TAB
                    Button(action: { selectedTab = 0 }) {
                        VStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                            Text("Leaderboard")
                                .font(.system(size: 11, weight: .medium))
                        }
                        // White when active, Gray when inactive
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 15) // Aligns with the bottom of the tab bar
                    
                    // 2. CENTER HOME BUTTON
                    Button(action: { selectedTab = 1 }) {
                        ZStack {
                            // Background mask to hide the tab bar line
                            Circle()
                                .fill(tabBackground)
                                .frame(width: 64, height: 64)
                            
                            // The dark green inner fill
                            Circle()
                                .fill(darkGreenFill)
                                .frame(width: 58, height: 58)
                            
                            // The bright green stroke outline
                            Circle()
                                .stroke(themeGreen, lineWidth: 2.5)
                                .frame(width: 58, height: 58)
                            
                            // Hollow House Icon exactly like the design
                            Image(systemName: "house")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(selectedTab == 1 ? .white : .gray)
                        }
                        // This makes it "float" above the tab bar perfectly
                        .offset(y: -20)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 3. PROFILE TAB
                    Button(action: { selectedTab = 2 }) {
                        VStack(spacing: 4) {
                            // Hollow person icon exactly like the design
                            Image(systemName: "person")
                                .font(.system(size: 24))
                            Text("Profile")
                                .font(.system(size: 11, weight: .medium))
                        }
                        // White when active, Gray when inactive
                        .foregroundColor(selectedTab == 2 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 15)
                }
                .frame(height: 70) // Fixed height to match design proportions
                .background(tabBackground)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // --- REFERRAL POPUP OVERLAY ---
            if authViewModel.showReferralPopup {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                ReferralPopupView(
                    generatedUsername: authViewModel.generatedUsername,
                    onNext: { code in
                        authViewModel.submitOnboarding(referralCode: code)
                    },
                    onSkip: {
                        authViewModel.submitOnboarding(referralCode: nil)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.spring(), value: authViewModel.showReferralPopup)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
