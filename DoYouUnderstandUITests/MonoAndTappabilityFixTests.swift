import XCTest

/// Ad-hoc verification for three follow-up fixes:
/// 1. Mono palette leaked color through `Main.secondaryAccent`/`Main.success`
///    (the Reply badge, Language/Privacy Policy row icons) even though every
///    `Tone.*` color correctly went gray - those two now also respect Mono.
/// 2. Mono's tone colors cycled across 3 gray tiers - reduced to exactly 1
///    shared gray for all 16 tones.
/// 3. Several glass-converted rows only had their icon/text glyphs as the
///    tappable area, not the whole row - added `.contentShape(...)`
///    everywhere. This is verified by tapping a row's empty edge (not its
///    text/icon), which would have silently no-opped before the fix.
/// Not part of the smoke-test suite - produces screenshots for manual
/// review and asserts the tap-target regression directly.
final class MonoAndTappabilityFixTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func skipOnboardingToDashboard(_ app: XCUIApplication) {
        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))
    }

    @MainActor
    private func shot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.lifetime = .keepAlways
        attachment.name = name
        add(attachment)
    }

    @MainActor
    func testMonoPaletteIsFullyGrayscale() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()
        skipOnboardingToDashboard(app)

        app.buttons["dashboardSettingsButton"].tap()
        app.staticTexts["Appearance"].tap()

        let monoRow = app.buttons["Mono"]
        XCTAssertTrue(monoRow.waitForExistence(timeout: 2))
        monoRow.tap()
        Thread.sleep(forTimeInterval: 0.3)
        shot(app, name: "Mono_AppearanceScreen")

        app.buttons["backButton"].tap()
        shot(app, name: "Mono_SettingsMainList")

        // Language and Privacy Policy row icons used to stay blue/green
        // under Mono via `Main.secondaryAccent`/`Main.success`.
        app.staticTexts["Language"].tap()
        XCTAssertTrue(app.staticTexts["Default Reply Language"].waitForExistence(timeout: 2))
        shot(app, name: "Mono_LanguageScreen")
        app.buttons["backButton"].tap()

        app.staticTexts["Privacy Policy"].tap()
        XCTAssertTrue(app.staticTexts["Contact"].waitForExistence(timeout: 2))
        shot(app, name: "Mono_PrivacyPolicyScreen")
        app.buttons["backButton"].tap()

        // Back on Dashboard, the Reply badge used to stay blue under Mono.
        app.buttons["backButton"].tap()
        XCTAssertTrue(app.staticTexts["DO YOU\nUNDERSTAND?!"].waitForExistence(timeout: 2))
        shot(app, name: "Mono_Dashboard")
    }

    /// Scrolls the Dashboard's history list and confirms the fixed header
    /// (title + gear/FAQ buttons) is never covered by scrolled-past tiles -
    /// `.scrollClipDisabled()` used to disable ALL clipping (not just the
    /// horizontal clipping it was meant to fix), letting rows render over
    /// the header above the List.
    @MainActor
    func testDashboardScrollDoesNotCoverHeader() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()
        skipOnboardingToDashboard(app)

        shot(app, name: "DashboardScroll_Top")

        app.swipeUp()
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.3)
        shot(app, name: "DashboardScroll_Scrolled")

        // The header title must still exist and be on-screen, not covered.
        XCTAssertTrue(app.staticTexts["DO YOU\nUNDERSTAND?!"].exists)
        XCTAssertTrue(app.buttons["dashboardSettingsButton"].isHittable)
    }

    /// Taps a Settings row's far trailing edge (well past its icon and
    /// text, in what used to be a dead zone with no `.contentShape`) to
    /// confirm the whole glass tile - not just its visible glyphs - is
    /// tappable.
    @MainActor
    func testSettingsRowFullTileIsTappable() throws {
        let app = XCUIApplication()
        app.launch()
        skipOnboardingToDashboard(app)

        app.buttons["dashboardSettingsButton"].tap()

        let appearanceText = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceText.waitForExistence(timeout: 2))
        // The full row is the Button ancestor of this label text.
        let appearanceRow = app.buttons.containing(.staticText, identifier: "Appearance").firstMatch
        XCTAssertTrue(appearanceRow.exists)

        // Tap near the row's trailing edge (past the chevron, in empty
        // glass space) rather than `.tap()` on the label itself.
        appearanceRow.coordinate(withNormalizedOffset: CGVector(dx: 0.96, dy: 0.5)).tap()

        XCTAssertTrue(app.staticTexts["Classic"].waitForExistence(timeout: 2), "Tapping the row's empty trailing edge should still navigate to Appearance settings")
    }
}
