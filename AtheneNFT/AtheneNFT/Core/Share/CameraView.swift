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
    }
}

@MainActor
class CameraModel: NSObject, ObservableObject {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var capturedImage: UIImage?
    
    override init() {
        super.init()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    Task { @MainActor in
                        self.setUp()
                    }
                }
            }
        case .denied:
            self.alert = true
            return
        default:
            return
        }
    }
    
    func setUp() {
        Task {
            do {
                try await configureSession()
            } catch {
                print(error.localizedDescription)
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
        
        await MainActor.run {
            self.session = session
            self.output = output
        }
        
        session.startRunning()
    }
    
    func capturePhoto() {
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        Task { @MainActor in
            self.capturedImage = UIImage(data: imageData)
            self.isTaken = true
            self.session.stopRunning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        let parent = UIView()
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 0).isActive = true
        
        return parent
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
