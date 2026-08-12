import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @StateObject private var camera = CameraModel()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                ZStack {
                    CameraPreview(camera: camera)
                        .ignoresSafeArea()

                    VStack {
                        HStack {
                            Button {
                                isPresented = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding()
                            }

                            Spacer()
                        }

                        Spacer()
                    }
                }

                HStack {
                    Button {
                        camera.capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)

                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 75, height: 75)
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(Color.black)
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onChange(of: camera.capturedImage) { oldImage, newImage in
            if let image = newImage {
                selectedImage = image
                isPresented = false
            }
        }
        .alert("Camera Access Needed", isPresented: $camera.alert) {
            Button("OK", role: .cancel) { isPresented = false }
        } message: {
            Text("Enable camera access for AtheneNFT in Settings to take photos.")
        }
        .alert("Camera Error", isPresented: Binding(
            get: { camera.errorMessage != nil },
            set: { if !$0 { camera.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(camera.errorMessage ?? "")
        }
    }
}

@MainActor
class CameraModel: NSObject, ObservableObject {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?
    @Published var errorMessage: String?

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                Task { @MainActor [weak self] in
                    self?.setUp()
                }
            }
        case .denied, .restricted:
            alert = true
        default:
            return
        }
    }

    func setUp() {
        Task {
            do {
                try await configureSession()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    nonisolated func configureSession() async throws {
        let session = AVCaptureSession()
        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw NSError(domain: "CameraError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera not available"])
        }

        let input = try AVCaptureDeviceInput(device: device)
        let output = AVCapturePhotoOutput()

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
        // startRunning blocks, so it stays off the main actor; publish the
        // configured session afterward so the preview layer can attach to it.
        session.startRunning()

        await MainActor.run {
            self.session = session
            self.output = output
        }
    }

    func capturePhoto() {
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            Task { @MainActor in
                self.errorMessage = "Photo capture failed: \(error.localizedDescription)"
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            Task { @MainActor in
                self.errorMessage = "Photo capture failed: no image data was produced."
            }
            return
        }

        Task { @MainActor in
            self.capturedImage = UIImage(data: imageData)
            self.isTaken = true
            self.session.stopRunning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    final class PreviewView: UIView {
        // Backing the view with AVCaptureVideoPreviewLayer guarantees the cast.
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = camera.session
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // The model swaps in the configured session after async setup; reattach
        // so the preview shows the live feed instead of the initial empty session.
        if uiView.previewLayer.session !== camera.session {
            uiView.previewLayer.session = camera.session
        }
    }
}
