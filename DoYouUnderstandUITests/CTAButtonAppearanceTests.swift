import XCTest

/// Ad-hoc visual verification for `LiquidGlassCTAButtonStyle`: walks the
/// onboarding funnel once per app theme, capturing the "Continue" button
/// (Theme step) and the paywall's "START FREE TRIAL" button (Finisher step,
/// inside its `ScrollView`) so both can be inspected for the glassmorphism
/// look and for border clipping. Not part of the smoke-test suite - this
/// exists purely to produce screenshots for manual review.
final class CTAButtonAppearanceTests: XCTestCase {

    @MainActor
    func testCTAButtonAppearance_LightTheme() throws {
        try runToPaywall(themeName: "Light", paletteName: "Classic")
    }

    @MainActor
    func testCTAButtonAppearance_DarkTheme() throws {
        try runToPaywall(themeName: "Dark", paletteName: "Neon")
    }

    @MainActor
    private func runToPaywall(themeName: String, paletteName: String) throws {
        let app = XCUIApplication()
        app.launch()

        // The greeting screen's ~6.3s decryption intro delays this button's
        // very existence, so it needs a longer timeout than other steps.
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 9))
        getStartedButton.tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Ada")
        app.buttons["Continue"].tap()

        let ageSlider = app.sliders.firstMatch
        XCTAssertTrue(ageSlider.waitForExistence(timeout: 2))
        ageSlider.adjust(toNormalizedSliderPosition: 0.3)
        app.buttons["Non-Conforming"].tap()
        app.buttons["Continue"].tap()

        let themeCard = app.staticTexts[themeName]
        XCTAssertTrue(themeCard.waitForExistence(timeout: 2))
        themeCard.tap()
        app.staticTexts[paletteName].tap()

        let continueShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        continueShot.lifetime = .keepAlways
        continueShot.name = "ContinueButton_\(themeName)"
        add(continueShot)

        app.buttons["Continue"].tap()

        let introTitle = app.staticTexts["Here's what we do."]
        XCTAssertTrue(introTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        let triggerBubble = app.staticTexts["FROM YOUR BOSS"]
        XCTAssertTrue(triggerBubble.waitForExistence(timeout: 2))
        triggerBubble.tap()

        let processingTitle = app.staticTexts["Calibrating your communication profile..."]
        XCTAssertTrue(processingTitle.waitForExistence(timeout: 2))

        let statsTitle = app.staticTexts["We've got great news for you."]
        XCTAssertTrue(statsTitle.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.2)
        app.buttons["Continue"].tap()

        let holdPrompt = app.staticTexts["Hold to become a Text Master"]
        XCTAssertTrue(holdPrompt.waitForExistence(timeout: 2))
        let holdTarget = app.otherElements.firstMatch
        holdTarget.press(forDuration: 1.6)

        let privacyTitle = app.staticTexts["Your Data is Safe With Us."]
        XCTAssertTrue(privacyTitle.waitForExistence(timeout: 3))
        app.buttons["Continue"].tap()

        let toneDemoTitle = app.staticTexts["Control any conversation."]
        XCTAssertTrue(toneDemoTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        let claimTrialButton = app.buttons["Claim My 3-Day Free Trial"]
        XCTAssertTrue(claimTrialButton.waitForExistence(timeout: 2))
        // The carousel's initial scroll-to-center happens on .onAppear and
        // isn't instantaneous - give it a beat to settle before judging its
        // resting position from a screenshot.
        Thread.sleep(forTimeInterval: 1.2)

        // Full-screen shot of the marketing step (Step 1).
        let marketingShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        marketingShot.lifetime = .keepAlways
        marketingShot.name = "PaywallMarketing_\(themeName)"
        add(marketingShot)

        claimTrialButton.tap()

        // Full-screen shot of the checkout bottom sheet (Step 2), to inspect
        // the pricing-row borders and the "Start Free Trial" CTA.
        let startTrialButton = app.buttons["Start Free Trial"]
        XCTAssertTrue(startTrialButton.waitForExistence(timeout: 2))
        let checkoutShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        checkoutShot.lifetime = .keepAlways
        checkoutShot.name = "PaywallCheckout_\(themeName)"
        add(checkoutShot)
    }

    /// Verifies the app-wide Liquid Glass CTA rollout on the two screens
    /// reachable without a live Gemini call: Settings > Profile (Cancel /
    /// Save Changes) and Settings > Manage Subscription (Subscribe).
    @MainActor
    func testAppWideLiquidGlassButtons() throws {
        let app = XCUIApplication()
        app.launch()

        // This button exists the whole time but isn't hittable until the
        // greeting screen's decryption intro finishes.
        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["dashboardSettingsButton"].tap()

        let profileRow = app.buttons["settingsProfileRow"]
        XCTAssertTrue(profileRow.waitForExistence(timeout: 2))
        profileRow.tap()

        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        // Append rather than assume a starting value - a previous test run
        // on this simulator may already have set a name, and typing
        // something different is what's needed to trigger the unsaved-
        // changes footer (Cancel/Save Changes) regardless of prior state.
        nameField.typeText("X")

        let saveChangesButton = app.buttons["Save Changes"]
        XCTAssertTrue(saveChangesButton.waitForExistence(timeout: 2))
        let profileShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        profileShot.lifetime = .keepAlways
        profileShot.name = "ProfileCancelSaveButtons"
        add(profileShot)

        app.buttons["backButton"].tap()

        let subscriptionRow = app.staticTexts["Subscription"]
        XCTAssertTrue(subscriptionRow.waitForExistence(timeout: 2))
        subscriptionRow.tap()

        // A prior test run on this simulator may have already completed a
        // real RevenueCat sandbox purchase (the onboarding smoke test's
        // "Test valid purchase" step), in which case this screen shows the
        // already-subscribed "Manage on the App Store" row instead of the
        // Subscribe CTA - screenshot whichever state is actually showing.
        let subscribeButton = app.buttons["Subscribe"]
        let manageOnAppStoreButton = app.buttons["Manage on the App Store"]
        XCTAssertTrue(
            subscribeButton.waitForExistence(timeout: 2) || manageOnAppStoreButton.waitForExistence(timeout: 2)
        )
        let subscriptionShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        subscriptionShot.lifetime = .keepAlways
        subscriptionShot.name = "ManageSubscriptionButton"
        add(subscriptionShot)
    }
}
