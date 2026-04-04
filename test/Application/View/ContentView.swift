import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                WalletView()
                    .tabItem { Label("Wallet", systemImage: "wallet.pass") }
                    .tag(0)
                
                HomeView(selectedTab: $selectedTab)
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(1)
                
                RankingView()
                    .tabItem { Label("Ranking", systemImage: "trophy") }
                    .tag(2)
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(3)
            }
            .tint(.blue)
            
            if authViewModel.showReferralPopup {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                ReferralPopupView(
                    generatedUsername: authViewModel.generatedUsername, // 🌟 NEW: Pass it here
                    onNext: { code in
                        print("✅ Referral code entered: \(code)")
                        print("✅ Username to send to backend: \(authViewModel.generatedUsername)")
                        
                        // TODO: Fire off the network request here to save both `code` and `generatedUsername`
                        
                        withAnimation {
                            authViewModel.showReferralPopup = false
                        }
                    },
                    onSkip: {
                        print("⏭️ Skipped referral")
                        
                        // TODO: Fire off network request to save `generatedUsername` without a code
                        
                        withAnimation {
                            authViewModel.showReferralPopup = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(), value: authViewModel.showReferralPopup)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
