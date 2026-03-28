//
//  HomeView.swift
//  test
//
//  Created by Umar Momin on 25/03/26.
//


// test/Features/Home/View/HomeView.swift
import SwiftUI

struct HomeView: View {
    // 1. Connect to the ViewModel
    @StateObject private var viewModel = HomeViewModel()
    
    // 2. Accept the tab selection so the profile button works
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // --- THE "BIG BOX" CONTAINER ---
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        StatCard(stat: viewModel.stats[0])
                        StatCard(stat: viewModel.stats[1])
                    }
                    
                    HStack(spacing: 15) {
                        StatCard(stat: viewModel.stats[2])
                        StatCard(stat: viewModel.stats[3])
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // --- START TRACKING BUTTON ---
                Button(action: {
                    viewModel.toggleTracking()
                }) {
                    Text(viewModel.isTracking ? "Stop Tracking" : "Start Tracking")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isTracking ? Color.red : Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        selectedTab = 3 // Navigates to Profile Tab
//                    }) {
//                        Image(systemName: "person.crop.circle")
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                    }
//                }
//            }
        }
    }
}

// --- REUSABLE COMPONENT ---
// Updated to accept the StatModel instead of individual strings
struct StatCard: View {
    var stat: StatModel
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: stat.icon)
                .font(.title)
                .foregroundColor(stat.iconColor)
            
            Text(stat.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(stat.title)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 35)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview {
    HomeView(selectedTab: .constant(1))
}
