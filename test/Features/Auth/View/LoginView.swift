// test/Features/Auth/View/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Theme colors to match your app
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 1. App Logo & Welcome Text
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Welcome to Scout")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Sign in to sync your stats and rankings.")
                    .font(.subheadline)
                    // Changed to gray for a clean subtitle look
                    .foregroundColor(.gray)
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
                // Keeping the button white is standard for the "Sign in with Google" design guidelines
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        // 🌟 Replaced the old light background with your new global dark modifier!
        .applyAppBackground()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
