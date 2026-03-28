import SwiftUI

struct ProfileView: View {
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
                } // <--- THIS IS THE BRACKET YOU WERE MISSING!
                
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
                        print("Log out tapped!")
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
                
            }
            .navigationTitle("Profile") // This correctly attaches to the Form now
        }
    }
}

#Preview {
    ProfileView()
}
