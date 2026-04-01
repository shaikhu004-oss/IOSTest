//
//  ReferralPopupView.swift
//  test
//
//  Created by Umar Momin on 01/04/26.
//


// test/Features/Auth/View/ReferralPopupView.swift
import SwiftUI

struct ReferralPopupView: View {
    @State private var referralCode: String = ""
    
    // Closures to handle the button taps
    var onNext: (String) -> Void
    var onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("Do you have a referral?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Referral Code")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter referral code", text: $referralCode)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    // Makes the placeholder text gray instead of default
                    .preferredColorScheme(.dark) 
            }
            
            VStack(spacing: 15) {
                // Next Button
                Button(action: {
                    onNext(referralCode)
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green) // You can use a custom hex color if you have a specific brand green
                        .cornerRadius(25)
                }
                
                // Skip Button
                Button(action: {
                    onSkip()
                }) {
                    Text("Skip")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1)) // Dark gray card background
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ReferralPopupView(onNext: { _ in }, onSkip: { })
    }
}