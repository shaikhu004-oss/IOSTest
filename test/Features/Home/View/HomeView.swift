import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int
    
    // UI State for the timeframe picker
    @State private var selectedTimeframe = "Daily"
    let timeframes = ["Daily", "Weekly", "Monthly", "Custom"]
    
    // Theme colors
    let themeBlack = Color(red: 0.08, green: 0.1, blue: 0.08)
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    let cardBackground = Color(red: 0.05, green: 0.07, blue: 0.05)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // --- CUSTOM HEADER ---
                HStack {
                    Text("Home")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // PULS Pill
                    HStack(spacing: 4) {
                        Text("P")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(4)
                            .background(Circle().fill(themeGreen))
                        
                        Text("10")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    
                    // Bell Icon
                    Button(action: { }) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    .padding(.leading, 5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- YOUR TOTAL STATS CARD ---
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Card Title
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(themeGreen)
                                    .fontWeight(.bold)
                                Text("Your Total Stats")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            // Timeframe Picker
                            HStack(spacing: 10) {
                                ForEach(timeframes, id: \.self) { timeframe in
                                    Button(action: {
                                        withAnimation { selectedTimeframe = timeframe }
                                    }) {
                                        Text(timeframe)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedTimeframe == timeframe ? .white : .gray)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(selectedTimeframe == timeframe ? Color.clear : Color.black.opacity(0.4))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(selectedTimeframe == timeframe ? themeGreen : Color.white.opacity(0.05), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            
                            // Stats Grid
                            VStack(spacing: 15) {
                                HStack(spacing: 15) {
                                    PrimaryStatCard(title: "Beats", value: "0.00", iconSystemName: "square.fill", iconColor: .blue, themeGreen: themeGreen)
                                    PrimaryStatCard(title: "$PULS", value: "10.00", iconSystemName: "p.circle.fill", iconColor: themeGreen, themeGreen: themeGreen)
                                }
                                
                                HStack(spacing: 15) {
                                    SecondaryStatCard(title: "Time", value: "00:00", unit: "Hours", themeGreen: themeGreen)
                                    SecondaryStatCard(title: "Distance", value: "0.0", unit: "Kilometers", themeGreen: themeGreen)
                                }
                            }
                        }
                        .padding(20)
                        .background(themeBlack)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        // --- UPLOAD STATUS CARD ---
                        HStack(spacing: 15) {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .foregroundColor(themeGreen)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upload Detections (0), Trips (0)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                
                                Text("0 trip(s), 0 sequence(s) ready")
                                    .font(.caption)
                                    .foregroundColor(Color.gray.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                        .padding(20)
                        .background(themeBlack)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // --- START TRACKING BUTTON ---
                Button(action: {
                    viewModel.toggleTracking()
                }) {
                    Text(viewModel.isTracking ? "Stop Tracking" : "Start Tracking")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.05, green: 0.15, blue: 0.1))
                        .cornerRadius(30)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: themeGreen.opacity(viewModel.isTracking ? 0 : 0.4), radius: 20, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
                .padding(.top, 10)
            }
            .navigationBarHidden(true)
            .applyAppBackground()
        }
    }
}

// --- REUSABLE STAT CARDS ---

struct PrimaryStatCard: View {
    var title: String
    var value: String
    var iconSystemName: String
    var iconColor: Color
    var themeGreen: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(themeGreen)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Image(systemName: iconSystemName)
                .font(.title3)
                .foregroundColor(iconColor)
                .padding(.top, 4)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.4))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct SecondaryStatCard: View {
    var title: String
    var value: String
    var unit: String
    var themeGreen: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(themeGreen)
                .padding(.top, 4)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.4))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

#Preview {
    HomeView(selectedTab: .constant(1))
        .preferredColorScheme(.dark)
}
