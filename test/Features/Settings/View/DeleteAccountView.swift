import SwiftUI

struct DeleteAccountView: View {
    // State variables
    @State private var selectedReason: String? = nil
    @State private var otherReasonText: String = ""
    
    // 🛠️ The sensor that tracks if the keyboard is open
    @FocusState private var isInputActive: Bool
    
    // Modern environment dismissal
    @Environment(\.dismiss) var dismiss
    
    // Theme Colors
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    let cardBackground = Color.white.opacity(0.05)
    let darkRed = Color(red: 0.7, green: 0.1, blue: 0.1)
    
    let reasons = [
        "I am no longer using my account",
        "I don't understand how to use",
        "I no longer need the service",
        "Privacy concerns",
        "Others"
    ]
    
    // Safety check to disable button until valid input is given
    var isDeleteDisabled: Bool {
        if selectedReason == "Others" {
            return otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return selectedReason == nil
    }
    
    var body: some View {
        ZStack {
            // Background color
            themeBlack.ignoresSafeArea()
                // 🛠️ Closes the keyboard if the user taps anywhere on the dark background
                .onTapGesture {
                    isInputActive = false
                }
            
            VStack(spacing: 0) {
                // --- CUSTOM TOP NAVIGATION BAR ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }
                    
                    Spacer()
                    
                    Text("Delete Account")
                        .font(.custom("ClashDisplay-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .opacity(0)
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // --- SCROLLABLE CONTENT ---
                ScrollView(showsIndicators: false) {
                    // The "Camera Operator" that controls scrolling
                    ScrollViewReader { scrollProxy in
                        VStack(spacing: 24) {
                            
                            Text("We're sorry to see you go. Are you sure you want to delete your account? Once confirmed, all your data will be permanently removed after 90 days.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .lineSpacing(4)
                            
                            VStack(spacing: 16) {
                                ForEach(reasons, id: \.self) { reason in
                                    Button(action: {
                                        // Smooth selection animation
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedReason = reason
                                        }
                                        
                                        // Scroll down to text box automatically
                                        if reason == "Others" {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                withAnimation(.easeOut(duration: 0.3)) {
                                                    scrollProxy.scrollTo("OthersTextBox", anchor: .bottom)
                                                }
                                            }
                                        } else {
                                            // Close keyboard if they switch to a different reason
                                            isInputActive = false
                                        }
                                    }) {
                                        HStack(spacing: 16) {
                                            Image(systemName: selectedReason == reason ? "circle.fill" : "circle")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(themeGreen)
                                            
                                            Text(reason)
                                                .font(.custom("ClashDisplay-Medium", size: 16))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(cardBackground)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedReason == reason ? themeGreen.opacity(0.5) : themeGreen.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Conditional Text Box
                                if selectedReason == "Others" {
                                    VStack(alignment: .leading, spacing: 8) {
                                        TextField("Please specify your reason...", text: $otherReasonText, axis: .vertical)
                                            .focused($isInputActive) // 🛠️ Attaches the focus sensor here
                                            .font(.custom("ClashDisplay-Regular", size: 14))
                                            .foregroundColor(.white)
                                            .lineLimit(3...6)
                                            .padding()
                                            .frame(minHeight: 80, alignment: .topLeading)
                                            .background(cardBackground)
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(themeGreen.opacity(0.4), lineWidth: 1)
                                            )
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .id("OthersTextBox") // The nametag the scrollProxy looks for
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                        // 🛠️ Closes the keyboard if they tap the empty space inside the scrollview
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isInputActive = false
                        }
                    }
                }
                
                // --- RED DELETE BUTTON ---
                Button(action: {
                    print("Account delete requested. Reason: \(selectedReason ?? "None")")
                    if selectedReason == "Others" {
                        print("User specified: \(otherReasonText)")
                    }
                }) {
                    Text("Delete Account")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(isDeleteDisabled ? .white.opacity(0.5) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isDeleteDisabled ? darkRed.opacity(0.4) : darkRed)
                        .cornerRadius(24)
                }
                .disabled(isDeleteDisabled)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                // 🛠️ DYNAMIC PADDING: 20 if typing (keyboard open), 120 if closed (Tab Bar clearance)
                .padding(.bottom, isInputActive ? 20 : 120)
                .animation(.easeOut(duration: 0.3), value: isInputActive)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    DeleteAccountView()
}
