import SwiftUI

struct VehicleDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Updated Form State Variables
    @State private var vehicleType: String = ""
    @State private var driverCategory: String = ""
    @State private var vehicleName: String = ""
    @State private var vehicleBrand: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    
    // Exact Theme Colors
    private let themeBlack = Color(red: 0.04, green: 0.06, blue: 0.04)
    private let themeGreen = Color(red: 0.3, green: 0.75, blue: 0.4)
    private let inputBg = Color(red: 0.08, green: 0.1, blue: 0.08)
    
    // Button styling matching the rest of the app
    private var buttonInnerGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [
            Color(red: 0.05, green: 0.15, blue: 0.1),
            Color(red: 0.15, green: 0.35, blue: 0.25),
            Color(red: 0.05, green: 0.15, blue: 0.1)
        ]), startPoint: .leading, endPoint: .trailing)
    }
    private var buttonBorderColor: Color { Color(red: 0.15, green: 0.35, blue: 0.25) }

    var body: some View {
        ZStack {
            // Screen Background
            themeBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- CUSTOM TOP NAVIGATION BAR ---
                HStack {
                    // Back Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44, alignment: .leading)
                    }
                    
                    // Centered Title
                    Text("Vehicle Details")
                        .font(.custom("ClashDisplay-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Invisible spacer to balance the back button
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // --- SCROLLABLE FORM ---
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Input Fields Section based on your exact text
                        VStack(spacing: 16) {
                            VehicleInputField(title: "Vehicle Type", placeholder: "Select an option", text: $vehicleType, isDropdown: true)
                            VehicleInputField(title: "Driver Category", placeholder: "Select an option", text: $driverCategory, isDropdown: true)
                            VehicleInputField(title: "Vehicle Name", placeholder: "Enter car name", text: $vehicleName, isDropdown: false)
                            VehicleInputField(title: "Vehicle Brand", placeholder: "Enter vehicle name", text: $vehicleBrand, isDropdown: false)
                            VehicleInputField(title: "Model", placeholder: "Enter model name", text: $model, isDropdown: false)
                            VehicleInputField(title: "Year", placeholder: "Enter year", text: $year, isDropdown: false)
                        }
                        
                        // Submit Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Submit")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(buttonInnerGradient)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(buttonBorderColor, lineWidth: 1))
                                .shadow(color: themeGreen.opacity(0.2), radius: 15, x: 0, y: 0)
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 40)
                        
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        
        // 🛠️ THE FIX: Broadcasts the hide/show message globally
        .onAppear {
            NotificationCenter.default.post(name: NSNotification.Name("HideCustomTabBar"), object: nil)
        }
        .onDisappear {
            NotificationCenter.default.post(name: NSNotification.Name("ShowCustomTabBar"), object: nil)
        }
    }
}

// MARK: - Reusable Custom Text Field Component
struct VehicleInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isDropdown: Bool = false
    
    private let inputBg = Color(red: 0.08, green: 0.1, blue: 0.08)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(title)
                .font(.custom("ClashDisplay-Medium", size: 14))
                .foregroundColor(.white)
            
            // Input Box
            HStack {
                if isDropdown {
                    Text(text.isEmpty ? placeholder : text)
                        .font(.custom("ClashDisplay-Medium", size: 16))
                        .foregroundColor(text.isEmpty ? .gray : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                        .font(.custom("ClashDisplay-Medium", size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(inputBg)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}
