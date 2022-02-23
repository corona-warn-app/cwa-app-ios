//
// 🦠 Corona-Warn-App
//

import XCTest

extension XCUIElement {

	@discardableResult
	func waitForElementToBecomeHittable(timeout: TimeInterval) -> Bool {
		let predicate   = NSPredicate(format: "exists == true && isHittable == true")
		let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
		let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
		return result == .completed
	}
}
