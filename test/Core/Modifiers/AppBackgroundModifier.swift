//
//  AppBackgroundModifier.swift
//  test
//
//  Created by Umar Momin on 06/04/26.
//


// test/Core/Modifiers/AppBackgroundModifier.swift
// test/Core/Modifiers/AppBackgroundModifier.swift
import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Matches the new appBackground perfectly
            Color(red: 0.05, green: 0.06, blue: 0.05)
                .ignoresSafeArea()
            
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
