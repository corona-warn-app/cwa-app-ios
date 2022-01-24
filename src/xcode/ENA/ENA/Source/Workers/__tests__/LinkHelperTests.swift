//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class LinkHelperTests: CWATestCase {
	
	func testFAQAnchorDE() throws {
		let url = LinkHelper.urlString(suffix: "test", type: .faq, languageCode: "de")

		XCTAssertEqual(url, "https://www.coronawarn.app/de/faq/#test")
	}
	
	func testFAQAnchorEN() throws {
		let url = LinkHelper.urlString(suffix: "test", type: .faq, languageCode: "en")

		XCTAssertEqual(url, "https://www.coronawarn.app/en/faq/#test")
	}
	
	func testFAQAnchorOtherLanguage() throws {
		let url = LinkHelper.urlString(suffix: "test", type: .faq, languageCode: "tr")

		XCTAssertEqual(url, "https://www.coronawarn.app/en/faq/#test")
	}
}
