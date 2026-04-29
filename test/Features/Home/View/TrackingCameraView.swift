import SwiftUI
import AVFoundation
internal import Combine

// MARK: - Main Camera View
struct TrackingCameraView: View {
    var onStopTracking: () -> Void
    var onHidePreview: () -> Void // Kept for compatibility with HomeView
    
    @StateObject private var cameraManager = CameraManager()
    
    // 🛠️ NEW: State to control if the screen is blacked out
    @State private var isPreviewHidden = false
    
    var body: some View {
        ZStack {
            // Base black background
            Color.black.ignoresSafeArea()
            
            // Camera Feed
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
                // 🛠️ THE FIX: Hides the feed (leaving just the black background) without killing the camera
                .opacity(isPreviewHidden ? 0 : 1)
            
            // Overlay Buttons
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    // Hide/Show Preview Button
                    Button(action: {
                        // 🛠️ Toggles the black screen instead of dismissing the view!
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPreviewHidden.toggle()
                        }
                    }) {
                        // Dynamically changes text based on state
                        Text(isPreviewHidden ? "Show Preview" : "Hide Preview")
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    
                    // Stop Tracking Button (Red Theme)
                    Button(action: {
                        onStopTracking() // This still fully stops tracking and dismisses the screen
                    }) {
                        Text("Stop Tracking")
                            .font(.custom("ClashDisplay-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.1, blue: 0.1),
                                        Color(red: 0.8, green: 0.2, blue: 0.2),
                                        Color(red: 0.6, green: 0.1, blue: 0.1)
                                    ]),
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(red: 0.9, green: 0.3, blue: 0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStart()
        }
        .onDisappear {
            cameraManager.stop()
        }
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
