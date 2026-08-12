import XCTest
@testable import AtheneNFT

final class ModelTests: XCTestCase {

    // MARK: - String.avatarInitial

    func testAvatarInitialStripsAtPrefix() {
        XCTAssertEqual("@rayul".avatarInitial, "R")
    }

    func testAvatarInitialPlainUsername() {
        XCTAssertEqual("rayul".avatarInitial, "R")
    }

    func testAvatarInitialEmptyStringFallsBack() {
        XCTAssertEqual("".avatarInitial, "?")
    }

    func testAvatarInitialLoneAtSignFallsBack() {
        XCTAssertEqual("@".avatarInitial, "?")
    }

    // MARK: - User.initials

    private func makeUser(displayName: String) -> User {
        User(id: "1", username: "@test", displayName: displayName, profileImage: "Profile")
    }

    func testInitialsTwoWords() {
        XCTAssertEqual(makeUser(displayName: "Ben Parker").initials, "BP")
    }

    func testInitialsSingleWord() {
        XCTAssertEqual(makeUser(displayName: "Rayul").initials, "RA")
    }

    func testInitialsDoubleSpaceDoesNotProduceEmpty() {
        XCTAssertEqual(makeUser(displayName: "Ben  Parker").initials, "BP")
    }

    // MARK: - User.displayUsername

    func testDisplayUsernameAddsAtWhenMissing() {
        XCTAssertEqual(makeUser(displayName: "X").displayUsername, "@test")
        let plain = User(id: "2", username: "plain", displayName: "X", profileImage: "Profile")
        XCTAssertEqual(plain.displayUsername, "@plain")
    }

    // MARK: - NFT.isNew

    private func makeNFT(createdAt: Date) -> NFT {
        NFT(
            id: "1", title: "T", description: "D", imageURL: "New", price: 1.0,
            creator: makeUser(displayName: "C"), createdAt: createdAt,
            blockchain: .ethereum, contract: nil, tokenId: nil
        )
    }

    func testIsNewWithinSevenDays() {
        XCTAssertTrue(makeNFT(createdAt: Date().addingTimeInterval(-3 * 86400)).isNew)
    }

    func testIsNotNewAfterSevenDays() {
        XCTAssertFalse(makeNFT(createdAt: Date().addingTimeInterval(-8 * 86400)).isNew)
    }

    // MARK: - Notification.message

    func testNotificationMessageUsesDisplayName() {
        let notification = Notification(
            id: "1", type: .like, user: makeUser(displayName: "Ben Parker"),
            nft: nil, timestamp: Date()
        )
        XCTAssertEqual(notification.message, "Ben Parker liked your NFT")
    }

    func testNotificationMessageFallsBackToUsername() {
        let user = User(id: "1", username: "@ghost", displayName: "", profileImage: "Profile")
        let notification = Notification(id: "1", type: .follow, user: user, nft: nil, timestamp: Date())
        XCTAssertEqual(notification.message, "@ghost started following you")
    }

    // MARK: - Safe subscripts

    func testSafeIndexInBounds() {
        XCTAssertEqual([1, 2, 3][safe: 1], 2)
    }

    func testSafeIndexOutOfBounds() {
        XCTAssertNil([1, 2, 3][safe: 9])
    }

    func testSafeRangeClampsToBounds() {
        let slice = [1, 2, 3][safe: 2..<10]
        XCTAssertEqual(Array(slice), [3])
    }

    func testSafeRangeFullyOutOfBoundsIsEmpty() {
        XCTAssertTrue([1, 2, 3][safe: 5..<9].isEmpty)
    }
}
