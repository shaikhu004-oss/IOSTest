//
//  GoogleAuthService.swift
//  test
//
//  Created by Umar Momin on 01/04/26.
//


// New Service: Features/Auth/Service/GoogleAuthService.swift
import GoogleSignIn
import UIKit

class GoogleAuthService {
    @MainActor
    func signIn() async throws -> GIDSignInResult {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Root VC"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                }
            }
        }
    }
}