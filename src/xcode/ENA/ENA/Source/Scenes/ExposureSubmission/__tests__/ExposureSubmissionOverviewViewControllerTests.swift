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
	var coordinator: MockExposureSubmissionCoordinator!

	override func setUp() {
		super.setUp()
		service = MockExposureSubmissionService()
		qrScannerViewController = MockExposureSubmissionQRScannerViewController()
		coordinator = MockExposureSubmissionCoordinator()
	}

	func testQRCodeScanSuccess() {
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
			ExposureSubmissionOverviewViewController(coder: coder, coordinator: self.coordinator, exposureSubmissionService: self.service)
		}

		let expectation = self.expectation(description: "Received test result callback")
		service.getTestResultCallback = { completion in
			completion(.success(.negative))
			expectation.fulfill()
		}

		qrScannerViewController.dismissCallback = { _, callback in callback?() }

		vc.qrScanner(qrScannerViewController, didScan: "https://localhost/?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
		waitForExpectations(timeout: .short)
	}
}

class ExposureSubmissionOverviewViewModelTests: XCTestCase {

	func testQRCodeSanitization() {
		let viewModel = ExposureSubmissionOverviewViewModel()
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		// Empty.
		var result = viewModel.sanitizeAndExtractGuid("")
		XCTAssertNil(result)

		// Input Length exceeded.
		result = viewModel.sanitizeAndExtractGuid(String(repeating: "x", count: 150))
		XCTAssertNil(result)

		// Wrong URL.
		result = viewModel.sanitizeAndExtractGuid("https://coronawarn.app/?\(guid)")
		XCTAssertNil(result)

		// Missing URL.
		result = viewModel.sanitizeAndExtractGuid("?\(guid)")
		XCTAssertNil(result)

		// Missing ?.
		result = viewModel.sanitizeAndExtractGuid("https://localhost/\(guid)")
		XCTAssertNil(result)

		// Additional space after ?
		result = viewModel.sanitizeAndExtractGuid("? \(guid)")
		XCTAssertNil(result)

		// GUID length exceeded.
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(guid)-BEEF")
		XCTAssertNil(result)

		// GUID too short.
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(guid.dropLast(4))")
		XCTAssertNil(result)

		// GUID structure wrong.
		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(wrongGuid)")
		XCTAssertNil(result)

		// Success uppercase.
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(guid)")
		XCTAssertEqual(result, guid)

		// Success lowercase.
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(guid.lowercased())")
		XCTAssertEqual(result, guid.lowercased())

		// Success mixed case.
		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		result = viewModel.sanitizeAndExtractGuid("https://localhost/?\(mixedCaseGuid)")
		XCTAssertEqual(result, mixedCaseGuid)
	}
}
