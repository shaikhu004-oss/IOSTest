// test/Features/Profile/View/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    // Custom colors
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    let darkBackground = Color(red: 0.04, green: 0.06, blue: 0.04)
    let rowBackground = Color(red: 0.08, green: 0.1, blue: 0.08)
    
    var body: some View {
        // 🌟 WRAPPED IN NAVIGATION STACK TO ALLOW ROUTING
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // --- HEADER ---
                        HStack {
                            Button(action: { }) {
                                Image(systemName: "chevron.left").font(.title3).foregroundColor(.white)
                            }
                            Spacer()
                            Text("Profile").font(.title3).fontWeight(.medium).foregroundColor(.white)
                            Spacer()
                            
                            // 🌟 NAVIGATION LINK TO SETTINGS
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill").font(.title3).foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal).padding(.top, 10)
                        
                        // --- PROFILE PICTURE ---
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(themeGreen.opacity(0.8))
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Text(String(viewModel.profile?.name?.prefix(1) ?? "U").uppercased())
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Circle()
                                .fill(themeGreen)
                                .frame(width: 32, height: 32)
                                .overlay(Image(systemName: "pencil").font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                                .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                .offset(x: -2, y: -2)
                        }
                        .padding(.top, 10)
                        
                        // --- USER INFO ---
                        VStack(spacing: 6) {
                            if viewModel.isLoading && viewModel.profile == nil {
                                ProgressView().tint(themeGreen)
                            } else {
                                Text(viewModel.profile?.name ?? "Loading...")
                                    .font(.title2).fontWeight(.bold).foregroundColor(themeGreen)
                                
                                Text("@\(viewModel.profile?.username ?? "username")")
                                    .font(.headline).foregroundColor(.white)
                                
                                Text("contact info").font(.caption).foregroundColor(.gray).padding(.top, 2)
                                
                                Text(viewModel.profile?.email ?? "...")
                                    .font(.subheadline).fontWeight(.semibold).foregroundColor(themeGreen)
                            }
                        }
                        
                        // --- WALLET BUTTON ---
                        NavigationLink(destination: WalletView()) {
                            Text("Wallet")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule().fill(Color.black.opacity(0.6))
                                        .shadow(color: themeGreen.opacity(0.3), radius: 15, x: 0, y: 0)
                                )
                                .overlay(
                                    Capsule().stroke(
                                        LinearGradient(gradient: Gradient(colors: [themeGreen.opacity(0.5), .clear]), startPoint: .top, endPoint: .bottom),
                                        lineWidth: 1
                                    )
                                )
                        }
                        .padding(.horizontal, 30).padding(.top, 10)
                        
                        // --- PERSONAL SECTION ---
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Personal").font(.headline).foregroundColor(.white).padding(.horizontal, 20).padding(.top, 10)
                            VStack(spacing: 12) {
                                ProfileRowView(title: "Tracking Details", hasChevron: true)
                                ProfileRowView(title: "Vehicle Details", hasChevron: true)
                                ProfileRowView(title: "Connect Fleet", isComingSoon: true)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // --- THE NEW REFERRALS SECTION ---
                        ReferralExpandedCard(
                            themeGreen: themeGreen,
                            themeBlack: rowBackground,
                            referralCode: viewModel.profile?.referralCode ?? "Loading..."
                        )
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .applyAppBackground()
            .navigationBarHidden(true)
            .task {
                if viewModel.profile == nil {
                    await viewModel.loadProfile()
                }
            }
        }
    }
}

// --- REUSABLE COMPONENT FOR ROWS ---
struct ProfileRowView: View {
    var title: String
    var hasChevron: Bool = false
    var isComingSoon: Bool = false
    
    var body: some View {
        HStack {
            Text(title).font(.subheadline).foregroundColor(.white)
            Spacer()
            if isComingSoon {
                Text("Coming Soon").font(.caption).foregroundColor(.gray)
            } else if hasChevron {
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

// --- EXPANDED REFERRAL CARD ---
struct ReferralExpandedCard: View {
    var themeGreen: Color
    var themeBlack: Color
    var referralCode: String
    
    @State private var showStats = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            HStack {
                Image(systemName: "gift.fill").font(.title2).foregroundColor(themeGreen)
                Text("Earn More with Referrals!")
                    .font(.title3).fontWeight(.black).foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("Climb the Leaderboard").font(.subheadline).foregroundColor(.white)
                }
                Text("Climb to the Top of the leaderboard and win exclusive rewards!\n\nThe more points you earn, the higher your chances of claiming the biggest prizes.")
                    .font(.caption).foregroundColor(.gray).lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "link").foregroundColor(.gray)
                    Text("Share & Earn").font(.subheadline).foregroundColor(.white)
                }
                Text("Invite your friends using your unique referral link, start earning when they join and contribute!")
                    .font(.caption).foregroundColor(.gray).lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "questionmark.square.fill").foregroundColor(themeGreen)
                    Text("How it works").font(.headline).fontWeight(.bold).foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark").foregroundColor(themeGreen).font(.caption).padding(.top, 2)
                        Text("Standard: ") + Text(Image(systemName: "triangle.fill")).foregroundColor(themeGreen) + Text(" +1 when a referred friend collects 1 ") + Text(Image(systemName: "square.fill")).foregroundColor(.blue) + Text(" Beat + 3 $PULS")
                    }.font(.caption).foregroundColor(.white)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark").foregroundColor(themeGreen).font(.caption).padding(.top, 2)
                        Text("Prime: ") + Text(Image(systemName: "triangle.fill")).foregroundColor(themeGreen) + Text(" +6 when your referred friend collects 50 ") + Text(Image(systemName: "square.fill")).foregroundColor(.blue) + Text(" Beats + 20 $PULS.")
                    }.font(.caption).foregroundColor(.white)
                }
                
                HStack {
                    Text("Your Referral Code").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) { showStats.toggle() }
                    }) {
                        Text(showStats ? "Hide Stats ^" : "Show Stats v")
                            .font(.caption).foregroundColor(.white)
                    }
                }
                .padding(.top, 5)
                
                HStack {
                    Text(referralCode)
                        .font(.headline).fontWeight(.bold).foregroundColor(themeGreen)
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = referralCode
                        print("Referral code copied to clipboard!")
                    }) {
                        Image(systemName: "square.on.square")
                            .foregroundColor(.gray).font(.title3)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .padding(20)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            
            if showStats {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "chart.bar.fill").foregroundColor(themeGreen)
                            Text("Your Referral Performance").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        }
                        
                        HStack {
                            Image(systemName: "triangle.fill").foregroundColor(themeGreen)
                            Text("Points").foregroundColor(.white)
                            Spacer()
                            Text("0").fontWeight(.bold).foregroundColor(themeGreen)
                        }
                        .padding().background(Color.black.opacity(0.5)).cornerRadius(12)
                        
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("STANDARD").font(.caption).foregroundColor(.gray)
                                Text("0").font(.title3).fontWeight(.bold).foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding().background(Color.black.opacity(0.5)).cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PRIME").font(.caption).foregroundColor(.gray)
                                Text("0").font(.title3).fontWeight(.bold).foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding().background(Color.black.opacity(0.5)).cornerRadius(12)
                        }
                        
                        HStack {
                            Image(systemName: "person.fill").foregroundColor(themeGreen)
                            Text("Referrals").foregroundColor(.white)
                            Spacer()
                            Text("0").fontWeight(.bold).foregroundColor(themeGreen)
                        }
                        .padding().background(Color.black.opacity(0.5)).cornerRadius(12)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    
                    Button(action: { }) {
                        Text("View Full History").font(.caption).foregroundColor(.white)
                    }
                }
            }
            
            Button(action: { }) {
                Text("Share")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.05, green: 0.15, blue: 0.1))
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    .shadow(color: themeGreen.opacity(0.4), radius: 20, x: 0, y: 10)
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(themeBlack)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
