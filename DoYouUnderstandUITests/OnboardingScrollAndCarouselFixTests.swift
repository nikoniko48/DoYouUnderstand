import XCTest

/// Ad-hoc verification for three onboarding fixes:
/// 1. The Age/Theme steps' scroll-top fade gradient shouldn't cover the
///    step's own title while at rest (unscrolled) - it should only fade in
///    once the content has actually scrolled.
/// 2. The paywall `FeatureCarousel` cards should have no drop shadow (it
///    read as too vibrant/visible on the Light theme).
/// 3. The carousel's auto-advance should slide smoothly (verified visually
///    via a mid-animation screenshot, not asserted programmatically).
/// Not part of the smoke-test suite - produces screenshots for manual
/// review.
final class OnboardingScrollAndCarouselFixTests: XCTestCase {

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
    func testScrollFadeAndCarouselShadow() throws {
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

        // Step 3 - Age. Check the title is fully visible at rest (no fade
        // overlap), then scroll down and check the fade shows up cleanly.
        let ageTitle = app.staticTexts["How old are you?"]
        XCTAssertTrue(ageTitle.waitForExistence(timeout: 2))
        shot(app, name: "AgeStep_AtRest_TitleShouldBeFullyVisible")

        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.3)
        shot(app, name: "AgeStep_Scrolled_FadeShouldAppearAtTop")

        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        genderChip.tap()
        app.buttons["Continue"].tap()

        // Step 4 - Theme. Same at-rest / scrolled check, and pick Light so
        // the carousel shadow check later happens against the Light theme
        // background where it was reported too vibrant.
        let themeTitle = app.staticTexts["Choose your theme."]
        XCTAssertTrue(themeTitle.waitForExistence(timeout: 2))
        shot(app, name: "ThemeStep_AtRest_TitleShouldBeFullyVisible")

        let lightThemeCard = app.staticTexts["Light"]
        XCTAssertTrue(lightThemeCard.waitForExistence(timeout: 2))
        lightThemeCard.tap()

        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.3)
        shot(app, name: "ThemeStep_Scrolled_FadeShouldAppearAtTop")

        app.buttons["Continue"].tap()

        // Step 5 - Intro
        let introTitle = app.staticTexts["Here's what we do."]
        XCTAssertTrue(introTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        // Step 6 - Trigger message bubble (tap auto-advances)
        let triggerBubble = app.staticTexts["FROM YOUR BOSS"]
        XCTAssertTrue(triggerBubble.waitForExistence(timeout: 2))
        triggerBubble.tap()

        // Step 7 - Processing (auto-advances after ~3s)
        let processingTitle = app.staticTexts["Calibrating your communication profile..."]
        XCTAssertTrue(processingTitle.waitForExistence(timeout: 2))

        // Step 8 - Stats
        let statsTitle = app.staticTexts["We've got great news for you."]
        XCTAssertTrue(statsTitle.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.2)
        app.buttons["Continue"].tap()

        // Step 9 - Tactile hold
        let holdPrompt = app.staticTexts["Hold to become a Text Master"]
        XCTAssertTrue(holdPrompt.waitForExistence(timeout: 2))
        let holdTarget = app.otherElements.firstMatch
        holdTarget.press(forDuration: 1.6)

        // Step 10 - Privacy
        let privacyTitle = app.staticTexts["Your Data is Safe With Us."]
        XCTAssertTrue(privacyTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        // Step 11 - Interactive tone demo
        let toneDemoTitle = app.staticTexts["Control any conversation."]
        XCTAssertTrue(toneDemoTitle.waitForExistence(timeout: 2))
        let savagePill = app.buttons["Savage"]
        XCTAssertTrue(savagePill.waitForExistence(timeout: 2))
        savagePill.tap()
        XCTAssertTrue(app.staticTexts["Perfect. I'll do it my way then."].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        // Step 12 - Paywall marketing screen: the carousel. One shot right
        // away (initial resting card), then wait through a full auto-advance
        // cycle (5s) and shoot again mid/post-slide.
        let claimTrialButton = app.buttons["Claim My 3-Day Free Trial"]
        XCTAssertTrue(claimTrialButton.waitForExistence(timeout: 2))
        shot(app, name: "Paywall_Carousel_Light_Initial_ShadowShouldBeGone")

        Thread.sleep(forTimeInterval: 5.3)
        shot(app, name: "Paywall_Carousel_Light_AfterAutoAdvance")

        // Checkout bottom sheet - checking for a reported gap/"stripe"
        // between the sheet's own content and the bottom of the screen.
        claimTrialButton.tap()
        let trialButton = app.buttons["Start Free Trial"]
        XCTAssertTrue(trialButton.waitForExistence(timeout: 2))
        shot(app, name: "Checkout_Light_BottomStripeCheck")
    }
}
