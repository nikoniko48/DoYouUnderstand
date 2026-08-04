import XCTest

/// Ad-hoc visual verification for two fixes:
/// 1. The Dashboard history card's type badge ("EXPLANATION"/"REFINE") used
///    to reuse theme-adaptive monochrome tokens (`Text.highlight`/
///    `Main.accent`), which read as a flat white/black pill in Dark/Light -
///    now colored via the same `Tone.*` palette used for their Input screen
///    icons.
/// 2. The Input screen's Explain/Reply/Refine mode tiles used to tint the
///    entire Liquid Glass surface with `Main.primary` when selected, which
///    looked like a solid white/colored blob rather than glass - now a
///    plain glass surface plus a thin colored ring.
/// Not part of the smoke-test suite - this exists purely to produce
/// screenshots for manual review.
final class TileAndBadgeAppearanceTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDashboardHistoryBadgeColors() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UI_TEST_USE_MOCK_HISTORY"]
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        // The seed data's most recent entries (mock_1 explanation, mock_2
        // reply) should already be visible at the top of the list without
        // any scrolling.
        XCTAssertTrue(app.staticTexts["EXPLANATION"].waitForExistence(timeout: 2))

        let topShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        topShot.lifetime = .keepAlways
        topShot.name = "DashboardBadges_Top"
        add(topShot)

        // Scroll down to bring the Refine seed entry (mock_8, the oldest)
        // into view too, so its badge color is captured in the same run.
        app.swipeUp()
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.3)

        let scrolledShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        scrolledShot.lifetime = .keepAlways
        scrolledShot.name = "DashboardBadges_Scrolled"
        add(scrolledShot)
    }

    @MainActor
    func testInputScreenTileSelectionAppearance() throws {
        let app = XCUIApplication()
        app.launch()

        let skipButton = app.buttons["Skip Onboarding (Debug)"]
        XCTAssertTrue(waitUntilHittable(skipButton))
        skipButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5))

        app.buttons["newAnalysisButton"].tap()

        let explanationTile = app.staticTexts["Explanation"]
        XCTAssertTrue(explanationTile.waitForExistence(timeout: 2))

        // Explain is selected by default - capture that resting state first.
        let defaultShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        defaultShot.lifetime = .keepAlways
        defaultShot.name = "InputTiles_ExplainSelected_Default"
        add(defaultShot)

        app.staticTexts["Reply"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        let replyShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        replyShot.lifetime = .keepAlways
        replyShot.name = "InputTiles_ReplySelected"
        add(replyShot)

        app.staticTexts["Refine"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        let refineShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        refineShot.lifetime = .keepAlways
        refineShot.name = "InputTiles_RefineSelected"
        add(refineShot)
    }
}
