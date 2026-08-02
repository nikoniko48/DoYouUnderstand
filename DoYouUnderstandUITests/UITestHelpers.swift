import XCTest

extension XCTestCase {
    /// `waitForExistence` only confirms an element is in the accessibility
    /// hierarchy - it says nothing about whether a `.tap()` will actually
    /// register. During the onboarding greeting screen's decryption intro,
    /// the "Skip Onboarding (Debug)" button already exists the whole time
    /// (it's just non-interactive, `allowsHitTesting(false)`, until the
    /// intro finishes), so waiting on `isHittable` instead avoids a tap
    /// that silently no-ops mid-animation.
    @discardableResult
    func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval = 9) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
