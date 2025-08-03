import Foundation
import SwiftUI
import Combine

@MainActor
class ShareViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var title = ""
    @Published var description = ""
    @Published var price = ""
    @Published var isUploading = false
    @Published var uploadProgress = 0.0
    @Published var errorMessage: String?
    @Published var successfullyCreated = false
    
    private let nftService = NFTService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func createNFT() {
        guard let image = image, 
              let _ = image.jpegData(compressionQuality: 0.8),
              !title.isEmpty,
              let _ = Double(price) else {
            errorMessage = "Please fill all fields and add an image"
            return
        }
        
        isUploading = true
        uploadProgress = 0.0
        
        // Create a timer to simulate upload progress
        // In a real app, you would get this from your upload task
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            
            if self.uploadProgress < 1.0 {
                self.uploadProgress += 0.2
            } else {
                // Upload complete
                self.completeUpload()
            }
        }
        .store(in: &cancellables)
        
        // In a real app, you would call the service like this:
        /*
        nftService.createNFT(
            title: title,
            description: description,
            price: priceValue,
            image: imageData
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isUploading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] nft in
                self?.successfullyCreated = true
            }
        )
        .store(in: &cancellables)
        */
    }
    
    private func completeUpload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isUploading = false
            self?.uploadProgress = 0
            self?.successfullyCreated = true
            self?.resetForm()
        }
    }
    
    func resetForm() {
        image = nil
        title = ""
        description = ""
        price = ""
        errorMessage = nil
    }
}