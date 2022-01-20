//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class LinkHelperTests: CWATestCase {
	
	func testFAQAnchorDE() throws {
		let url = LinkHelper.urlString(suffix: "test", type: .faq)

		XCTAssertEqual(NSLocale.current.languageCode, "de")
		XCTAssertEqual(url, "https://www.coronawarn.app/de/faq/#test")
	}
	
	func testFAQAnchorEN() throws {
		if NSLocale.current.languageCode == "en" {
			let url = LinkHelper.urlString(suffix: "test", type: .faq)

			XCTAssertEqual(url, "https://www.coronawarn.app/en/faq/#test")
		}
	}
	
	func testFAQAnchorOtherLanguages() throws {
		let supportedLocale = ["tr", "ro", "pl"]
		if supportedLocale.contains(NSLocale.current.languageCode ?? "") {
			let url = LinkHelper.urlString(suffix: "test", type: .faq)

			XCTAssertEqual(url, "https://www.coronawarn.app/en/faq/#test")
		}
	}
}
