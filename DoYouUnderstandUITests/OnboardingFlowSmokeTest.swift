import XCTest

final class OnboardingFlowSmokeTest: XCTestCase {

    @MainActor
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["Condescending & Bossy"].tap()
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()

        let step2Title = app.staticTexts["How do you usually handle a tricky text or email?"]
        XCTAssertTrue(step2Title.waitForExistence(timeout: 2))
        let step2Screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        step2Screenshot.lifetime = .keepAlways
        step2Screenshot.name = "OnboardingStep2"
        add(step2Screenshot)

        app.staticTexts["Vent to a coworker"].tap()
        app.buttons["Continue"].tap()

        let armButton = app.buttons["ARM YOURSELF"]
        XCTAssertTrue(armButton.waitForExistence(timeout: 2))
        let step3Screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        step3Screenshot.lifetime = .keepAlways
        step3Screenshot.name = "OnboardingStep3"
        add(step3Screenshot)

        armButton.tap()

        let dashboardTitle = app.staticTexts["DO YOU\nUNDERSTAND?!"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 2))
    }
}
