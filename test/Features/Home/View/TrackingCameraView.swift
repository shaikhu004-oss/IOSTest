import SwiftUI
import AVFoundation
internal import Combine

// MARK: - Main Camera View
struct TrackingCameraView: View {
    var onStopTracking: () -> Void
    var onHidePreview: () -> Void // Kept for compatibility with HomeView
    
    @StateObject private var cameraManager = CameraManager()
    
    // State to control if the screen is blacked out
    @State private var isPreviewHidden = false
    
    var body: some View {
        ZStack {
            // Base black background
            Color.black.ignoresSafeArea()
            
            // Camera Feed
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
                .opacity(isPreviewHidden ? 0 : 1)
            
            // Overlay Bottom Panel
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    // 🛠️ NEW: STATS ROW (Matches your image exactly)
                    HStack(spacing: 12) {
                        statBox(title: "Beats", value: "0.0")
                        statBox(title: "Distance", value: "0.00\nkm", isHighlighted: true)
                        statBox(title: "Time", value: "0 min")
                    }
                    
                    // BUTTONS ROW
                    HStack(spacing: 16) {
                        // Hide/Show Preview Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPreviewHidden.toggle()
                            }
                        }) {
                            Text(isPreviewHidden ? "Show Preview" : "Hide Preview")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.08, green: 0.09, blue: 0.08))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }
                        
                        // End Tracking Button (Solid Red Theme from Image)
                        Button(action: {
                            onStopTracking()
                        }) {
                            Text("End Tracking")
                                .font(.custom("ClashDisplay-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.85, green: 0.05, blue: 0.05)) // Flat Red
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 10) // Bottom clearance for the home indicator
                .background(
                    // Solid dark background for the whole panel
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(red: 0.05, green: 0.06, blue: 0.05))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStart()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
    
    // 🛠️ REUSABLE STAT BOX COMPONENT
    @ViewBuilder
    private func statBox(title: String, value: String, isHighlighted: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("ClashDisplay-Bold", size: 15))
                .foregroundColor(.white)
            
            Text(value)
                .font(.custom("ClashDisplay-Bold", size: 18))
                .foregroundColor(.white)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(red: 0.08, green: 0.09, blue: 0.08)) // Inner card dark background
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                // Slightly brighter border if highlighted (like the Distance box)
                .stroke(Color.white.opacity(isHighlighted ? 0.2 : 0.05), lineWidth: 1)
        )
    }
}

// MARK: - Camera Logic Manager
class CameraManager: ObservableObject {
    @Published var session = AVCaptureSession()
    private var isConfigured = false
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            print("Camera permission denied")
        }
    }
    
    private func setupCamera() {
        guard !isConfigured else {
            start()
            return
        }
        
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }
        
        session.commitConfiguration()
        isConfigured = true
        start()
    }
    
    private func start() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.session.isRunning == false {
                self?.session.startRunning()
            }
        }
    }
    
    func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
        }
    }
}

// MARK: - UIViewRepresentable for Camera Feed
struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // No updates needed dynamically for now
    }
}
