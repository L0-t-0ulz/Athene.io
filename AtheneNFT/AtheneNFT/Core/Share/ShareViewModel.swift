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
              image.jpegData(compressionQuality: 0.8) != nil else {
            errorMessage = "Please add an image"
            return
        }
        guard !title.isEmpty else {
            errorMessage = "Please give your NFT a title"
            return
        }
        guard !description.isEmpty else {
            errorMessage = "Please add a description"
            return
        }
        guard let priceValue = Double(price), priceValue > 0 else {
            errorMessage = "Please enter a price greater than 0"
            return
        }

        errorMessage = nil
        isUploading = true
        uploadProgress = 0.0

        // Simulated upload progress until the real NFTService.createNFT call is
        // wired up; the cancellable is cleared in completeUpload so the timer
        // stops once the upload finishes.
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                if self.uploadProgress < 1.0 {
                    self.uploadProgress = min(self.uploadProgress + 0.2, 1.0)
                } else {
                    self.completeUpload()
                }
            }
            .store(in: &cancellables)
    }

    private func completeUpload() {
        cancellables.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + MockLatency.uploadSettle) { [weak self] in
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