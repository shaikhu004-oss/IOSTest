// test/Features/Auth/View/SplashView.swift
import SwiftUI

struct SplashView: View {
    @State private var isSplashFinished = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Inject our auth manager
    @StateObject private var authViewModel = AuthViewModel()
    
    // Theme colors to match your app
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    
    var body: some View {
        ZStack {
            if isSplashFinished {
                // ROUTING LOGIC: Check if user is logged in
                if authViewModel.isAuthenticated {
                    ContentView()
                        .environmentObject(authViewModel) // Pass it down so you can log out later
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            } else {
                // --- SPLASH SCREEN CONTENT ---
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        
                    Text("Scout Lite")
                        .font(.custom("Fauna", size: 25))
                        .foregroundColor(.white) // Ensure it is white for the dark background
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
                // Ensure the VStack takes up the full screen space
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // 🌟 Apply the global dark gradient background here!
                .applyAppBackground()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isSplashFinished = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
