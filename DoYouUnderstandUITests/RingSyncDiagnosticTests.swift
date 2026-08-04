import XCTest

/// Diagnostic-only: verifies the ring-growth-sync fix specifically on a
/// tile that (a) is already selected (so its ring is actually visible) and
/// (b) sits inside an `.onboardingReveal(...)` ancestor - the exact
/// condition that used to show the tile growing a frame before the ring
/// caught up.
final class RingSyncDiagnosticTests: XCTestCase {

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
    func testSelectedGenderChipMidPress() throws {
        let app = XCUIApplication()
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 9))
        getStartedButton.tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Ada")
        app.buttons["Continue"].tap()

        // Select the chip FIRST so its ring is actually visible, then press
        // it again (still selected) to check the ring grows in sync.
        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        genderChip.tap()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            shot(app, name: "SelectedGenderChip_MidPress_RingShouldMatchTileExactly")
        }
        genderChip.press(forDuration: 1.2)
    }
}
