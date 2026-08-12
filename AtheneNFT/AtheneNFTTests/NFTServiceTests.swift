import XCTest
import Combine
@testable import AtheneNFT

@MainActor
final class NFTServiceTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Mock factories

    func testMockNFTsReturnRequestedCount() {
        XCTAssertEqual(NFTService.shared.getMockNFTs(count: 7).count, 7)
        XCTAssertTrue(NFTService.shared.getMockNFTs(count: 0).isEmpty)
    }

    func testMockNFTsAreDeterministic() {
        let first = NFTService.shared.getMockNFTs(count: 5)
        let second = NFTService.shared.getMockNFTs(count: 5)
        XCTAssertEqual(first.map(\.id), second.map(\.id))
        XCTAssertEqual(first.map(\.price), second.map(\.price))
        XCTAssertEqual(first.map(\.likeCount), second.map(\.likeCount))
    }

    func testMockNFTsUseBundledAssetNames() {
        for nft in NFTService.shared.getMockNFTs(count: 10) {
            XCTAssertTrue(NFTService.mockAssetNames.contains(nft.imageURL),
                          "mock imageURL should be a bundled asset name, got \(nft.imageURL)")
        }
    }

    func testMockNotificationsSortedNewestFirst() {
        let notifications = NFTService.shared.getMockNotifications(count: 8)
        XCTAssertEqual(notifications.count, 8)
        for pair in zip(notifications, notifications.dropFirst()) {
            XCTAssertGreaterThanOrEqual(pair.0.timestamp, pair.1.timestamp)
        }
    }

    func testFollowNotificationsHaveNoNFT() {
        let notifications = NFTService.shared.getMockNotifications(count: 16)
        for notification in notifications where notification.type == .follow {
            XCTAssertNil(notification.nft)
        }
    }

    // MARK: - shareNFT

    private func makeNFT(title: String) -> NFT {
        NFT(
            id: "abc123", title: title, description: "D", imageURL: "New", price: 1.0,
            creator: NFTService.shared.getMockUser(), createdAt: Date(),
            blockchain: .ethereum, contract: nil, tokenId: nil
        )
    }

    func testShareURLContainsID() throws {
        let url = try XCTUnwrap(NFTService.shared.shareNFT(nft: makeNFT(title: "Simple")))
        XCTAssertTrue(url.path.contains("abc123"))
    }

    func testShareURLEncodesSpecialCharacters() throws {
        let url = try XCTUnwrap(NFTService.shared.shareNFT(nft: makeNFT(title: "Cats & Dogs?")))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let titleItem = components.queryItems?.first { $0.name == "title" }
        XCTAssertEqual(titleItem?.value, "Cats & Dogs?", "round-trip through URLComponents must preserve the title")
        XCTAssertFalse(url.absoluteString.contains(" "), "URL must not contain raw spaces")
    }

    // MARK: - searchNFTs

    func testSearchFiltersByTitle() {
        let expectation = expectation(description: "search")
        NFTService.shared.searchNFTs(query: "Amazing Artwork")
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertFalse(response.items.isEmpty)
                for nft in response.items {
                    XCTAssertTrue(
                        nft.title.localizedCaseInsensitiveContains("Amazing Artwork") ||
                        nft.description.localizedCaseInsensitiveContains("Amazing Artwork") ||
                        nft.creator.displayName.localizedCaseInsensitiveContains("Amazing Artwork")
                    )
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testSearchPaginationOutOfRangeIsEmptyNotCrash() {
        let expectation = expectation(description: "page out of range")
        NFTService.shared.searchNFTs(query: "Amazing", page: 99, pageSize: 20)
            .sink(receiveCompletion: { _ in }, receiveValue: { response in
                XCTAssertTrue(response.items.isEmpty)
                XCTAssertFalse(response.hasMore)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    // MARK: - createNFT validation

    private func assertCreateFails(title: String, description: String, price: Double, image: Data,
                                   file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "createNFT fails")
        NFTService.shared.createNFT(title: title, description: description, price: price,
                                    image: image, blockchain: .ethereum)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    } else {
                        XCTFail("expected failure", file: file, line: line)
                    }
                },
                receiveValue: { _ in XCTFail("expected no value", file: file, line: line) }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testCreateNFTRejectsEmptyTitle() {
        assertCreateFails(title: "", description: "D", price: 1, image: Data([1]))
    }

    func testCreateNFTRejectsEmptyDescription() {
        assertCreateFails(title: "T", description: "", price: 1, image: Data([1]))
    }

    func testCreateNFTRejectsZeroPrice() {
        assertCreateFails(title: "T", description: "D", price: 0, image: Data([1]))
    }

    func testCreateNFTRejectsOversizedImage() {
        let oversized = Data(count: NFTService.maxImageBytes + 1)
        assertCreateFails(title: "T", description: "D", price: 1, image: oversized)
    }

    func testCreateNFTSucceedsWithValidInput() {
        let expectation = expectation(description: "createNFT succeeds")
        NFTService.shared.createNFT(title: "Valid", description: "D", price: 1.5,
                                    image: Data([1, 2, 3]), blockchain: .ethereum)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("unexpected failure: \(error)")
                    }
                },
                receiveValue: { nft in
                    XCTAssertEqual(nft.title, "Valid")
                    XCTAssertEqual(nft.price, 1.5)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 10)
    }
}
