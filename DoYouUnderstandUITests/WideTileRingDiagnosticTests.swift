import XCTest

/// Diagnostic-only: checks the ring's now-proportional (width-based) outset
/// on a WIDE tile (a full-width Settings row) to compare against the
/// narrower gender chip already checked in `RingSyncDiagnosticTests`.
final class WideTileRingDiagnosticTests: XCTestCase {

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
    func testSelectedLanguageRowMidPress() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["dashboardSettingsButton"].tap()
        app.staticTexts["Language"].tap()

        let englishRow = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "English")).firstMatch
        XCTAssertTrue(englishRow.waitForExistence(timeout: 2))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            shot(app, name: "WideLanguageRow_MidPress_RingShouldBeMoreStretchedThanNarrowChip")
        }
        englishRow.press(forDuration: 1.2)
    }
}
