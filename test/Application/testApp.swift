//
//  testApp.swift
//  test
//
//  Created by Umar Momin on 13/03/26.
//

import SwiftUI

@main
struct testApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
