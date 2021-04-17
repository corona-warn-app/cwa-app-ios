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
	
	func testSuccessfulAntigenScan_Base64URL() throws {
		let payload = "eyJ0aW1lc3RhbXAiOjE2MTgzMDYwNTYsImd1aWQiOiI1OEM0MERBMC00Q0M1LTQ4ODAtOTIyMS0xNjBCNjA1OTIxQzAiLCJmbiI6IkpvZWwiLCJsbiI6IkdyYXppYW5pIiwiZG9iIjoiMTk4OC0wNy0wOSJ9"
		let antigenTestInformation = try XCTUnwrap(AntigenTestInformation(payload: payload))

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(let testInformation):
					XCTAssertEqual(testInformation.guid, antigenTestInformation.guid)
				case .pcr:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(payload)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	func testSuccessfulAntigenScan_base64() throws {
		let payload = "eyJ0aW1lc3RhbXAiOjE2MTgzMDY1MzAsImd1aWQiOiJDQzcyMEI2Ni1CNTBFLTQ1NzAtQUNCNC02RUExNEFEMDdGRDIiLCJmbiI6Ikhlcm1hbiIsImxuIjoiTWFydGluZXoiLCJkb2IiOiIxOTY0LTA5LTI3In0="
		let antigenTestInformation = try XCTUnwrap(AntigenTestInformation(payload: payload))

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(let testInformation):
					XCTAssertEqual(testInformation.guid, antigenTestInformation.guid)
				case .pcr:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(payload)")
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

		let result = viewModel.coronaTestQRCodeInformation(from: "")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_InputLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: String(repeating: "x", count: 150))

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_WrongURL() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://wrong.app/?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtration_someUTF8Text() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "This is a Test ん鞠")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "? \(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.dropLast(4))")

		XCTAssertNil(result)
	}

	func testAntigenQRCodeExtraction_GUIDLengthExceeded() throws {

		let viewModel = createViewModel()
		let antigenInformation = try XCTUnwrap(AntigenTestInformation(payload: validAntigenPayLoad))
		let result = viewModel.coronaTestQRCodeInformation(from: "https://s.coronawarn.app/?v=1#\(antigenInformation)-BEEF")

		XCTAssertNil(result)
	}

	func testAntigenPcrQRCodeExtraction_GUIDTooShort() throws {
		let viewModel = createViewModel()
		let invalidPayload = String(validAntigenPayLoad.dropLast(4))
		let result = viewModel.coronaTestQRCodeInformation(from: invalidPayload)

		XCTAssertNil(result)
	}
	
	func testPcrQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = createViewModel()

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = createViewModel()

		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.uppercased())") else {
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

		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.lowercased())") else {
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
		
		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(mixedCaseGuid)") else {
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
		let result = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?\(validPcrGuid)")

		// THEN
		XCTAssertNotNil(result)
	}

	func testGIVEN_invalidPath_WHEN_extractPcrGuid_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost//?A9652E-3BE0486D-0678-40A8-BEFD-07846B41993C")

		// THEN
		XCTAssertNil(result)
	}
	
	func testGIVEN_invalidPath_WHEN_extractAntigenPayload_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.coronaTestQRCodeInformation(from: "https://s.coronawarn.app/?v=1#//?eyJ0aW1lc3RhbXAiOjE2MTgyMzM5NzksImd1aWQiOiIwQzg5MjItMEM4OTIyNjMtQTM0Qy00RjM1LTg5QUMtMTcyMzlBMzQ2QUZEIiwiZm4iOiJDYW1lcm9uIiwibG4iOiJIdWRzb24iLCJkb2IiOiIxOTkyLTA4LTA3In0")

		// THEN
		XCTAssertNil(result)
	}
	
	private let validPcrGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
	private let validAntigenPayLoad = "eyJ0aW1lc3RhbXAiOjE2MTgzMDY1MzAsImd1aWQiOiJDQzcyMEI2Ni1CNTBFLTQ1NzAtQUNCNC02RUExNEFEMDdGRDIiLCJmbiI6Ikhlcm1hbiIsImxuIjoiTWFydGluZXoiLCJkb2IiOiIxOTY0LTA5LTI3In0="

	private func createViewModel() -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })
	}

}
