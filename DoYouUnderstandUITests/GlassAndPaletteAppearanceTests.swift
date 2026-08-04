import XCTest

/// Ad-hoc visual verification for three fixes:
/// 1. Every tone palette's colors were tuned by eye against a dark
///    background and never checked against Light theme's near-white one -
///    measuring found most were badly under WCAG's readability minimum
///    there. `TonePaletteChoice.color(for:)` now darkens (preserving hue)
///    whenever the active theme's own background needs it.
/// 2. Mono specifically was redesigned from 16 near-identical grays to 3
///    distinct, theme-aware tiers.
/// 3. FAQ, Settings, and all of its sub-screens' tiles (plus the Dashboard's
///    floating + button) now use real Liquid Glass instead of a flat
///    card-surface + hand-drawn border.
/// Not part of the smoke-test suite - this exists purely to produce
/// screenshots for manual review.
final class GlassAndPaletteAppearanceTests: XCTestCase {

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

    /// Switches to Light app theme, then screenshots every tone palette
    /// against it - the exact combination that was unreadable before.
    @MainActor
    func testTonePaletteReadabilityInLightTheme() throws {
        let app = XCUIApplication()
        app.launch()
        skipOnboardingToDashboard(app)

        app.buttons["dashboardSettingsButton"].tap()

        let appearanceRow = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceRow.waitForExistence(timeout: 2))
        appearanceRow.tap()

        let lightThemeCard = app.staticTexts["Light"]
        XCTAssertTrue(lightThemeCard.waitForExistence(timeout: 2))
        lightThemeCard.tap()
        Thread.sleep(forTimeInterval: 0.3)

        for paletteName in ["Classic", "Pastel", "Neon", "Mono", "Terminal"] {
            // "Terminal" is ambiguous as a `staticTexts` lookup - it's both
            // an App Theme name (above, on this same screen) and a Tone
            // Palette name. The palette row's Button has the clean exact
            // label "Terminal" (the theme card's combines title+subtitle),
            // so disambiguate via `.buttons` for that one name.
            let paletteRow = paletteName == "Terminal" ? app.buttons["Terminal"] : app.staticTexts[paletteName]
            XCTAssertTrue(paletteRow.waitForExistence(timeout: 2))
            paletteRow.tap()
            Thread.sleep(forTimeInterval: 0.3)
            shot(app, name: "LightTheme_Palette_\(paletteName)")
        }
    }

    /// Walks every Settings sub-screen plus FAQ, screenshotting each so the
    /// Liquid Glass tile treatment can be checked everywhere it now applies.
    @MainActor
    func testSettingsAndFAQGlassTiles() throws {
        let app = XCUIApplication()
        app.launch()
        skipOnboardingToDashboard(app)

        // Dashboard's floating + button.
        XCTAssertTrue(app.buttons["newAnalysisButton"].waitForExistence(timeout: 2))
        shot(app, name: "Dashboard_PlusButton")

        app.buttons["dashboardSettingsButton"].tap()
        let settingsProfileRow = app.buttons["settingsProfileRow"]
        XCTAssertTrue(settingsProfileRow.waitForExistence(timeout: 2))
        shot(app, name: "Settings_MainList")

        settingsProfileRow.tap()
        XCTAssertTrue(app.textFields["Your name"].waitForExistence(timeout: 2))
        shot(app, name: "Settings_Profile")
        app.buttons["backButton"].tap()

        app.staticTexts["Appearance"].tap()
        XCTAssertTrue(app.staticTexts["Classic"].waitForExistence(timeout: 2))
        shot(app, name: "Settings_Appearance")
        app.buttons["backButton"].tap()

        app.staticTexts["Language"].tap()
        XCTAssertTrue(app.staticTexts["Default Reply Language"].waitForExistence(timeout: 2))
        shot(app, name: "Settings_Language")
        app.buttons["backButton"].tap()

        app.staticTexts["Subscription"].tap()
        let subscribeButton = app.buttons["Subscribe"]
        let manageOnAppStoreButton = app.buttons["Manage on the App Store"]
        XCTAssertTrue(subscribeButton.waitForExistence(timeout: 2) || manageOnAppStoreButton.waitForExistence(timeout: 2))
        shot(app, name: "Settings_ManageSubscription")
        app.buttons["backButton"].tap()

        app.staticTexts["Privacy Policy"].tap()
        XCTAssertTrue(app.staticTexts["Contact"].waitForExistence(timeout: 2))
        shot(app, name: "Settings_PrivacyPolicy")
        app.buttons["backButton"].tap()

        app.staticTexts["FAQ"].tap()
        XCTAssertTrue(app.staticTexts["Frequently Asked Questions"].waitForExistence(timeout: 2))
        shot(app, name: "Settings_FAQ")
    }
}
