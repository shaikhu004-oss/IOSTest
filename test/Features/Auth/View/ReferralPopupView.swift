import SwiftUI

struct ReferralPopupView: View {
    @State private var referralCode: String = ""
    
    // 🌟 NEW: Receive the generated username
    var generatedUsername: String
    
    // Closures to handle the button taps
    var onNext: (String) -> Void
    var onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            
            // 🌟 NEW: Display the generated username
            VStack(spacing: 4) {
                Text("Welcome!")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text(generatedUsername)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.top, 10)
            
            Text("Do you have a referral?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
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
                    .preferredColorScheme(.dark)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    onNext(referralCode)
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(25)
                }
                
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
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
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
        ReferralPopupView(generatedUsername: "scout_rider_000001", onNext: { _ in }, onSkip: { })
    }
}
