import SwiftUI

// 🛠️ Shared grouping struct
struct GroupedReward: Identifiable {
    let id = UUID()
    let rankText: String
    let value: Int
}

struct BeatsRewardsView: View {
    @Binding var isPresented: Bool
    var rewards: [RewardTier]
    
    let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    let themeGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
    
    var totalAmount: String {
        let sum = rewards.reduce(0) { $0 + $1.value }
        return "$\(sum)"
    }
    
    var groupedRewards: [GroupedReward] {
        guard !rewards.isEmpty else { return [] }
        let sorted = rewards.sorted(by: { $0.rank < $1.rank })
        var result: [GroupedReward] = []
        var startRank = sorted[0].rank
        var endRank = sorted[0].rank
        var currentValue = sorted[0].value
        
        for i in 1..<sorted.count {
            let current = sorted[i]
            if current.value == currentValue && current.rank == endRank + 1 {
                endRank = current.rank
            } else {
                let rankStr = (startRank == endRank) ? "\(startRank)" : "\(startRank) - \(endRank)"
                result.append(GroupedReward(rankText: rankStr, value: currentValue))
                startRank = current.rank
                endRank = current.rank
                currentValue = current.value
            }
        }
        let rankStr = (startRank == endRank) ? "\(startRank)" : "\(startRank) - \(endRank)"
        result.append(GroupedReward(rankText: rankStr, value: currentValue))
        return result
    }
    
    var body: some View {
        ZStack {
            // Background Dimming
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) { isPresented = false }
                }
            
            // --- THE SOLID MODAL CARD ---
            VStack(spacing: 0) {
                // --- HEADER ---
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Beats Rewards")
                            .font(.custom("ClashDisplay-Bold", size: 22))
                            .foregroundColor(.white)
                        
                        Text("Earn rewards every 7 days by collecting the most data points (Beats).")
                            .font(.system(size: 14))
                            .foregroundColor(themeGreen)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 16)
                    Button(action: {
                        withAnimation(.easeInOut) { isPresented = false }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                .padding(.bottom, 24)
                
                // --- TOTAL ROW ---
                HStack {
                    Text("Total")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                    Spacer()
                    Text(totalAmount)
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                    Spacer()
                    Text(totalAmount)
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(themeGreen)
                }
                .padding(20)
                .background(themeBlack)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeGreen.opacity(0.4), lineWidth: 1))
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
                
                // --- INNER SCROLLVIEW (Only the list scrolls!) ---
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(groupedRewards) { group in
                            RewardRow(
                                rank: group.rankText,
                                amount: "$\(group.value)",
                                themeGreen: themeGreen
                            )
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxHeight: 350) // Keeps the card a nice size
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 24)
            .background(Color(red: 0.07, green: 0.08, blue: 0.07))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 20)
            
            // 🛠️ THE FIX: This invisible padding forces the entire modal upward!
            .padding(.bottom, 40)
        }
    }
}

// Reusable Row Component
struct RewardRow: View {
    let rank: String
    let amount: String
    let themeGreen: Color
    
    var body: some View {
        HStack {
            Text(rank)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            Spacer()
            Text(amount)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(themeGreen)
                .frame(width: 80, alignment: .trailing)
            Spacer()
            Text(amount)
                .font(.custom("ClashDisplay-Medium", size: 16))
                .foregroundColor(themeGreen)
                .frame(width: 80, alignment: .trailing)
        }
    }
}
