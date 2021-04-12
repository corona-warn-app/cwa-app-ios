//
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import XCTest
@testable import ENA

final class TestableExposureSubmissionQRScannerViewModel: ExposureSubmissionQRScannerViewModel {

	private var fakeIsScanning: Bool = false

	override var isScanningActivated: Bool {
		return fakeIsScanning
	}

	override func activateScanning() {
		fakeIsScanning = true
	}

	override func deactivateScanning() {
		fakeIsScanning = false
	}

	#if !targetEnvironment(simulator)
	override func startCaptureSession() {
		if isScanningActivated {
			deactivateScanning()
		} else {
			activateScanning()
		}
	}
	
	override func setupCaptureSession() {
		guard isScanningActivated else {
			onError(.cameraPermissionDenied, {})
			return
		}
	}
	#endif
}

final class ExposureSubmissionQRScannerViewModelTests: XCTestCase {

	func testSuccessfulPcrScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .pcr(let scannedGuid):
					XCTAssertEqual(scannedGuid, guid)
				case .antigen:
					XCTFail("Expected PCR test")
				}
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	
	func testSuccessfulAntigenScan_Base64URL() {
		let guid = "eyJ0aW1lc3RhbXAiOjE2MTgyMzM5NzksImd1aWQiOiIwQzg5MjItMEM4OTIyNjMtQTM0Qy00RjM1LTg5QUMtMTcyMzlBMzQ2QUZEIiwiZm4iOiJDYW1lcm9uIiwibG4iOiJIdWRzb24iLCJkb2IiOiIxOTkyLTA4LTA3In0"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(_, let scannedGuid):
					XCTAssertEqual(scannedGuid, guid)
				case .pcr:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(guid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	func testSuccessfulAntigenScan_base64URL() {
		let guid = "eyJ0aW1lc3RhbXAiOjE2MTgyMTEwMjksImd1aWQiOiIzNDlDNDUtMzQ5QzQ1MjItNzFDOC00MDlDLUJFRTgtMEZFMTA2MDU5MEY2IiwiZm4iOiJ+ZGEiLCJsbiI6IkhvcG1hbiIsImRvYiI6IjIwMDAtMDUtMjUifQ=="

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(_, let scannedGuid):
					XCTAssertEqual(scannedGuid, guid)
				case .pcr:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(guid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	func testUnsuccessfulScan() {
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 2

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		viewModel.activateScanning()
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one unsuccessful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testScanningIsDeactivatedInitially() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testInitalUnsuccessfulScanWithSuccessfulRetry() {
		let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 2

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .pcr(let scannedGuid):
					XCTAssertEqual(scannedGuid, validGuid)
				case .antigen:
					XCTFail("Expected PCR test")
				}
				onSuccessExpectation.fulfill()
			},
			onError: { error, reactivateScanning in
				switch error {
				case .cameraPermissionDenied:
					onErrorExpectation.fulfill()
					reactivateScanning()

				case .codeNotFound:
					onErrorExpectation.fulfill()
					reactivateScanning()

				case .other:
					XCTFail("unexpected error")
				}
			}
		)

		viewModel.activateScanning()

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])

		wait(for: [onErrorExpectation], timeout: .short)

		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(validGuid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])

		wait(for: [onSuccessExpectation], timeout: .short)
	}

	func testQRCodeExtraction_EmptyString() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_InputLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: String(repeating: "x", count: 150))

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_WrongURL() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://wrong.app/?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtration_someUTF8Text() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "This is a Test ん鞠")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "? \(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validPcrGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validPcrGuid.dropLast(4))")

		XCTAssertNil(result)
	}

	func testAntigenQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://s.coronawarn.app/?v=1#\(validAntigenPayload)-BEEF")

		XCTAssertNil(result)
	}

	func testAntigenPcrQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://s.coronawarn.app/?v=1#\(validAntigenPayload.dropLast(4))")

		XCTAssertNil(result)
	}
	
	func testPcrQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = createViewModel()

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.extractGuid(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = createViewModel()

		guard let result = viewModel.extractGuid(from: "https://localhost/?\(validPcrGuid.uppercased())") else {
			XCTFail("Result is nil")
			return
		}

		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, validPcrGuid)
		}
	}

	func testPcrQRCodeExtraction_ValidWithLowercaseString() {
		let viewModel = createViewModel()

		guard let result = viewModel.extractGuid(from: "https://localhost/?\(validPcrGuid.lowercased())") else {
			XCTFail("Result is nil")
			return
		}
		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, validPcrGuid.lowercased())
		}
	}

	func testPcrQRCodeExtraction_ValidWithMixedcaseString() {
		let viewModel = createViewModel()
		
		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		
		guard let result = viewModel.extractGuid(from: "https://localhost/?\(mixedCaseGuid)") else {
			XCTFail("Result is nil")
			return
		}
		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, mixedCaseGuid)
		}
	}

	func testGIVEN_ViewModelWithScanningEnabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCaptureSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_ViewModelWithScanningDisabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCaptureSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_upperCasedHost_WHEN_extractGuid_THEN_isFound() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.extractGuid(from: "HTTPS://LOCALHOST/?\(validPcrGuid)")

		// THEN
		XCTAssertNotNil(result)
	}

	func testGIVEN_invalidPath_WHEN_extractPcrGuid_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.extractGuid(from: "https://localhost//?A9652E-3BE0486D-0678-40A8-BEFD-07846B41993C")

		// THEN
		XCTAssertNil(result)
	}
	
	func testGIVEN_invalidPath_WHEN_extractAntigenPayload_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.extractGuid(from: "https://s.coronawarn.app/?v=1#//?eyJ0aW1lc3RhbXAiOjE2MTgyMzM5NzksImd1aWQiOiIwQzg5MjItMEM4OTIyNjMtQTM0Qy00RjM1LTg5QUMtMTcyMzlBMzQ2QUZEIiwiZm4iOiJDYW1lcm9uIiwibG4iOiJIdWRzb24iLCJkb2IiOiIxOTkyLTA4LTA3In0")

		// THEN
		XCTAssertNil(result)
	}
	
	private let validPcrGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
	// TO DO: replace with valid Payload with correct uuid v4
	private let validAntigenPayload = "d5f01a48-0e02-496f-9421-974b2737dc5d"

	private func createViewModel() -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })
	}

}
