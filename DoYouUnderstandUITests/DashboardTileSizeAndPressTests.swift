import XCTest

/// Ad-hoc verification that the Dashboard history List:
/// 1. Shows no scroll indicator.
/// 2. Renders tiles at their original size/position (the List's own frame
///    was widened to make clip-safe room for the interactive glass
///    material's press-and-hold grow, instead of shrinking the tiles via a
///    bigger `listRowInsets`).
/// 3. Doesn't clip a tile's rounded corners while it's actively pressed and
///    held (captured via a background screenshot mid-`press(forDuration:)`).
/// Not part of the smoke-test suite - produces screenshots for manual review.
final class DashboardTileSizeAndPressTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func shot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.lifetime = .keepAlways
        attachment.name = name
        add(attachment)
    }

    @MainActor
    func testDashboardTileSizeNoScrollIndicatorAndPressHold() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        // Resting-state tile size/position.
        shot(app, name: "DashboardTiles_Resting")

        // Swipe then screenshot immediately - if `.scrollIndicators(.hidden)`
        // is working, no indicator bar should ever appear, even mid-scroll.
        app.swipeUp()
        shot(app, name: "DashboardTiles_MidScroll_NoIndicatorExpected")
        app.swipeDown()
        Thread.sleep(forTimeInterval: 0.3)

        // Capture a screenshot from a background queue while the main
        // thread is blocked inside a long-press, to catch the tile mid-grow.
        let firstCard = app.staticTexts["EXPLANATION"].firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 2))

        let pressExpectation = expectation(description: "long press finished")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { [self] in
            shot(app, name: "DashboardTiles_MidPressHold")
        }
        firstCard.press(forDuration: 1.2)
        pressExpectation.fulfill()
        wait(for: [pressExpectation], timeout: 2)

        shot(app, name: "DashboardTiles_AfterPressRelease")
    }
}
