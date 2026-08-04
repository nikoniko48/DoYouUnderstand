import XCTest

/// Ad-hoc verification for a batch of visual/interaction fixes:
/// 1. Back buttons are a real, tappable circle (not a stretched pill).
/// 2. Selected glass tiles grow noticeably (and consistently) when held.
/// 3. Dashboard/Age/Theme step cards no longer clip their own shadow on the
///    sides in Light theme.
/// 4. No ScrollView/List in the app shows a scroll indicator.
/// 5. The stats bar chart reads as an actual chart, not a flat blob.
/// 6. The paywall checkout panel sizes to its content (no dead space) and
///    its drag handle sits at the very top.
/// Not part of the smoke-test suite - produces screenshots for manual
/// review.
final class VisualFixesVerificationTests: XCTestCase {

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
    func testDashboardBackButtonAndShadow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        // Light theme is where the native glass shadow is actually visible
        // enough to judge the side-clipping fix.
        app.buttons["dashboardSettingsButton"].tap()
        app.staticTexts["Appearance"].tap()
        let lightRow = app.staticTexts["Light"]
        XCTAssertTrue(lightRow.waitForExistence(timeout: 2))
        lightRow.tap()

        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
        shot(app, name: "ThemeSettings_Light_BackButtonShouldBeCircleAndTappable")
        backButton.tap()

        XCTAssertTrue(app.staticTexts["SETTINGS"].waitForExistence(timeout: 2))
        backButton.tap()

        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
        shot(app, name: "Dashboard_Light_CardShadowShouldNotClipSides")

        // Navigate into a history entry and confirm the back button both
        // looks right and actually navigates back (not just the chevron
        // glyph itself being tappable - tapping near its edge should work).
        let firstCard = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "ago")).firstMatch
        if firstCard.waitForExistence(timeout: 2) {
            firstCard.tap()
            let detailBackButton = app.buttons["backButton"]
            XCTAssertTrue(detailBackButton.waitForExistence(timeout: 3))
            shot(app, name: "Detail_Light_BackButtonShouldBeCircle")
            // Tap near the edge of the button's frame, not dead center, to
            // specifically exercise the enlarged hit target.
            detailBackButton.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: 0.15)).tap()
            XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testOnboardingGrowShadowChartAndCheckout() throws {
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

        // Step 3 - Age/Gender. Press-and-hold a gender chip in the
        // background while screenshotting mid-hold, to check both the
        // grow amount and the side margin (does the grown tile still fit
        // without clipping?).
        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        shot(app, name: "AgeGender_Light_AtRest")

        // `press(forDuration:)` blocks synchronously and must run on the
        // main thread like every other XCUIElement interaction - scheduling
        // the mid-hold screenshot via `DispatchQueue.main.asyncAfter` BEFORE
        // starting the press (rather than firing it from a background
        // thread, which XCTest rejects outright) lets it land while the
        // press is still in flight, since XCTest pumps the run loop during
        // the hold.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            shot(app, name: "AgeGender_Light_ChipHeldShouldGrowVisibly_NoClipping")
        }
        genderChip.press(forDuration: 1.2)

        genderChip.tap()
        app.buttons["Continue"].tap()

        // Step 4 - Theme. Pick Light (needed for the shadow-visibility
        // checks throughout this test), screenshot at rest, then hold a
        // tone palette row.
        let themeTitle = app.staticTexts["Choose your theme."]
        XCTAssertTrue(themeTitle.waitForExistence(timeout: 2))
        let lightThemeCard = app.staticTexts["Light"]
        XCTAssertTrue(lightThemeCard.waitForExistence(timeout: 2))
        lightThemeCard.tap()
        shot(app, name: "Theme_Light_AtRest_NoSideClipping")

        let classicRow = app.buttons["Classic"]
        if classicRow.waitForExistence(timeout: 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                shot(app, name: "Theme_Light_PaletteRowHeldShouldGrowVisibly_NoClipping")
            }
            classicRow.press(forDuration: 1.2)
        }

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

        // Step 8 - Stats. Wait for the bars to finish rising, then
        // screenshot the chart's new look.
        let statsTitle = app.staticTexts["We've got great news for you."]
        XCTAssertTrue(statsTitle.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 2.2)
        shot(app, name: "Stats_Light_ChartShouldLookLikeAChartNotABlob")
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

        // Step 12 - Paywall marketing -> checkout panel
        let claimTrialButton = app.buttons["Claim My 3-Day Free Trial"]
        XCTAssertTrue(claimTrialButton.waitForExistence(timeout: 2))
        claimTrialButton.tap()

        let trialButton = app.buttons["Start Free Trial"]
        XCTAssertTrue(trialButton.waitForExistence(timeout: 2))
        shot(app, name: "Checkout_Light_ShouldFitContent_HandleAtTop_NoDeadSpace")
    }
}
