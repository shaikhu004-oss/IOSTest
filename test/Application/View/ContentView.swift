// test/Application/View/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // WALLET TAB
            WalletView()
                .tabItem { Label("Wallet", systemImage: "wallet.pass") }
                .tag(0)
            
            // HOME TAB
            // We pass the $selectedTab binding so the HomeView can still navigate to the Profile tab
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
    }
}

#Preview {
    ContentView()
}
