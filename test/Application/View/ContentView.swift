// test/Application/View/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    // 🌟 1. Bring in the AuthViewModel to read the popup state
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        // 🌟 2. Wrap everything in a ZStack to layer the popup on top
        ZStack {
            
            // --- YOUR EXISTING TAB VIEW ---
            TabView(selection: $selectedTab) {
                
                // WALLET TAB
                WalletView()
                    .tabItem { Label("Wallet", systemImage: "wallet.pass") }
                    .tag(0)
                
                // HOME TAB
                HomeView(selectedTab: $selectedTab)
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(1)
                
                // RANKING TAB
                RankingView()
                    .tabItem { Label("Ranking", systemImage: "trophy") }
                    .tag(2)
                
                // PROFILE TAB
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(3)
            }
            .tint(.blue)
            
            // --- 🌟 3. THE POPUP OVERLAY LOGIC ---
            if authViewModel.showReferralPopup {
                
                // Dimmed background to focus the user on the popup
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                // The Custom Popup View
                ReferralPopupView(
                    onNext: { code in
                        print("📝 Referral code entered: \(code)")
                        // TODO: You can pass this code to your backend service here if needed.
                        
                        // Dismiss the popup smoothly
                        withAnimation {
                            authViewModel.showReferralPopup = false
                        }
                    },
                    onSkip: {
                        print("⏭️ Skipped referral")
                        // Dismiss the popup smoothly
                        withAnimation {
                            authViewModel.showReferralPopup = false
                        }
                    }
                )
                // Adds a nice slide-up and fade-in animation
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1) // Ensures the popup stays strictly above the TabView
            }
        }
        // Animates changes to the showReferralPopup state
        .animation(.spring(), value: authViewModel.showReferralPopup)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel()) // Needed so the preview doesn't crash
}
