import XCTest

final class OnboardingFlowSmokeTest: XCTestCase {

    @MainActor
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Step 1 - Greeting
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 2))
        getStartedButton.tap()

        // Step 2 - Name
        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Ada")
        app.buttons["Continue"].tap()

        // Step 3 - Age (slider, always valid - just drag it and continue)
        let ageSlider = app.sliders.firstMatch
        XCTAssertTrue(ageSlider.waitForExistence(timeout: 2))
        ageSlider.adjust(toNormalizedSliderPosition: 0.3)
        app.buttons["Continue"].tap()

        // Step 4 - Theme + tone palette (selection only, then manual Continue)
        let darkThemeCard = app.staticTexts["Dark"]
        XCTAssertTrue(darkThemeCard.waitForExistence(timeout: 2))
        darkThemeCard.tap()
        app.staticTexts["Neon"].tap()
        let themeScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        themeScreenshot.lifetime = .keepAlways
        themeScreenshot.name = "OnboardingTheme"
        add(themeScreenshot)
        app.buttons["Continue"].tap()

        // Step 5 - Intro
        let introTitle = app.staticTexts["Here's what we do."]
        XCTAssertTrue(introTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        // Step 6 - Trigger message bubble (tap auto-advances)
        let triggerBubble = app.staticTexts["FROM YOUR BOSS"]
        XCTAssertTrue(triggerBubble.waitForExistence(timeout: 2))
        let triggerScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        triggerScreenshot.lifetime = .keepAlways
        triggerScreenshot.name = "OnboardingTrigger"
        add(triggerScreenshot)
        triggerBubble.tap()

        // Step 7 - Processing (auto-advances after ~3s)
        let processingTitle = app.staticTexts["Calibrating your communication profile..."]
        XCTAssertTrue(processingTitle.waitForExistence(timeout: 2))

        // Step 8 - Stats (wait for the bar/percentage rise animation to settle)
        let statsTitle = app.staticTexts["We've got great news for you."]
        XCTAssertTrue(statsTitle.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.2)
        let statsScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        statsScreenshot.lifetime = .keepAlways
        statsScreenshot.name = "OnboardingStats"
        add(statsScreenshot)
        app.buttons["Continue"].tap()

        // Step 9 - Tactile hold (press and hold until it fills and auto-advances)
        let holdPrompt = app.staticTexts["Hold to become a Text Master"]
        XCTAssertTrue(holdPrompt.waitForExistence(timeout: 2))
        let holdTarget = app.otherElements.firstMatch
        holdTarget.press(forDuration: 1.6)

        // Step 10 - Privacy
        let privacyTitle = app.staticTexts["Your Data is Safe With Us."]
        XCTAssertTrue(privacyTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        // Step 11 - Paywall
        let trialButton = app.buttons["START FREE TRIAL"]
        XCTAssertTrue(trialButton.waitForExistence(timeout: 2))
        let paywallScreenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        paywallScreenshot.lifetime = .keepAlways
        paywallScreenshot.name = "OnboardingPaywall"
        add(paywallScreenshot)
        trialButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
    }
}
