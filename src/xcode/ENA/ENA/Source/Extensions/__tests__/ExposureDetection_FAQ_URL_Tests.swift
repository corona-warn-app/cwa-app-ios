//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import ExposureNotification

final class ExposureDetection_FAQ_URL_Tests: XCTestCase {

	// MARK: - ENError FAQ URL mapping tests

	func testENError_Unsupported_FAQURL() {
		XCTAssertEqual(ENError(.unsupported).faqURL, URL(string: AppStrings.Links.appFaqENError5))
	}

	func testENError_Internal_FAQURL() {
		XCTAssertEqual(ENError(.internal).faqURL, URL(string: AppStrings.Links.appFaqENError11))
	}

	func testENError_RateLimited_FAQURL() {
		XCTAssertEqual(ENError(.rateLimited).faqURL, URL(string: AppStrings.Links.appFaqENError13))
	}
}
