import SwiftUI
import GoogleSignIn
import FirebaseAuth
internal import CoreLocation
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    // 🌟 State to control the referral popup
    @Published var showReferralPopup: Bool = false
    
    // Inject services
    private let googleService = GoogleAuthService()
    private let firebaseService = FirebaseAuthService()
    private let backendService = AuthService()

    func signInWithGoogle() {
        Task {
            do {
                // 1. Request location (UI/UX step)
                _ = await LocationManager.shared.requestLocationPermissionIfNeeded()
                
                // 2. Step-by-step service calls
                let googleResult = try await googleService.signIn()
                let firebaseToken = try await firebaseService.signInWithGoogle(result: googleResult)
                
                // 3. Verify with your backend (🌟 UPDATED: Now expects a Tuple)
                let result = try await backendService.verifyWithBackend(idToken: firebaseToken)
                
                // 🌟 4. Handle the successful login
                self.isAuthenticated = result.success
                
                if result.success {
                    // 🌟 5. Evaluate the onboarding flag to route the user
                    if result.onboarding {
                        self.showReferralPopup = true // Trigger the popup
                        print("✅ [AuthViewModel] Onboarding is true. Showing referral popup.")
                    } else {
                        self.showReferralPopup = false // Keep popup hidden, go to Home
                        print("✅ [AuthViewModel] Onboarding is false. Navigating directly to HomeView.")
                    }
                } else {
                    print("❌ [AuthViewModel] Verification failed. Check logs.")
                }
                
            } catch {
                print("❌ Login flow failed: \(error.localizedDescription)")
            }
        }
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
        
        self.isAuthenticated = false
        self.showReferralPopup = false // 🌟 Reset popup state on logout
        print("ℹ️ [AuthViewModel] App state returned to unauthenticated.")
    }
}
