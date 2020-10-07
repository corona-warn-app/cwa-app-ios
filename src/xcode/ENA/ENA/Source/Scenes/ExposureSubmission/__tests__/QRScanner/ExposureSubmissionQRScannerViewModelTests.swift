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

final class ExposureSubmissionQRScannerViewModelTests: XCTestCase {

	func testActivateScanning() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		XCTAssertFalse(viewModel.isScanningActivated)

		viewModel.activateScanning()

		XCTAssertTrue(viewModel.isScanningActivated)
	}

	func testDeactivateScanning() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: true)

		XCTAssertTrue(viewModel.isScanningActivated)

		viewModel.deactivateScanning()

		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testQRCodeExtraction_EmptyString() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_InputLengthExceeded() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: String(repeating: "x", count: 150))

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_WrongURL() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://coronawarn.app/?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "? \(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDTooShort() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.dropLast(4))")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.extractGuid(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.uppercased())")

		XCTAssertEqual(result, validGuid)
	}

	func testQRCodeExtraction_ValidWithLowercaseString() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.lowercased())")

		XCTAssertEqual(result, validGuid.lowercased())
	}

	func testQRCodeExtraction_ValidWithMixedcaseString() {
		let viewModel = ExposureSubmissionQRScannerViewModel(isScanningActivated: false)

		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		let result = viewModel.extractGuid(from: "https://localhost/?\(mixedCaseGuid)")

		XCTAssertEqual(result, mixedCaseGuid)
	}

	private let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

}
