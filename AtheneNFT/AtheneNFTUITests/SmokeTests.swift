import XCTest

/// Sandbox smoke suite: launches the real app in the simulator and drives every
/// tab plus the share/wallet and search flows.
final class SmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testHomeFeedRendersOnLaunch() {
        XCTAssertTrue(app.staticTexts["Home Feed"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Slango"].waitForExistence(timeout: 10),
                      "first mock post should be visible")
    }

    func testDiscoverTabShowsCategories() {
        app.staticTexts["Discover"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Featured Categories"].waitForExistence(timeout: 10))
    }

    func testNotificationsTabLoadsFromService() {
        app.staticTexts["Notifications"].firstMatch.tap()
        // Rows arrive after the mock latency; "Today" section header proves the
        // service-driven list rendered.
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 10))
    }

    func testProfileTabShowsUser() {
        app.staticTexts["Me"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["ben_parker53"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Followers"].waitForExistence(timeout: 10))
    }

    func testShareButtonOpensWalletSheet() {
        app.staticTexts["Share"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Select a Wallet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["MetaMask Mobile"].exists)

        // "Show More Options" must reveal the remaining wallets (was a dead button).
        // SwiftUI exposes Button labels as buttons, not static texts.
        let showMore = app.buttons["Show More Options"]
        XCTAssertTrue(showMore.waitForExistence(timeout: 5))
        showMore.tap()
        // Wallet row labels surface as static texts (like "MetaMask Mobile" above)
        XCTAssertTrue(app.staticTexts["Coinbase Wallet"].waitForExistence(timeout: 5))
    }

    func testDiscoverSearchFlow() {
        app.staticTexts["Discover"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Search NFTs, collections, artists..."].waitForExistence(timeout: 10))
        app.staticTexts["Search NFTs, collections, artists..."].tap()

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("Hazy")

        // Submit and expect either results or the no-results state — both prove
        // the search pipeline ran.
        app.keyboards.buttons["return"].tap()
        let gotResults = app.staticTexts["The Hazy Maze"].waitForExistence(timeout: 10)
        let gotEmptyState = app.staticTexts["No results found"].exists
        XCTAssertTrue(gotResults || gotEmptyState)

        app.buttons["Done"].tap()
    }

    func testAllTabsSurviveRoundTrip() {
        // Walk every tab and land back Home — the app must never crash.
        for label in ["Discover", "Notifications", "Me", "Home"] {
            app.staticTexts[label].firstMatch.tap()
        }
        XCTAssertTrue(app.staticTexts["Home Feed"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.state, .runningForeground)
    }
}
