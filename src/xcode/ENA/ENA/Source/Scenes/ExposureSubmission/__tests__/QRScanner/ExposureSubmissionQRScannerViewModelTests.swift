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

import AVFoundation
import Foundation
import XCTest
@testable import ENA

final class ExposureSubmissionQRScannerViewModelTests: XCTestCase {

	func testSuccessfulScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		onErrorExpectation.isInverted = true

		let viewModel = ExposureSubmissionQRScannerViewModel(
			isScanningActivated: true,
			onSuccess: { deviceRegistrationKey in
				XCTAssertEqual(deviceRegistrationKey, .guid(guid))

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			},
			onCancel: { }
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: 1.0)
	}

	func testUnsuccessfulScan() {
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = ExposureSubmissionQRScannerViewModel(
			isScanningActivated: true,
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { error, _ in
				XCTAssertEqual(error, .codeNotFound)

				onErrorExpectation.fulfill()
			},
			onCancel: { }
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one unsuccessful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: 1.0)
	}

	func testScanningIsDeactivatedInitially() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError not called")
		onErrorExpectation.isInverted = true

		let viewModel = ExposureSubmissionQRScannerViewModel(
			isScanningActivated: false,
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			},
			onCancel: { }
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: 1.0)
	}

	func testInitalUnsuccessfulScanWithSuccessfulRetry() {
		let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = ExposureSubmissionQRScannerViewModel(
			isScanningActivated: true,
			onSuccess: { deviceRegistrationKey in
				XCTAssertEqual(deviceRegistrationKey, .guid(validGuid))

				onSuccessExpectation.fulfill()
			},
			onError: { error, reactivateScanning in
				XCTAssertEqual(error, .codeNotFound)

				reactivateScanning()

				onErrorExpectation.fulfill()
			},
			onCancel: { }
		)

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])

		wait(for: [onErrorExpectation], timeout: 1.0)

		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(validGuid)")
		viewModel.didScan(metadataObjects: [validMetaDataObject])

		wait(for: [onSuccessExpectation], timeout: 1.0)
	}

	func testQRCodeExtraction_EmptyString() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_InputLengthExceeded() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: String(repeating: "x", count: 150))

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_WrongURL() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://coronawarn.app/?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "? \(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.dropLast(4))")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = createViewModel(isScanningActivated: false)

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.extractGuid(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.uppercased())")

		XCTAssertEqual(result, validGuid)
	}

	func testQRCodeExtraction_ValidWithLowercaseString() {
		let viewModel = createViewModel(isScanningActivated: false)

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.lowercased())")

		XCTAssertEqual(result, validGuid.lowercased())
	}

	func testQRCodeExtraction_ValidWithMixedcaseString() {
		let viewModel = createViewModel(isScanningActivated: false)

		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		let result = viewModel.extractGuid(from: "https://localhost/?\(mixedCaseGuid)")

		XCTAssertEqual(result, mixedCaseGuid)
	}

	private let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

	private func createViewModel(isScanningActivated: Bool) -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(isScanningActivated: isScanningActivated, onSuccess: { _ in }, onError: { _, _ in }, onCancel: { })
	}

}
