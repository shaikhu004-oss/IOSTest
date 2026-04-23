// test/Features/Home/ViewModel/HomeViewModel.swift
import Foundation
import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var currentStats: StatModel = .empty
    @Published var userProfile: UserProfile? = nil // 🛠️ Added to hold profile data
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let profileService = ProfileService() // 🛠️ Initialize the Profile Service
    
    // Formatter to send yyyy-MM-dd to the API
    private let apiDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    func toggleTracking() {
        isTracking.toggle()
    }
    
    // 🛠️ MAIN FUNCTION: Calls both separate fetch functions concurrently
    func fetchStats(for range: String, startDate: Date? = nil, endDate: Date? = nil) {
        isLoading = true
        errorMessage = nil
        
        Task {
            // Initiate both network requests concurrently
            async let fetchStatsTask: () = loadStats(for: range, startDate: startDate, endDate: endDate)
            async let fetchProfileTask: () = loadProfile()
            
            // Await both tasks to finish before stopping the loading state
            _ = await (fetchStatsTask, fetchProfileTask)
            
            self.isLoading = false
        }
    }
    
    // 🛠️ SEPARATE FUNCTION 1: Fetch Stats Only
    private func loadStats(for range: String, startDate: Date?, endDate: Date?) async {
        let startStr = startDate != nil ? apiDateFormatter.string(from: startDate!) : nil
        let endStr = endDate != nil ? apiDateFormatter.string(from: endDate!) : nil
        
        do {
            let response = try await StatsService.shared.fetchUserStats(
                range: range,
                startDate: startStr,
                endDate: endStr
            )
            
            self.currentStats = StatModel(
                beats: String(format: "%.1f", response.totalBeats ?? 0.0),
                puls: String(format: "%.2f", response.pulsPoints ?? 0.0),
                time: formatTime(seconds: response.totalTimeTravelled ?? 0),
                distance: String(format: "%.1f", response.totalDistanceKm ?? 0.0)
            )
        } catch {
            print("Failed to fetch stats: \(error)")
            self.errorMessage = "Failed to load stats data"
            self.currentStats = .empty
        }
    }
    
    // 🛠️ SEPARATE FUNCTION 2: Fetch Profile Only
    private func loadProfile() async {
        do {
            self.userProfile = try await profileService.fetchProfile()
            print("✅ Profile loaded for: \(self.userProfile?.username ?? "Unknown")")
        } catch {
            print("Failed to fetch profile: \(error)")
            // Optionally append to errorMessage if you want to alert the user
            if self.errorMessage == nil {
                self.errorMessage = "Failed to load profile data"
            }
        }
    }
    
    // Converts seconds to HH:MM (e.g., 5400s -> 01:30)
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        // %02d ensures it always shows two digits (e.g., 05 instead of 5)
        return String(format: "%02d:%02d", hours, minutes)
    }
}
