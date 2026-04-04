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
            print("ℹ️ [AuthViewModel] No token found. Routing to Login.")
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
    
    // MARK: - Username Generation & Validation Logic
    
    // 🌟 NEW: Loops until `exists` comes back false from the backend
    private func findAndSetValidUsername() async {
        var usernameExists = true // Start as true so we enter the loop
        var attempts = 0
        var prospectiveUsername = ""
        
        // Loop continues WHILE `usernameExists` is true
        // (Added a safety limit of 50 attempts to prevent endless freezing if backend breaks)
        while usernameExists && attempts < 50 {
            prospectiveUsername = generateNextUsername()
            print("⏳ [AuthViewModel] Checking if username exists: \(prospectiveUsername)...")
            
            do {
                // 🌟 FIX: Call the correctly named service method
                usernameExists = try await backendService.checkIfUsernameExists(username: prospectiveUsername)
                
                if usernameExists == false {
                    print("✅ [AuthViewModel] 'exists' is false! Username is available: \(prospectiveUsername)")
                } else {
                    print("⚠️ [AuthViewModel] 'exists' is true. Username taken, looping again...")
                }
            } catch {
                print("❌ [AuthViewModel] Error checking username. Proceeding with fallback.")
                break // Break loop on network error
            }
            
            attempts += 1
        }
        
        // Once `exists` is false (or loop breaks), show the popup
        self.generatedUsername = prospectiveUsername
        self.showReferralPopup = true
        print("✅ [AuthViewModel] Final verified username displayed to user: \(self.generatedUsername)")
    }
    
    private func generateNextUsername() -> String {
        let key = "scout_rider_index"
        // Get current index from UserDefaults (defaults to 0 if doesn't exist)
        let currentIndex = UserDefaults.standard.integer(forKey: key)
        let nextIndex = currentIndex + 1
        
        // Save the updated index back
        UserDefaults.standard.set(nextIndex, forKey: key)
        
        // Format it as 6 digits with leading zeroes (e.g., 000001)
        return String(format: "scout_rider_%06d", nextIndex)
    }
    
    // MARK: - Sign Out
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            print("ℹ️ [AuthViewModel] User signed out of Firebase.")
        } catch {
            print("❌ [AuthViewModel] Error signing out of Firebase: \(error.localizedDescription)")
        }
        
        SecureStorage.shared.deleteToken()
        
        self.isAuthenticated = false
        self.showReferralPopup = false
        self.generatedUsername = ""
        print("ℹ️ [AuthViewModel] App state returned to unauthenticated and token cleared.")
    }
}
