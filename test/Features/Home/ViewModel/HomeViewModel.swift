//
//  HomeViewModel.swift
//  test
//
//  Created by Umar Momin on 25/03/26.
//


// test/Features/Home/ViewModel/HomeViewModel.swift
import SwiftUI
internal import Combine


@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var isTracking: Bool = false
    
    // Holding our stats data here instead of hardcoding it in the View
    @Published var stats: [StatModel] = [
        StatModel(title: "Beats", value: "0", icon: "heart.fill", iconColor: .red),
        StatModel(title: "Time", value: "00:00", icon: "timer", iconColor: .blue),
        StatModel(title: "Distance", value: "0.0", icon: "figure.walk", iconColor: .green),
        StatModel(title: "Pulse", value: "0 bpm", icon: "waveform.path.ecg", iconColor: .purple)
    ]
    
    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            print("Tracking Started!")
        } else {
            print("Tracking Stopped!")
        }
    }
}
