import SwiftUI

struct ProfileView: View {
    // 1. Bring in the AuthViewModel so we can actually log them out
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // 2. Add a state variable to track if the alert should be visible
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                // SECTION 1: User Profile Header
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Umar Momin")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("@umarmomin")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                // SECTION 2: General Settings
                Section(header: Text("General")) {
                    NavigationLink(destination: Text("Account Settings Coming Soon!")) {
                        Label("Account Info", systemImage: "person.text.rectangle")
                    }
                    
                    NavigationLink(destination: Text("Goals Coming Soon!")) {
                        Label("My Goals", systemImage: "target")
                    }
                }
                
                // SECTION 3: App Preferences
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Notifications Coming Soon!")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Privacy Coming Soon!")) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }
                
                // SECTION 4: Log Out Button
                Section {
                    Button(action: {
                        // 3. Show the alert instead of logging out immediately
                        showingLogoutAlert = true
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
                
            }
            .navigationTitle("Profile")
            
            // 4. Attach the alert modifier to the Form
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                // The "Cancel" button automatically closes the alert and does nothing else
                Button("Cancel", role: .cancel) { }
                
                // The "destructive" role automatically makes the text red on iOS
                Button("Log Out", role: .destructive) {
                    // 5. This is where the actual logout happens!
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Needed for the preview to work
}
