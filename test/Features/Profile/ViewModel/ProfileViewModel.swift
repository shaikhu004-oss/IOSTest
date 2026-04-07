import SwiftUI
internal import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service = ProfileService()
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.profile = try await service.fetchProfile()
            print("✅ [ProfileViewModel] Profile loaded for: \(self.profile?.username ?? "")")
        } catch {
            self.errorMessage = "Failed to load profile data."
            print("❌ [ProfileViewModel] Error: \(error)")
        }
        
        isLoading = false
    }
}
