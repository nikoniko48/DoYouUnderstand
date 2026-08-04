import XCTest

/// Ad-hoc verification that the Reply badge (Dashboard) and Reply's Input
/// screen icon now actually change with the tone palette. They used to
/// read `Main.secondaryAccent` (a fixed, `AppThemeChoice`-only blue,
/// unaffected by `TonePaletteChoice`), so switching to Pastel/Neon/Terminal
/// never changed Reply's color at all - only Mono did, via a later special
/// case. Both now reuse `Tone.professional`, which reskins with every
/// palette like Explain/Refine already did.
/// Not part of the smoke-test suite - produces screenshots for manual
/// review.
final class ReplyPaletteAwarenessTests: XCTestCase {

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
    func testReplyBadgeChangesWithTonePalette() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["dashboardSettingsButton"].tap()
        app.staticTexts["Appearance"].tap()

        for paletteName in ["Classic", "Pastel", "Neon"] {
            let paletteRow = app.staticTexts[paletteName]
            XCTAssertTrue(paletteRow.waitForExistence(timeout: 2))
            paletteRow.tap()
            Thread.sleep(forTimeInterval: 0.3)
            shot(app, name: "AppearanceScreen_\(paletteName)")
        }

        app.buttons["backButton"].tap()
        app.buttons["backButton"].tap()
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
        shot(app, name: "Dashboard_NeonPalette_ReplyBadge")

        app.buttons["newAnalysisButton"].tap()
        XCTAssertTrue(app.staticTexts["Reply"].waitForExistence(timeout: 2))
        shot(app, name: "InputScreen_NeonPalette_ReplyIcon")
    }
}
