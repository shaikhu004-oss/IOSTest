import SwiftUI

struct RankingPopupUI: View {
    // Default values set to match your Beats image
    var title: String = "Beats Ranking"
    var description: String = "Your rank is calculated based on total Beats contributed. Higher activity increases your position on the global leaderboard."
    var iconName: String = "beats"
    var onClose: () -> Void = {}
    
    var body: some View {
        ZStack {
            // 1. Dark Dimming Overlay
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
            
            // 2. Popup Card
            VStack(spacing: 0) {
                
                // --- Top-Right Close Button ---
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(white: 0.6)) // Light gray cross
                            .frame(width: 30, height: 30) // Perfect circle
                            .background(Color.white.opacity(0.08)) // Subtle circle background
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
                // --- Central Icon ---
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
                    .padding(.top, -10) // Pulls the icon up slightly into the empty space
                    .padding(.bottom, 20)
                
                // --- Title ---
                Text(title)
                    .font(.custom("ClashDisplay-Bold", size: 22))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
                
                // --- Description ---
                Text(description)
                    .font(.custom("ClashDisplay-Medium", size: 14))
                    .foregroundColor(Color(white: 0.6)) // Exact gray from design
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36) // Generous bottom padding to match the image
            }
            .frame(width: 320) // Fixed width forces the text to wrap exactly like the image
            .background(Color(red: 0.08, green: 0.09, blue: 0.08)) // Elevated card color
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1) // Crisp premium border
            )
        }
    }
}

// See it perfectly in your preview!
#Preview {
    RankingPopupUI()
}