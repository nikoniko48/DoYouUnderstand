import XCTest

/// Visual verification only - screenshots the app-wide "enlarge a little for
/// iPad" pass (`Theme.wideScale`, bumped `LiquidGlassCTAButtonStyle` padding,
/// taller Input textfield) across onboarding and the main screens. Not part
/// of the smoke-test suite - there's nothing to assert positionally here (the
/// whole point was reverting the two-column layout back to a plain, bigger,
/// single-column one), so this exists purely to produce screenshots for
/// manual/visual review.
final class IPadWideScaleVisualCheckTests: XCTestCase {

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
    func testOnboardingScreensLookGoodOniPad() throws {
        let app = XCUIApplication()
        app.launch()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 9))
        shot(app, name: "Onboarding_Greeting")
        getStartedButton.tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        shot(app, name: "Onboarding_Name")
        nameField.tap()
        nameField.typeText("Ada")
        app.buttons["Continue"].tap()

        let ageSlider = app.sliders.firstMatch
        XCTAssertTrue(ageSlider.waitForExistence(timeout: 2))
        ageSlider.adjust(toNormalizedSliderPosition: 0.3)
        shot(app, name: "Onboarding_AgeGender")
        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        genderChip.tap()
        app.buttons["Continue"].tap()

        let darkThemeCard = app.staticTexts["Dark"]
        XCTAssertTrue(darkThemeCard.waitForExistence(timeout: 2))
        shot(app, name: "Onboarding_Theme")
    }

    @MainActor
    func testMainScreensLookGoodOniPad() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
        shot(app, name: "Dashboard")

        app.buttons["newAnalysisButton"].tap()
        XCTAssertTrue(app.staticTexts["Reply"].waitForExistence(timeout: 2))
        shot(app, name: "Input")

        app.buttons["backButton"].tap()
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))

        let replySnippet = app.staticTexts["Just to clarify, we need that finalized by this evening or we might miss the window."]
        XCTAssertTrue(replySnippet.waitForExistence(timeout: 5))
        replySnippet.tap()
        XCTAssertTrue(app.staticTexts["ORIGINAL TONE DETECTED"].waitForExistence(timeout: 5))
        shot(app, name: "Reply")

        app.buttons["backButton"].tap()
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))

        let refineSnippet = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Hey, sorry to bother you again")
        ).firstMatch
        for _ in 0..<6 {
            if refineSnippet.exists { break }
            app.swipeUp()
        }
        XCTAssertTrue(refineSnippet.waitForExistence(timeout: 5))
        refineSnippet.tap()
        XCTAssertTrue(app.staticTexts["YOUR DRAFT"].waitForExistence(timeout: 5))
        shot(app, name: "Refine")
    }
}
