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

//final class ExposureSubmissionOverviewViewControllerTests: XCTestCase {
//
//	var service: MockExposureSubmissionService!
//	var qrScannerViewController: MockExposureSubmissionQRScannerViewController!
//	var coordinator: MockExposureSubmissionCoordinator!
//
//	override func setUp() {
//		super.setUp()
//		service = MockExposureSubmissionService()
//		qrScannerViewController = MockExposureSubmissionQRScannerViewController()
//		coordinator = MockExposureSubmissionCoordinator()
//	}
//
//	func testQRCodeScanSuccess() {
//		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
//			ExposureSubmissionOverviewViewController(coder: coder, coordinator: self.coordinator, exposureSubmissionService: self.service)
//		}
//
//		let expectation = self.expectation(description: "Received test result callback")
//		service.getTestResultCallback = { completion in
//			completion(.success(.negative))
//			expectation.fulfill()
//		}
//
//		qrScannerViewController.dismissCallback = { _, callback in callback?() }
//
//		vc.qrScanner(qrScannerViewController, didScan: "https://localhost/?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
//		waitForExpectations(timeout: .short)
//	}
//}
