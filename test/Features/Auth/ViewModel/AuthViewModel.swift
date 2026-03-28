import SwiftUI
import GoogleSignIn
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    func signInWithGoogle() {
        // 1. SwiftUI needs to find the underlying "ViewController" to present the Google popup
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Could not find root view controller")
            return
        }
        
        // 2. Trigger the official Google Sign-In SDK
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            // Handle if the user cancels or if there is no internet
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            // If successful, grab the user's data
            guard let user = signInResult?.user else { return }
            print("Successfully signed in as: \(user.profile?.name ?? "Unknown User")")
            
            // 3. Change the state to move the user to the Home screen
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        // Tell Google to log out, then update our app's screen
        GIDSignIn.sharedInstance.signOut()
        self.isAuthenticated = false
    }
}
