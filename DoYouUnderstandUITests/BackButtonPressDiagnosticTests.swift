import XCTest

/// Diagnostic-only: the user reports the back button still isn't a round
/// circle after the `BackButton` fix. The at-rest screenshot from the
/// previous fix looked correct, so this specifically captures the button
/// mid-press (the interactive glass's own press animation might not
/// respect the `Circle()` clip shape faithfully, the same class of bug
/// already found and fixed for `GlassSelectionButtonStyle`).
final class BackButtonPressDiagnosticTests: XCTestCase {

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
    func testBackButtonMidPress() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["dashboardSettingsButton"].tap()
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))

        shot(app, name: "BackButton_AtRest")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            shot(app, name: "BackButton_MidPress")
        }
        backButton.press(forDuration: 1.0)

        // The press-and-release above already completed a tap, navigating
        // back to Dashboard. Go back in through Settings to reach FAQ,
        // in case the shape only distorts in some specific toolbar context.
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
        app.buttons["dashboardSettingsButton"].tap()
        app.staticTexts["FAQ"].tap()
        let faqBackButton = app.buttons["backButton"]
        if faqBackButton.waitForExistence(timeout: 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                shot(app, name: "FAQBackButton_MidPress")
            }
            faqBackButton.press(forDuration: 1.0)
        }
    }
}
