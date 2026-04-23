//
//  SettingsView.swift
//  test
//
//  Created by Umar Momin on 06/04/26.
//


// test/Features/Settings/View/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Environment property to dismiss the view when hitting the back button
    @Environment(\.dismiss) var dismiss
    
    // State variables for the interactive elements
    @State private var receiveNotifications = true
    @State private var emailNotifications = true
    
    // Theme colors
    let themeBlack = Color(red: 0.08, green: 0.1, blue: 0.08)
    let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // --- CUSTOM HEADER ---
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer icon to keep the title perfectly centered
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                // --- TOP TOGGLES ---
                VStack(spacing: 12) {
                    SettingsToggleRow(title: "Receive Notifications", isOn: $receiveNotifications)
                    SettingsToggleRow(title: "Email Notifications", isOn: $emailNotifications)
                    SettingsValueRow(title: "Language", value: "English")
                }
                .padding(.horizontal, 20)
                
                // --- RECORDING SECTION ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recording")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    SettingsValueRow(title: "Primary Recording", value: "Mobile Camera")
                        .padding(.horizontal, 20)
                }
                .padding(.top, 5)
                
                // --- SUPPORT SECTION ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Support")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        SettingsNavigationRow(title: "Terms and Privacy Policy")
                        SettingsNavigationRow(title: "Help")
                        SettingsNavigationRow(title: "FAQs")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 5)
                
                // --- ACTION BUTTONS ---
                VStack(spacing: 20) {
                    // Log Out Button
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color(red: 0.6, green: 0, blue: 0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    // Delete Account Button
                    NavigationLink(destination: DeleteAccountView()) {
                        // Delete account action
                     Text("Delete Account")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(themeGreen)
                            // Underline to match the screenshot
                            .underline()
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 120)
            }
        }
        // Apply the global background!
        .applyAppBackground()
        // Hide default nav bar since we built a custom one that matches your design
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable Row Components

struct SettingsToggleRow: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                // Custom bright green tint
                .tint(Color(red: 0.3, green: 0.85, blue: 0.4))
        }
        .padding()
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct SettingsValueRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 5) {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct SettingsNavigationRow: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
