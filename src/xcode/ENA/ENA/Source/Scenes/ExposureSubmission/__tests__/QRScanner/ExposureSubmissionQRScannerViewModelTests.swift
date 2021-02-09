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

	func testSuccessfulScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { deviceRegistrationKey in
				XCTAssertEqual(deviceRegistrationKey, .guid(guid))

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
			onSuccess: { deviceRegistrationKey in
				XCTAssertEqual(deviceRegistrationKey, .guid(validGuid))

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

		let result = viewModel.extractGuid(from: "https://coronawarn.app/?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtration_someUTF8Text() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "This is a Test ん鞠")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "?\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/\(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "? \(validGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.dropLast(4))")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = createViewModel()

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.extractGuid(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.uppercased())")

		XCTAssertEqual(result, validGuid)
	}

	func testQRCodeExtraction_ValidWithLowercaseString() {
		let viewModel = createViewModel()

		let result = viewModel.extractGuid(from: "https://localhost/?\(validGuid.lowercased())")

		XCTAssertEqual(result, validGuid.lowercased())
	}

	func testQRCodeExtraction_ValidWithMixedcaseString() {
		let viewModel = createViewModel()

		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		let result = viewModel.extractGuid(from: "https://localhost/?\(mixedCaseGuid)")

		XCTAssertEqual(result, mixedCaseGuid)
	}

	func testGIVEN_ViewModelWithScanningEnabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCapturSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_ViewModelWithScanningDisabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCapturSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_upperCasedHost_WHEN_extractGuid_THEN_isFound() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.extractGuid(from: "HTTPS://LOCALHOST/?\(validGuid)")

		// THEN
		XCTAssertNotNil(result)
	}

	func testGIVEN_invalidPath_WHEN_extractGuid_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.extractGuid(from: "https://localhost//?A9652E-3BE0486D-0678-40A8-BEFD-07846B41993C")

		// THEN
		XCTAssertNil(result)
	}

	private let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

	private func createViewModel() -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })
	}

}
