import SwiftUI

struct ReferralRewardsView: View {
    @Binding var isPresented: Bool
    
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    
    var body: some View {
        ZStack {
            // Background Dimming
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isPresented = false
                    }
                }
            
            // Modal Container
            VStack(spacing: 0) {
                // --- HEADER ---
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Referral Rewards")
                            .font(.custom("ClashDisplay-Bold", size: 22))
                            .foregroundColor(.white)
                        
                        // Updated text for Referrals
                        Text("Earn rewards every 7 days by inviting the most friends to PathPulse.")
                            .font(.system(size: 14))
                            .foregroundColor(themeGreen)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 16)
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 20)
                
                // --- TOTAL ROW ---
                HStack {
                    Text("Total")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                    Spacer()
                    Text("$450") // Update this if the referral pool is different
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                    Spacer()
                    Text("$450")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                }
                .padding()
                .background(themeBlack)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeGreen.opacity(0.4), lineWidth: 1)
                )
                .padding(.bottom, 24)
                
                // --- TABLE HEADERS ---
                HStack {
                    Text("Rank")
                        .frame(width: 60, alignment: .leading)
                    Spacer()
                    Text("USD")
                        .frame(width: 80, alignment: .trailing)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("USD")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(width: 80, alignment: .trailing)
                }
                .font(.custom("ClashDisplay-Bold", size: 16))
                .foregroundColor(themeGreen)
                .padding(.bottom, 16)
                
                // --- REWARDS LIST ---
                VStack(spacing: 18) {
                    // You can adjust these amounts if Referral rewards differ from Beats rewards
                    RewardRow(rank: "1", amount: "$45", themeGreen: themeGreen)
                    RewardRow(rank: "2", amount: "$35", themeGreen: themeGreen)
                    RewardRow(rank: "3", amount: "$30", themeGreen: themeGreen)
                    RewardRow(rank: "4", amount: "$25", themeGreen: themeGreen)
                    RewardRow(rank: "5", amount: "$20", themeGreen: themeGreen)
                    RewardRow(rank: "6 - 10", amount: "$15", themeGreen: themeGreen)
                    RewardRow(rank: "11 - 20", amount: "$12", themeGreen: themeGreen)
                    RewardRow(rank: "21 - 30", amount: "$10", themeGreen: themeGreen)
                }
                .padding(.bottom, 10)
            }
            .padding(24)
            .background(Color(red: 0.07, green: 0.08, blue: 0.07))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}