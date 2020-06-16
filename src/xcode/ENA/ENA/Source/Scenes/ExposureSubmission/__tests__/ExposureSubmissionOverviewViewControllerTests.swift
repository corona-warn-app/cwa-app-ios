//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import XCTest
@testable import ENA

extension TimeInterval {
	static let short = 1.0
	static let long = 3.0
}

final class ExposureSubmissionOverviewViewControllerTests: XCTestCase {

	var service: MockExposureSubmissionService!
	var qrScannerViewController: MockExposureSubmissionQRScannerViewController!

	override func setUp() {
		super.setUp()
		service = MockExposureSubmissionService()
		qrScannerViewController = MockExposureSubmissionQRScannerViewController()
	}

	func testQRCodeScanSuccess() {
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
			ExposureSubmissionOverviewViewController(coder: coder, service: self.service)
		}

		let expectation = self.expectation(description: "Call getRegistration service method.")
		service.getRegistrationTokenCallback = { deviceRegistrationKey, completion in
			completion(.success(""))
			expectation.fulfill()
		}

		qrScannerViewController.dismissCallback = { _, callback in callback?() }

		vc.qrScanner(qrScannerViewController, didScan: "https://example.org/?50C707FB-2DC4-4252-9C21-7B0DF0F30ED5")
		waitForExpectations(timeout: .short)
	}

	func testQRCodeSanitization() {
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
			ExposureSubmissionOverviewViewController(coder: coder, service: self.service)
		}

		// Empty.
		var result = vc.sanitizeAndExtractGuid("")
		XCTAssertNil(result)

		// Input Length exceeded.
		result = vc.sanitizeAndExtractGuid(String(repeating: "x", count: 150))
		XCTAssertNil(result)

		// Missing ?.
		let guid = "61d4e0f7-a910-4b82-8b9b-39fdc76837a0"
		result = vc.sanitizeAndExtractGuid("https://abc.com/\(guid)")
		XCTAssertNil(result)

		// Additional space after ?
		result = vc.sanitizeAndExtractGuid("? \(guid)")
		XCTAssertNil(result)

		// GUID Length exceeded.
		result = vc.sanitizeAndExtractGuid("https://abc.com/\(guid)\(guid)")
		XCTAssertNil(result)

		// Success.
		result = vc.sanitizeAndExtractGuid("https://abc.com?\(guid)")
		XCTAssertEqual(result, guid)
		result = vc.sanitizeAndExtractGuid("?\(guid)")
		XCTAssertEqual(result, guid)
		result = vc.sanitizeAndExtractGuid(" ?\(guid)")
		XCTAssertEqual(result, guid)
		result = vc.sanitizeAndExtractGuid("some-string?\(guid)")
		XCTAssertEqual(result, guid)
		result = vc.sanitizeAndExtractGuid("https://abc.com?\(guid.uppercased())")
		XCTAssertEqual(result, guid.uppercased())
	}
}
