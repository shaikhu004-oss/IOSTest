//
//  FirebaseAuthService.swift
//  test
//
//  Created by Umar Momin on 01/04/26.
//


// New Service: Features/Auth/Service/FirebaseAuthService.swift
import FirebaseAuth
import GoogleSignIn

class FirebaseAuthService {
    func signInWithGoogle(result: GIDSignInResult) async throws -> String {
        let credential = GoogleAuthProvider.credential(
            withIDToken: result.user.idToken?.tokenString ?? "",
            accessToken: result.user.accessToken.tokenString
        )
        
        _ = try await Auth.auth().signIn(with: credential)
        
        // Get the Firebase ID Token
        return try await Auth.auth().currentUser!.getIDToken()
    }
}