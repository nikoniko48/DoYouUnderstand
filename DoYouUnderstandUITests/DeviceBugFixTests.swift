import XCTest

/// Covers the two fixes from this pass that are actually reproducible on
/// the Simulator: the Name step's TextField auto-focus, and the Input
/// screen's keyboard show/dismiss layout. The other two fixes from the same
/// report - Liquid Glass button hit-testing and the tactile-hold haptics
/// crescendo - are real-device-only concerns (touch-precision and the
/// Taptic Engine don't exist in the Simulator) and can't be verified here.
final class DeviceBugFixTests: XCTestCase {

    @MainActor
    func testNameFieldAutoFocusesWithoutManualTap() throws {
        let app = XCUIApplication()
        app.launch()

        // The greeting screen's ~6.3s decryption intro delays this button's
        // very existence, so it needs a longer timeout than other steps.
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 9))
        getStartedButton.tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))

        // No manual tap on the field anywhere above - if it auto-focused,
        // the software keyboard should appear on its own. The focus
        // request is intentionally delayed ~0.35s past the step's own
        // slide-in transition, so give it a moment to show up.
        XCTAssertTrue(
            app.keyboards.element.waitForExistence(timeout: 2),
            "Keyboard should appear on its own once the Name step's TextField auto-focuses"
        )
    }

    @MainActor
    func testInputScreenLayoutAfterKeyboardDismiss() throws {
        let app = XCUIApplication()
        app.launch()

        // This button exists the whole time but isn't hittable until the
        // greeting screen's decryption intro finishes.
        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["newAnalysisButton"].tap()

        let textField = app.textFields["Paste text or write here..."]
        XCTAssertTrue(textField.waitForExistence(timeout: 2))
        textField.tap()
        textField.typeText("Testing keyboard dismiss layout")

        let keyboardUpShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        keyboardUpShot.lifetime = .keepAlways
        keyboardUpShot.name = "InputScreen_KeyboardUp"
        add(keyboardUpShot)

        // Interactive dismiss via a downward drag, same gesture a user
        // would make to put the keyboard away.
        app.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)

        let keyboardDownShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        keyboardDownShot.lifetime = .keepAlways
        keyboardDownShot.name = "InputScreen_KeyboardDismissed"
        add(keyboardDownShot)

        // The screen's content should still be present and not collapsed -
        // both the analyze button and the type-selection cards should be
        // reachable, not squeezed off-screen.
        XCTAssertTrue(app.staticTexts["WHAT DO YOU NEED?"].exists)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Analyze input'")).firstMatch.exists)
    }
}
