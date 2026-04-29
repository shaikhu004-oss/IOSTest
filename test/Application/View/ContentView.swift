import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @State private var profilePath = NavigationPath()
    
    // 🛠️ 1. State to control custom tab bar visibility
    @State private var showCustomTabBar = true
    
    @EnvironmentObject var authViewModel: AuthViewModel

    // Theme colors
    let themeGreen = Color(red: 0.2, green: 0.85, blue: 0.45)
    let tabBackground = Color(red: 0.02, green: 0.02, blue: 0.02)
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // --- MAIN SCREENS ---
            TabView(selection: $selectedTab) {
                RankingView()
                    .applyAppBackground()
                    .tag(0)
                
                HomeView(selectedTab: $selectedTab)
                    .applyAppBackground()
                    .tag(1)
                
                ProfileView(path: $profilePath)
                    .applyAppBackground()
                    .tag(2)
            }
            
            // --- CUSTOM TAB BAR ---
            // 🛠️ 2. Hide the Custom Tab Bar when the state is false
            if showCustomTabBar {
                VStack(spacing: 0) {
                    Divider().background(Color.white.opacity(0.1))
                    
                    HStack(alignment: .center) {
                        
                        // 1. LEADERBOARD TAB
                        Button(action: { selectedTab = 0 }) {
                            VStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                                
                                Text("Leaderboard")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(selectedTab == 0 ? themeGreen : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // 2. HOME TAB (Custom Drawn Icon!)
                        Button(action: { selectedTab = 1 }) {
                            ZStack {
                                // 3D Gradient Circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.82, blue: 0.6), // Bright mint top
                                                Color(red: 0.02, green: 0.58, blue: 0.4) // Deep forest bottom
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                
                                // 🌟 Exact Custom Drawn House Icon
                                ZStack {
                                    CustomHomeShape()
                                        // lineJoin: .round gives it those beautiful soft corners from your image!
                                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                                        .frame(width: 24, height: 22)
                                        .offset(y: -2)
                                    
                                    // The inner horizontal dash
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: 9, height: 2.5)
                                        .offset(y: 5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 3. PROFILE TAB
                        Button(action: {
                            selectedTab = 2
                            profilePath = NavigationPath()
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "person")
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedTab == 2 ? .white : .gray)
                                
                                Text("Profile")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(selectedTab == 2 ? themeGreen : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .background(tabBackground)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // --- REFERRAL POPUP OVERLAY ---
            if authViewModel.showReferralPopup {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                ReferralPopupView(
                    generatedUsername: authViewModel.generatedUsername,
                    onNext: { code in authViewModel.submitOnboarding(referralCode: code) },
                    onSkip: { authViewModel.submitOnboarding(referralCode: nil) }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(), value: authViewModel.showReferralPopup)
        
        // 🛠️ 3. Listen for the global broadcast to hide/show the tab bar
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HideCustomTabBar"))) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                showCustomTabBar = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowCustomTabBar"))) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                showCustomTabBar = true
            }
        }
    }
}

// 🌟 THE CUSTOM SHAPE (Draws the exact geometry of your custom icon)
struct CustomHomeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let roofBottom = h * 0.45
        
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: roofBottom))
        path.addLine(to: CGPoint(x: w / 2, y: 0))
        path.addLine(to: CGPoint(x: w, y: roofBottom))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
