import SwiftUI

// MARK: - 1. Data Model
/// Represents a single tracked session/trip.
struct TrackingSession: Identifiable {
    let id = UUID()
    let dateString: String
    let beats: String
    let time: String
    let distance: String
    let pulseEarned: String
    var initiallyExpanded: Bool = false
}

// MARK: - 2. Main Screen View
struct TrackingDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Theme Colors
    private let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    
    // Mock Data
    private let sessions: [TrackingSession] = [
        TrackingSession(dateString: "27 Apr 2026 at 12:01 PM", beats: "24.9", time: "00:02", distance: "0.56 KM", pulseEarned: "0"),
        TrackingSession(dateString: "23 Apr 2026 at 6:13 PM", beats: "0.0", time: "00:00", distance: "0.00 KM", pulseEarned: "0"),
        TrackingSession(dateString: "23 Apr 2026 at 6:13 PM", beats: "0.0", time: "00:00", distance: "0.00 KM", pulseEarned: "0"),
        TrackingSession(dateString: "12 Apr 2026 at 1:44 AM", beats: "0.0", time: "00:00", distance: "0.00 KM", pulseEarned: "0")
    ]
    
    var body: some View {
        ZStack {
            themeBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                sessionList
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Main View Subcomponents
    
    /// Custom top navigation bar with a back button and centered title
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44, alignment: .leading)
            }
            
            Text("Tracking Details")
                .font(.custom("ClashDisplay-Bold", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Empty spacer to balance out the chevron.left and keep text perfectly centered
            Spacer().frame(width: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    /// Scrollable list of tracking cards
    private var sessionList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(sessions) { session in
                    TrackingSessionCard(session: session)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Keeps bottom item from hiding under tab bar
        }
    }
}

// MARK: - 3. Individual Expandable Card
struct TrackingSessionCard: View {
    let session: TrackingSession
    @State private var isExpanded: Bool
    
    // Constants for Styling
    private let cardBg = Color(red: 0.08, green: 0.1, blue: 0.08)
    private let strokeColor = Color.white.opacity(0.1)
    private let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    
    init(session: TrackingSession) {
        self.session = session
        _isExpanded = State(initialValue: session.initiallyExpanded)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerRow
            statsRow
            
            if isExpanded {
                pulseEarnedRow
            }
        }
        .padding(16) // Combined vertical and horizontal padding
        .background(cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
    
    // MARK: - Card Subcomponents
    
    /// Tappable header containing the Date and the Expand/Collapse chevron
    private var headerRow: some View {
        HStack {
            Text(session.dateString)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .contentShape(Rectangle()) // Ensures the empty space between text and icon is tappable
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
    
    /// The 3 columns of stats (Beats, Time, Distance)
    private var statsRow: some View {
        HStack(spacing: 10) {
            StatBox(title: "Beats", value: session.beats, icon: "beats")
            StatBox(title: "Time", value: session.time)
            StatBox(title: "Distance", value: session.distance)
        }
    }
    
    /// Expandable row showing Pulse points
    private var pulseEarnedRow: some View {
        HStack {
            Text("Pulse Earned")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 6) {
                Text(session.pulseEarned)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeGreen)
                
                Image("Puls")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(themeGreen)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - 4. Small Stat Box UI
struct StatBox: View {
    let title: String
    let value: String
    var icon: String? = nil
    
    private let boxBg = Color.white.opacity(0.05)
    private let strokeColor = Color.white.opacity(0.1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            HStack(spacing: 4) {
                if let iconName = icon {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                }
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Forces boxes to distribute width evenly
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(boxBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor, lineWidth: 1)
        )
    }
}
