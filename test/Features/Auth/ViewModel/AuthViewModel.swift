import SwiftUI
import GoogleSignIn
import FirebaseAuth
internal import CoreLocation
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    // Connects to your separated network logic
    private let authService = AuthService()
    
    func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }
        
        Task {
            print("📍 [AuthViewModel] Requesting location permission...")
            let _ = await LocationManager.shared.requestLocationPermissionIfNeeded()
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    print("❌ [AuthViewModel] Google Sign-In Error: \(error.localizedDescription)")
                    return
                }
                
                // 1. Extract the ORIGINAL Google ID Token
                guard let user = signInResult?.user,
                      let googleIdToken = user.idToken?.tokenString else { return }
                
                let accessToken = user.accessToken.tokenString
                
                // 2. Local Firebase Handshake (Keeps your app's Firebase state active)
                let credential = GoogleAuthProvider.credential(withIDToken: googleIdToken, accessToken: accessToken)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("⚠️ [AuthViewModel] Firebase Sign-In Error: \(error.localizedDescription)")
                    } else {
                        print("✅ [AuthViewModel] Firebase signed in locally.")
                    }
                }
                
                // 3. SEND THE GOOGLE TOKEN TO THE BACKEND
                // We bypass the Firebase token entirely for the API request
                Task {
                    print("✅ [AuthViewModel] Sending Google ID Token to backend...")
                    await self.verifyToken(idToken: googleIdToken)
                }
            }
        }
    }
    // MARK: - Hand off to Service (THIS IS THE MISSING METHOD)
    private func verifyToken(idToken: String) async {
        do {
            let success = try await authService.verifyWithBackend(idToken: idToken)
            
            if success {
                self.isAuthenticated = true
                print("✅ [AuthViewModel] User is now authenticated and routed to Home.")
            } else {
                print("❌ [AuthViewModel] Verification failed. Check AuthService logs for details.")
            }
            
        } catch {
            print("❌ [AuthViewModel] Critical verification error: \(error.localizedDescription)")
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
        print("ℹ️ [AuthViewModel] App state returned to unauthenticated.")
    }
}
