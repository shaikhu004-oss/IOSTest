// test/Features/Wallet/View/WalletView.swift
import SwiftUI

struct WalletView: View {
    // Theme colors matching the dark aesthetic
    let themeBlack = Color(red: 0.05, green: 0.07, blue: 0.05)
    let cardBackground = Color(red: 0.08, green: 0.1, blue: 0.08)
    let themeGreen = Color(red: 0.2, green: 0.85, blue: 0.45)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- CARD 1: WALLET ADDRESS ---
                Button(action: {
                    UIPasteboard.general.string = "0xa2427.....7dcdab8"
                    print("Address copied!")
                }) {
                    HStack {
                        Text("Oxa2427.....7dcdab8")
                            .font(.headline) // Made slightly bolder to match image
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "square.on.square") // Swapped to square.on.square to match your image
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                    .padding(20)
                    .background(cardBackground) // 🌟 Added solid card background
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // --- CARD 2: TOTAL BALANCE ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("$0.00")
                        .font(.system(size: 48, weight: .bold)) // Massive font size
                        .foregroundColor(.white)
                    
                    // Inner Currency Dropdown Pill
                    Button(action: {
                        // Dropdown action
                    }) {
                        HStack {
                            Text("$ USD")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.4)) // Darker inner background
                        .cornerRadius(12)
                    }
                    .padding(.top, 5)
                }
                .padding(20)
                .background(cardBackground) // 🌟 Wrapped the whole balance section in a card background!
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // --- 3. HOLDINGS SECTION ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Holdings")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        HoldingCardView(
                            iconName: "line.3.horizontal.circle",
                            title: "APT",
                            subtitle: "Aptos Coin",
                            amount: "0.00000000",
                            fiatValue: "$0",
                            cardBackground: cardBackground
                        )
                        
                        HoldingCardView(
                            iconName: "tengesign.circle",
                            title: "USDT",
                            subtitle: "Tether USD",
                            amount: "0.00000000",
                            fiatValue: "$0",
                            cardBackground: cardBackground
                        )
                        
                        HoldingCardView(
                            iconName: "dollarsign.circle",
                            title: "USDC",
                            subtitle: "USDC Coin",
                            amount: "0.00000000",
                            fiatValue: "$0",
                            cardBackground: cardBackground
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
                
                // --- 4. WITHDRAW TO SECTION ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("Withdraw To")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        // External wallet action
                    }) {
                        VStack(spacing: 10) {
                            // Green Wallet Icon Box
                            Image(systemName: "wallet.pass.fill")
                                .font(.title3)
                                .foregroundColor(.black)
                                .frame(width: 40, height: 30)
                                .background(themeGreen)
                                .cornerRadius(8)
                            
                            Text("External Wallet")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(cardBackground)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // --- 5. TRANSACTION HISTORY LINK ---
                Button(action: {
                    // Navigate to history
                }) {
                    Text("Transaction History")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeGreen)
                        .underline()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                
                // Extra padding to scroll past the custom Tab Bar
                Spacer(minLength: 120)
            }
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .applyAppBackground()
    }
}

// --- REUSABLE HOLDING CARD COMPONENT ---
struct HoldingCardView: View {
    var iconName: String
    var title: String
    var subtitle: String
    var amount: String
    var fiatValue: String
    var cardBackground: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: iconName)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
            
            // Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Amounts
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(fiatValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        WalletView()
            .preferredColorScheme(.dark)
    }
}
