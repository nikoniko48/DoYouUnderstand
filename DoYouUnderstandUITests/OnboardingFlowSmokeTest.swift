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

        // Step 3 - Age + gender (slider is always valid, gender needs a pick)
        let ageSlider = app.sliders.firstMatch
        XCTAssertTrue(ageSlider.waitForExistence(timeout: 2))
        ageSlider.adjust(toNormalizedSliderPosition: 0.3)
        let ageGenderShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        ageGenderShot.lifetime = .keepAlways
        ageGenderShot.name = "OnboardingAgeGender"
        add(ageGenderShot)
        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        genderChip.tap()
        app.buttons["Continue"].tap()

        // Step 4 - Theme + tone palette (selection only, then manual Continue)
        let darkThemeCard = app.staticTexts["Dark"]
        XCTAssertTrue(darkThemeCard.waitForExistence(timeout: 2))
        let themeInitialShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        themeInitialShot.lifetime = .keepAlways
        themeInitialShot.name = "OnboardingTheme_Initial"
        add(themeInitialShot)
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

        // Step 9 - Tactile hold. A short tap/press that releases well before
        // the fill duration must NOT advance (it should shrink back instead);
        // only a genuinely sustained hold should.
        let holdPrompt = app.staticTexts["Hold to become a Text Master"]
        XCTAssertTrue(holdPrompt.waitForExistence(timeout: 2))
        let holdTarget = app.otherElements.firstMatch
        holdTarget.press(forDuration: 0.3)
        XCTAssertTrue(holdPrompt.waitForExistence(timeout: 1))

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

        // RevenueCat's test-mode API key swaps the real StoreKit sheet for its
        // own "Test Store Purchase" debug overlay - tap through a simulated
        // successful purchase to let onboarding actually complete.
        let testPurchaseAlert = app.alerts["Test Store Purchase"]
        XCTAssertTrue(testPurchaseAlert.waitForExistence(timeout: 5))
        testPurchaseAlert.buttons["Test valid purchase"].tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSkipOnboardingDebugButton() throws {
        let app = XCUIApplication()
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 2))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
    }
}
