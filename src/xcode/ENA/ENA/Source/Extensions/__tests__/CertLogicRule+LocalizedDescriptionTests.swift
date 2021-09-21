//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import class CertLogic.Rule
import class CertLogic.Description

final class CertLogicRuleLocalizedDescriptionTests: CWATestCase {

	func testWithDescriptionForCurrentLocale() {
		let rule = Rule.fake(
			description: [
				Description(lang: "xyz", desc: "Random Description"),
				Description(lang: "EN", desc: "English Description"),
				Description(lang: "Es", desc: "Spanish Description")
			]
		)

		XCTAssertEqual(rule.localizedDescription(locale: Locale(identifier: "es")), "Spanish Description")
	}

	func testWithMissingLocalDescriptionUsingEnglish() {
		let rule = Rule.fake(
			description: [
				Description(lang: "xyz", desc: "Random Description"),
				Description(lang: "EN", desc: "English Description"),
				Description(lang: "Es", desc: "Spanish Description")
			]
		)

		XCTAssertEqual(rule.localizedDescription(locale: Locale(identifier: "de")), "English Description")
	}

	func testWithMissingLocalAndEnglishDescriptionsUsingFirst() {
		let rule = Rule.fake(
			description: [
				Description(lang: "xyz", desc: "XYZ Description"),
				Description(lang: "abc", desc: "ABC Description"),
				Description(lang: "qwerty", desc: "QWERTY Description")
			]
		)

		XCTAssertEqual(rule.localizedDescription(locale: Locale(identifier: "de")), "XYZ Description")
	}

	func testWithoutDescriptionsUsingIdentifier() {
		let rule = Rule.fake(
			identifier: "Rule Identifier 1100",
			description: []
		)

		XCTAssertEqual(rule.localizedDescription(), "Rule Identifier 1100")
	}

}
