import XCTest
import UIKit
@testable import AtheneNFT

@MainActor
final class ShareViewModelTests: XCTestCase {

    private func makeImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }

    private func makeFilledViewModel() -> ShareViewModel {
        let vm = ShareViewModel()
        vm.image = makeImage()
        vm.title = "Test NFT"
        vm.description = "A test description"
        vm.price = "1.5"
        return vm
    }

    // MARK: - Validation

    func testMissingImageProducesError() {
        let vm = makeFilledViewModel()
        vm.image = nil
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please add an image")
        XCTAssertFalse(vm.isUploading)
    }

    func testMissingTitleProducesError() {
        let vm = makeFilledViewModel()
        vm.title = ""
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please give your NFT a title")
        XCTAssertFalse(vm.isUploading)
    }

    func testMissingDescriptionProducesError() {
        let vm = makeFilledViewModel()
        vm.description = ""
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please add a description")
        XCTAssertFalse(vm.isUploading)
    }

    func testNonNumericPriceProducesError() {
        let vm = makeFilledViewModel()
        vm.price = "abc"
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please enter a price greater than 0")
        XCTAssertFalse(vm.isUploading)
    }

    func testZeroPriceProducesError() {
        let vm = makeFilledViewModel()
        vm.price = "0"
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please enter a price greater than 0")
    }

    func testNegativePriceProducesError() {
        let vm = makeFilledViewModel()
        vm.price = "-5"
        vm.createNFT()
        XCTAssertEqual(vm.errorMessage, "Please enter a price greater than 0")
    }

    func testValidInputStartsUpload() {
        let vm = makeFilledViewModel()
        vm.createNFT()
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(vm.isUploading)
        XCTAssertEqual(vm.uploadProgress, 0.0)
    }

    // MARK: - Upload lifecycle

    func testUploadCompletesResetsFormAndStopsTimer() async throws {
        let vm = makeFilledViewModel()
        vm.createNFT()

        // Progress ticks every 0.5s in 0.2 steps, then a settle delay; wait
        // for the whole simulated pipeline to finish.
        let deadline = Date().addingTimeInterval(10)
        while !vm.successfullyCreated && Date() < deadline {
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertTrue(vm.successfullyCreated, "upload should complete within the deadline")
        XCTAssertFalse(vm.isUploading)
        XCTAssertEqual(vm.uploadProgress, 0.0)
        XCTAssertNil(vm.image)
        XCTAssertEqual(vm.title, "")
        XCTAssertEqual(vm.price, "")
    }

    func testProgressNeverExceedsOne() async throws {
        let vm = makeFilledViewModel()
        vm.createNFT()

        var maxObserved = 0.0
        let deadline = Date().addingTimeInterval(10)
        while !vm.successfullyCreated && Date() < deadline {
            maxObserved = max(maxObserved, vm.uploadProgress)
            try await Task.sleep(nanoseconds: 50_000_000)
        }

        XCTAssertLessThanOrEqual(maxObserved, 1.0, "progress must be clamped at 100%")
    }
}
