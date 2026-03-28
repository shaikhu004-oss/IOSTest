// test/Application/View/SplashView.swift
import SwiftUI

struct SplashView: View {
    @State private var isSplashFinished = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Inject our auth manager
    @StateObject private var authViewModel = AuthViewModel()
    
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
                Color("SplashBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    
                    Text("FitTracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
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
