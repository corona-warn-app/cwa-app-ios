//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionErrorTests: CWATestCase {

	func testGetURLInternal() {
		let url = ExposureSubmissionError.internal.faqURL
		XCTAssertEqual(url?.absoluteString, AppStrings.Links.appFaqENError11)
	}

	func testGetURLUnsupported() {
		let url = ExposureSubmissionError.unsupported.faqURL
		XCTAssertEqual(url?.absoluteString, AppStrings.Links.appFaqENError5)
	}

	func testGetURLRateLimited() {
		let url = ExposureSubmissionError.rateLimited.faqURL
		XCTAssertEqual(url?.absoluteString, AppStrings.Links.appFaqENError13)
	}

}
