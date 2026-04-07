//
//  AppBackgroundModifier.swift
//  test
//
//  Created by Umar Momin on 06/04/26.
//


// test/Core/Modifiers/AppBackgroundModifier.swift
import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Your exact background from ProfileView
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.25, blue: 0.15), Color.black]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            // The actual screen content goes on top
            content
        }
    }
}

// Extension to make it easy to type `.applyAppBackground()`
extension View {
    func applyAppBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}