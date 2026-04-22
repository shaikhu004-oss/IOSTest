import SwiftUI

struct DeleteAccountView: View {
    // This remembers which option the user tapped
    @State private var selectedReason: String? = nil
    
    // To handle the custom back button
    @Environment(\.presentationMode) var presentationMode
    
    // Theme Colors
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    let cardBackground = Color.white.opacity(0.05)
    let darkRed = Color(red: 0.7, green: 0.1, blue: 0.1)
    
    // The list of reasons
    let reasons = [
        "I am no longer using my account",
        "I don't understand how to use",
        "I no longer need the service",
        "Privacy concerns",
        "Others"
    ]
    
    var body: some View {
        ZStack {
            themeBlack.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // --- CUSTOM TOP NAVIGATION BAR ---
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Goes back to settings
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Delete Account")
                        .font(.custom("ClashDisplay-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible button to keep the title perfectly centered
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // --- HEADER TEXT ---
                Text("We're sorry to see you go. Are you sure you want to delete your account? Once confirmed, all your data will be permanently removed after 90 days.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(4)
                
                // --- SELECTION LIST ---
                VStack(spacing: 16) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: {
                            // When tapped, remember this reason
                            selectedReason = reason
                        }) {
                            HStack(spacing: 16) {
                                // The Circle Icon
                                Image(systemName: selectedReason == reason ? "circle.fill" : "circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(themeGreen)
                                
                                // The Text
                                Text(reason)
                                    .font(.custom("ClashDisplay-Medium", size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // --- RED DELETE BUTTON ---
                Button(action: {
                    // This is where you would call your API to delete the account
                    print("Account delete requested. Reason: \(selectedReason ?? "None")")
                }) {
                    Text("Delete Account")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(darkRed)
                        .cornerRadius(24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        // Hides the default Apple navigation bar so our custom one looks perfect
        .navigationBarHidden(true)
    }
}

#Preview {
    DeleteAccountView()
}