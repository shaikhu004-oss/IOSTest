// test/Features/Home/View/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int
    
    // UI State for the timeframe picker
    @State private var selectedTimeframe = "Daily"
    let timeframes = ["Daily", "Weekly", "Monthly", "Custom"]
    
    // State for Custom Date Range
    @State private var customStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    
    // State for showing the Calendar Sheets
    @State private var showStartCalendar = false
    @State private var showEndCalendar = false
    
    // State for Info Popups
    @State private var showBeatsInfo = false
    @State private var showPulsInfo = false
    
    // State to control the Full Screen Camera
    @State private var showCameraScreen = false
    
    // 🛠️ State for the "Sure to start tracking?" Popup
    @State private var showStartTrackingPopup = false
    @State private var dontShowAgain = false
    
    // 🛠️ Persists the user's choice to hide the popup in the future
    @AppStorage("hideStartTrackingPopup") private var hideStartTrackingPopup = false
    
    // 1. App Background (Deepest greenish-gray)
    let appBackground = Color(red: 0.05, green: 0.06, blue: 0.05)

    // 2. Outer Card Background (Slightly lighter to stand out from background)
    let themeBlack = Color(red: 0.08, green: 0.09, blue: 0.08)

    // 3. Inner Stat Card Background (Lightest gray for depth)
    let cardInnerGray = Color(red: 0.12, green: 0.12, blue: 0.12)

    let themeGreen = Color(red: 0.2, green: 0.85, blue: 0.45)
    let subheadlineGray = Color(red: 0.6, green: 0.6, blue: 0.6)
    let captionGray = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    var buttonInnerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.01, green: 0.4, blue: 0.2),
                Color(red: 0.2, green: 0.85, blue: 0.45),
                Color(red: 0.1, green: 0.4, blue: 0.2)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var buttonBorderColor: Color {
        Color(red: 0.15, green: 0.35, blue: 0.25)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    // MARK: - MAIN BODY
    var body: some View {
        NavigationStack {
            ZStack {
                appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            totalStatsCard
                            uploadStatusCard
                        }
                        .padding(.top, 5)
                    }
                    
                    trackingButton
                }
                
                // --- Info Popups Layered on Top ---
                if showBeatsInfo {
                    infoPopupView(
                        title: "Beats",
                        description: "Beats represent the data points you successfully contribute while tracking. More Beats mean better ranking and more rewards!",
                        isPresented: $showBeatsInfo
                    )
                    .zIndex(2)
                }
                
                if showPulsInfo {
                    infoPopupView(
                        title: "$PULS",
                        description: "$PULS is the utility token of the PathPulse ecosystem. You earn $PULS based on your Beats and can use it for exclusive features.",
                        isPresented: $showPulsInfo
                    )
                    .zIndex(2)
                }
                
                // 🛠️ Exact Start Tracking Confirmation Popup Overlay
                if showStartTrackingPopup {
                    startTrackingPopupView
                        .zIndex(3)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchStats(for: selectedTimeframe, startDate: customStartDate, endDate: customEndDate)
            }
            .sheet(isPresented: $showStartCalendar) {
                startCalendarSheet
            }
            .sheet(isPresented: $showEndCalendar) {
                endCalendarSheet
            }
            .fullScreenCover(isPresented: $showCameraScreen) {
                TrackingCameraView(
                    onStopTracking: {
                        viewModel.toggleTracking()
                        showCameraScreen = false
                    },
                    onHidePreview: {
                        showCameraScreen = false
                    }
                )
            }
        }
    }
    
    // 🛠️ EXACT UI POPUP FROM YOUR IMAGE
    private var startTrackingPopupView: some View {
        ZStack {
            // Dark Overlay Background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { showStartTrackingPopup = false }
                }
            
            // Popup Card
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text("Ready to start tracking?")
                    .font(.custom("ClashDisplay-Bold", size: 22))
                    .foregroundColor(.white)
                
                // Subtitle
                Text("Starting a new journey will begin\ntracking your route and detecting road\nhazards.")
                        .font(.custom("ClashDisplay-Medium", size: 14))
                    .foregroundColor(subheadlineGray)
                    .lineSpacing(4)
                
                // Checkbox: "Don't show this message again"
                Button(action: {
                    dontShowAgain.toggle()
                }) {
                    HStack(spacing: 12) {
                        // Custom Checkbox Match
                        ZStack {
                            if dontShowAgain {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(themeGreen)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(subheadlineGray, lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text("Don't show this message again")
                            .font(.custom("ClashDisplay-Medium", size: 14))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 4)
                
                // Buttons: Cancel & Start
                HStack(spacing: 24) {
                    Spacer() // Pushes buttons to the right
                    
                    // Cancel Button
                    Button(action: {
                        withAnimation(.spring()) { showStartTrackingPopup = false }
                    }) {
                        Text("Cancel")
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    
                    // Start Button
                    Button(action: {
                        // Save the user's preference if they checked the box
                        if dontShowAgain {
                            hideStartTrackingPopup = true
                        }
                        
                        withAnimation(.spring()) { showStartTrackingPopup = false }
                        
                        // Start tracking and open camera
                        viewModel.toggleTracking()
                        showCameraScreen = true
                    }) {
                        Text("Start")
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(themeGreen)
                    }
                }
                .padding(.top, 10)
            }
            .padding(24)
            .background(themeBlack)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private func infoPopupView(title: String, description: String, isPresented: Binding<Bool>) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) { isPresented.wrappedValue = false }
                }
            
            VStack(spacing: 16) {
                HStack(){
                    Text(title)
                        .font(.custom("ClashDisplay-Bold", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) { isPresented.wrappedValue = false }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(subheadlineGray)
                            .padding(8)
                    }
                }
                Text(description)
                    .font(.custom("ClashDisplay-Medium", size: 14))
                    .foregroundColor(subheadlineGray)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
            }
            .padding(24)
            .background(themeBlack)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - SUBVIEWS
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Home")
                .font(.custom("ClashDisplay-Bold", size: 28))
                .foregroundColor(.white)
            
            Spacer()
            
            // PULS Pill
            HStack(spacing: 4) {
               Image("Puls")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(String(format: "%.0f", viewModel.userProfile?.pulsePoints ?? 0.0))
                                    .font(.custom("ClashDisplay-Bold", size: 14))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8).padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
            // Bell Icon
            Button(action: { }) {
                Image(systemName: "bell")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(11)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .padding(.leading, 5)
        }
        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 20)
    }
    
    private var totalStatsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            HStack(spacing: 6) {
                Text("Your Total  Stats")
                    .font(.custom("ClashDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                Spacer()
            }
            
            timeframePickerView
            customDateInputsView
            statsGridView
        }
            .padding(20)
            .background(themeBlack)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
             .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            .padding(.horizontal, 20)
    }
    
    private var timeframePickerView: some View {
        HStack(spacing: 10) {
            ForEach(timeframes, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                        viewModel.fetchStats(for: timeframe, startDate: customStartDate, endDate: customEndDate)
                    }
                }) {
                    Text(timeframe)
                        .font(.custom(selectedTimeframe == timeframe ? "ClashDisplay-Semibold" : "ClashDisplay-Medium", size: 14))
                        .foregroundColor(selectedTimeframe == timeframe ? .black : subheadlineGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedTimeframe == timeframe
                                ? Color.white
                                : Color(red: 0.07, green: 0.07, blue: 0.07)
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.05), lineWidth: 1))
                        .shadow(color: selectedTimeframe == timeframe ? Color.black.opacity(0.15) : Color.clear, radius: 2, x: 0, y: 1)
                }
            }
        }
    }
    
    @ViewBuilder
    private var customDateInputsView: some View {
        if selectedTimeframe == "Custom" {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Start Date").font(.custom("ClashDisplay-Medium", size: 12)).foregroundColor(subheadlineGray)
                    Button(action: { showStartCalendar = true }) {
                        Text(dateFormatter.string(from: customStartDate))
                            .font(.custom("ClashDisplay-Semibold", size: 14)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(cardInnerGray).cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("End Date").font(.custom("ClashDisplay-Medium", size: 12)).foregroundColor(subheadlineGray)
                    Button(action: { showEndCalendar = true }) {
                        Text(dateFormatter.string(from: customEndDate))
                            .font(.custom("ClashDisplay-Semibold", size: 14)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(cardInnerGray).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
                    }
                }
            }
            .padding(.top, 4)
            .onChange(of: customStartDate) { _ in
                viewModel.fetchStats(for: "Custom", startDate: customStartDate, endDate: customEndDate)
            }
            .onChange(of: customEndDate) { _ in
                viewModel.fetchStats(for: "Custom", startDate: customStartDate, endDate: customEndDate)
            }
        }
    }
    
    private var statsGridView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PrimaryStatCard(title: "Beats", value: viewModel.currentStats.beats, iconName: "beats", isSystemImage: false, iconColor: .blue, bg: cardInnerGray, subheadlineColor: subheadlineGray,
                                onInfoTap: {
                    withAnimation(.spring()) { showBeatsInfo = true }
                })
                PrimaryStatCard(title: "$PULS", value: viewModel.currentStats.puls, iconName: "Puls", isSystemImage: false, iconColor: themeGreen, bg: cardInnerGray, subheadlineColor: subheadlineGray,onInfoTap: {
                    withAnimation(.spring()) { showPulsInfo = true }
                })
            }
            
            HStack(spacing: 12) {
                SecondaryStatCard(title: "Time", value: viewModel.currentStats.time, unit: "Hours", themeGreen: themeGreen, bg: cardInnerGray, subheadlineColor: subheadlineGray)
                SecondaryStatCard(title: "Distance", value: viewModel.currentStats.distance, unit: "Kilometers", themeGreen: themeGreen, bg: cardInnerGray, subheadlineColor: subheadlineGray)
            }
        }
    }
    
    private var uploadStatusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .padding(8)
                .background(Circle().fill(themeGreen))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Upload Detections (0), Trips (0)")
                    .font(.custom("ClashDisplay-Semibold", size: 14))
                    .foregroundColor(.white)
                Text("0 trip(s), 0 sequence(s) ready")
                    .font(.custom("ClashDisplay-Regular", size: 12))
                    .foregroundColor(captionGray)
            }
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeGreen)
        }
            .padding(16)
            .background(themeBlack)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
            .padding(.horizontal, 20)
    }
    
    private var trackingButton: some View {
        Button(action: {
            if viewModel.isTracking {
                viewModel.toggleTracking() // Stop Tracking instantly if already tracking
            } else {
                // 🛠️ Check if the user previously clicked "Don't show this message again"
                if hideStartTrackingPopup {
                    // Skip popup, go straight to tracking/camera
                    viewModel.toggleTracking()
                    showCameraScreen = true
                } else {
                    // Show the popup
                    withAnimation(.spring()) {
                        showStartTrackingPopup = true
                    }
                }
            }
        }) {
            Text(viewModel.isTracking ? "Stop Tracking" : "Start Tracking")
                .font(.custom("ClashDisplay-Bold", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(buttonInnerGradient).clipShape(Capsule())
                .overlay(Capsule().stroke(buttonBorderColor, lineWidth: 1))
                .shadow(color: themeGreen.opacity(viewModel.isTracking ? 0 : 0.2), radius: 15, x: 0, y: 1)
        }
        .padding(.horizontal, 20).padding(.bottom, 80).padding(.top, 10)
    }
    
    private var startCalendarSheet: some View {
        NavigationStack {
            DatePicker("Select Date", selection: $customStartDate, in: ...customEndDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(themeGreen)
                .padding()
                .navigationTitle("Select Start Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showStartCalendar = false }
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(themeGreen)
                    }
                }
        }
        .presentationDetents([.medium])
    }
    
    private var endCalendarSheet: some View {
        NavigationStack {
            DatePicker("Select Date", selection: $customEndDate, in: customStartDate...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(themeGreen)
                .padding()
                .navigationTitle("Select End Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showEndCalendar = false }
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(themeGreen)
                    }
                }
        }
        .presentationDetents([.medium])
    }
}

// 🛠️ PURE VERTICAL STAT CARDS 🛠️

struct PrimaryStatCard: View {
    var title: String
    var value: String
    var iconName: String
    var isSystemImage: Bool
    var iconColor: Color
    var bg: Color
    var subheadlineColor: Color
    var onInfoTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 6) {
                Text(title)
                    .font(.custom("ClashDisplay-Bold", size: 18))
                    .foregroundColor(.white)
                
                Button(action: {
                    onInfoTap?()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
            }
            
            Text(value)
                .font(.custom("ClashDisplay-Bold", size: 18))
                .foregroundColor(.white)
            
            if isSystemImage {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            } else {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
struct SecondaryStatCard: View {
    var title: String
    var value: String
    var unit: String
    var themeGreen: Color
    var bg: Color
    var subheadlineColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(title)
                .font(.custom("ClashDisplay-Bold", size: 18))
                .foregroundColor(.white)
            
            Text(value)
                .font(.custom("ClashDisplay-Bold", size: 18))
                .foregroundColor(.white)
            
            Text(unit)
                .font(.custom("ClashDisplay-Medium", size: 15))
                .foregroundColor(themeGreen)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

#Preview {
    HomeView(selectedTab: .constant(1))
        .preferredColorScheme(.dark)
}
