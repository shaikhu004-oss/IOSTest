// test/Features/Auth/ViewModel/AuthViewModel.swift

import SwiftUI
import GoogleSignIn
import FirebaseAuth
internal import CoreLocation
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var showReferralPopup: Bool = false
    @Published var generatedUsername: String = ""
    @Published var onboardingError: String? = nil // 🌟 NEW: Track onboarding errors for the UI
    
    // Inject services
    private let googleService = GoogleAuthService()
    private let firebaseService = FirebaseAuthService()
    private let backendService = AuthService()

    init() {
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        if SecureStorage.shared.getToken() != nil {
            print("✅ [AuthViewModel] Found existing token. Routing to Home.")
            self.isAuthenticated = true
        } else {
            print("ℹ [AuthViewModel] No token found. Routing to Login.")
            self.isAuthenticated = false
        }
    }

    func signInWithGoogle() {
        Task {
            do {
                _ = await LocationManager.shared.requestLocationPermissionIfNeeded()
                
                let googleResult = try await googleService.signIn()
                let firebaseToken = try await firebaseService.signInWithGoogle(result: googleResult)
                
                let result = try await backendService.verifyWithBackend(idToken: firebaseToken)
                
                if result.success {
                    // Save the access token locally
                    if let token = result.token {
                        _ = SecureStorage.shared.saveToken(token)
                        print("✅ [AuthViewModel] Access token saved successfully.")
                    }
                    
                    self.isAuthenticated = result.success
                    
                    if result.onboarding {
                        // 🌟 NEW: Call the asynchronous loop to find a valid username from the backend
                        await findAndSetValidUsername()
                    } else {
                        self.showReferralPopup = false
                        print("✅ [AuthViewModel] Onboarding is false. Navigating to HomeView.")
                    }
                } else {
                    print("❌ [AuthViewModel] Verification failed. Check logs.")
                }
                
            } catch {
                print("❌ Login flow failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Onboarding Submission Logic
    
    /// Call this when the user taps "Next" or "Skip" in the ReferralPopupView
    func submitOnboarding(referralCode: String?) {
        Task {
            do {
                onboardingError = nil
                let success = try await backendService.completeOnboarding(
                    username: self.generatedUsername,
                    referralCode: referralCode
                )
                
                if success {
                    print("✅ [AuthViewModel] Onboarding complete. Closing popup.")
                    withAnimation {
                        self.showReferralPopup = false
                        self.onboardingError = nil
                        // The user is now fully authenticated and onboarded
                    }
                } else {
                    // Show error if the referral code is incorrect or API fails
                    self.onboardingError = "Invalid referral code or request failed. Please try again."
                }
            } catch {
                self.onboardingError = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Username Generation & Validation Logic
    
    // 🌟 UPDATED: Finds the next sequential username without using local storage
    private func findAndSetValidUsername() async {
        var usernameExists = true
        var sequenceCounter = 1 // Start at 1 every time
        var prospectiveUsername = ""
        
        // Loop continues WHILE `usernameExists` is true
        while usernameExists && sequenceCounter < 1000 {
            // Format it as 6 digits with leading zeroes
            prospectiveUsername = String(format: "scout_rider_%06d", sequenceCounter)
            print("⏳ [AuthViewModel] Checking if username exists: \(prospectiveUsername)...")
            
            do {
                usernameExists = try await backendService.checkIfUsernameExists(username: prospectiveUsername)
                
                if usernameExists == false {
                    print("✅ [AuthViewModel] Found available sequence! \(prospectiveUsername)")
                } else {
                    print("⚠️ [AuthViewModel] \(prospectiveUsername) taken, trying next...")
                    sequenceCounter += 1
                }
            } catch {
                print("❌ [AuthViewModel] Error checking username. Proceeding with fallback.")
                break
            }
        }
        
        self.generatedUsername = prospectiveUsername
        self.showReferralPopup = true
        print("✅ [AuthViewModel] Final verified username displayed to user: \(self.generatedUsername)")
    }
    
    // MARK: - Sign Out
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            print("ℹ [AuthViewModel] User signed out of Firebase.")
        } catch {
            print("❌ [AuthViewModel] Error signing out of Firebase: \(error.localizedDescription)")
        }
        
        SecureStorage.shared.deleteToken()
        
        self.isAuthenticated = false
        self.showReferralPopup = false
        self.generatedUsername = ""
        self.onboardingError = nil
        print("ℹ [AuthViewModel] App state returned to unauthenticated and token cleared.")
    }
}
