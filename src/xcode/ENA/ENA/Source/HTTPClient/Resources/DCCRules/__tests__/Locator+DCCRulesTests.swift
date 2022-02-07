//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_DCCRulesTest: XCTestCase {

	func testGIVEN_LocatorAcceptance_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ae1404e07dd219aa58040e1613d3706792a6e84c157e5446427a5ea9b2e631e7"
		let locator = Locator.DCCRules(ruleType: .acceptance, isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	func testGIVEN_LocatorInvalidation_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "a5b8a28665551894e395848137773f6648a3e7dd58f5a3f8f3f1badee164e43e"
		let locator = Locator.DCCRules(ruleType: .invalidation, isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	func testGIVEN_LocatorBoosterNotification_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "f2b3a4c9ac4e1c7d4ffbe1200982dee68422179cb5046810339c5b863789a0f6"
		let locator = Locator.DCCRules(ruleType: .boosterNotification, isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
