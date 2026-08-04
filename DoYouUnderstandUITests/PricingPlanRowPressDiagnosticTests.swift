import XCTest

/// Diagnostic-only: `PricingPlanRow` (the checkout sheet's Monthly/Annual
/// selection rows) was found to still be using the old raw
/// `.glassEffect(...).overlay(shape.stroke(...))` pattern instead of
/// `GlassSelectionButtonStyle` - its border didn't grow with the tile when
/// held, same bug already fixed everywhere else. This checks it mid-press
/// after converting it.
final class PricingPlanRowPressDiagnosticTests: XCTestCase {

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
    func testPricingPlanRowMidPress() throws {
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

        let genderChip = app.buttons["Non-Conforming"]
        XCTAssertTrue(genderChip.waitForExistence(timeout: 2))
        genderChip.tap()
        app.buttons["Continue"].tap()

        let themeTitle = app.staticTexts["Choose your theme."]
        XCTAssertTrue(themeTitle.waitForExistence(timeout: 2))
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
        app.otherElements.firstMatch.press(forDuration: 1.6)

        let privacyTitle = app.staticTexts["Your Data is Safe With Us."]
        XCTAssertTrue(privacyTitle.waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        let toneDemoTitle = app.staticTexts["Control any conversation."]
        XCTAssertTrue(toneDemoTitle.waitForExistence(timeout: 2))
        let savagePill = app.buttons["Savage"]
        XCTAssertTrue(savagePill.waitForExistence(timeout: 2))
        savagePill.tap()
        XCTAssertTrue(app.staticTexts["Perfect. I'll do it my way then."].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()

        let claimTrialButton = app.buttons["Claim My 3-Day Free Trial"]
        XCTAssertTrue(claimTrialButton.waitForExistence(timeout: 2))
        claimTrialButton.tap()

        // Annual (not Monthly) is the pre-selected plan - it's the one with
        // an actual visible ring to check grows correctly with the tile.
        let annualRow = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Annual")).firstMatch
        XCTAssertTrue(annualRow.waitForExistence(timeout: 2))
        shot(app, name: "PricingPlanRow_AtRest")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            shot(app, name: "PricingPlanRow_MidPress_BorderShouldGrowWithTile")
        }
        annualRow.press(forDuration: 1.2)
    }
}
