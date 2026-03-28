import SwiftUI

// Blueprint for a transaction
struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: String
    let isPositive: Bool
}

struct WalletView: View {
    // Mock data for recent activity
    let transactions = [
        Transaction(title: "Morning Run (5km)", date: "Today", amount: "+50", isPositive: true),
        Transaction(title: "Redeemed Water Bottle", date: "Yesterday", amount: "-500", isPositive: false),
        Transaction(title: "Weekly Step Goal", date: "Mar 15", amount: "+200", isPositive: true),
        Transaction(title: "Profile Completion", date: "Mar 10", amount: "+100", isPositive: true)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // --- 1. THE BALANCE CARD ---
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // TOP ROW: Wallet Address & Icon
                        HStack {
                            // MOVED WALLET ADDRESS PILL HERE
                            Button(action: {
                            UIPasteboard.general.string = "0x71C...9A23"
                            print("Address actually copied to clipboard!")
                        }) {
                                HStack(spacing: 6) {
                                    Text("0x71C...9A23")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "doc.on.doc")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        // MIDDLE ROW: Balance Title & Amount
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Balance")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("$2,132.25")
                                .font(.system(size: 45, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // BOTTOM ROW: Available to withdraw
                        Text("Available to withdraw")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(25)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(25)
                    .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    // -------------------------------------------
                    
                    // --- 2. ACTION BUTTONS ---
                    HStack(spacing: 20) {
                        WalletActionButton(icon: "arrow.down.circle.fill", title: "Receive")
                        WalletActionButton(icon: "arrow.up.circle.fill", title: "Send")
                        WalletActionButton(icon: "gift.fill", title: "Redeem")
                    }
                    .padding(.horizontal, 20)
                    
                    // --- 3. HOLDINGS SECTION ---
                    VStack(alignment: .leading, spacing: 0) {
                        HoldingRow(icon: "a.circle.fill", iconColor: .black, name: "Aptos", symbol: "APT", amount: "145.50", fiatValue: "$1,382.25")
                        Divider().padding(.leading, 70)
                        HoldingRow(icon: "t.circle.fill", iconColor: .green, name: "Tether", symbol: "USDT", amount: "500.00", fiatValue: "$500.00")
                        Divider().padding(.leading, 70)
                        HoldingRow(icon: "c.circle.fill", iconColor: .blue, name: "USD Coin", symbol: "USDC", amount: "250.00", fiatValue: "$250.00")
                    }
                    
                    // --- 4. RECENT ACTIVITY LIST ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Activity")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        ForEach(transactions) { transaction in
                            HStack {
                                Image(systemName: transaction.isPositive ? "plus.circle.fill" : "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(transaction.isPositive ? .green : .red)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(transaction.title)
                                        .font(.headline)
                                    Text(transaction.date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(transaction.amount)
                                    .font(.headline)
                                    .foregroundColor(transaction.isPositive ? .green : .primary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .navigationTitle("My Wallet")
        }
    }
}

// Reusable component for the round action buttons
struct WalletActionButton: View {
    var icon: String
    var title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

// Reusable component for coin holdings
struct HoldingRow: View {
    var icon: String
    var iconColor: Color
    var name: String
    var symbol: String
    var amount: String
    var fiatValue: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.headline)
                Text(fiatValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    WalletView()
}
