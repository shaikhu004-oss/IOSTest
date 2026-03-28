// test/Features/Profile/View/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 1. App Logo & Welcome Text
            VStack(spacing: 15) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text("Welcome to FitTracker")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sign in to sync your stats and rankings.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // 2. Google Sign In Button
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                HStack(spacing: 15) {
                    // Note: In a real app, you'd add the actual Google "G" logo to your Assets
                    // and use Image("GoogleLogo") here instead of the globe symbol.
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Continue with Google")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
