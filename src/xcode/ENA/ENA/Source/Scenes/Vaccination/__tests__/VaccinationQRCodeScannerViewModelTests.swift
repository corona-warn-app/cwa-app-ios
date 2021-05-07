////
// 🦠 Corona-Warn-App
//

import XCTest
import AVFoundation
@testable import ENA

final class TestableVaccinationQRCodeScannerViewModelTests: VaccinationQRCodeScannerViewModel {

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
	
	#endif
}

class VaccinationQRCodeScannerViewModelTests: XCTestCase {
	func testSuccessfulPcrScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		onErrorExpectation.isInverted = true

		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableVaccinationQRCodeScannerViewModelTests(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC1:\(guid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
		
	func testUnsuccessfulScan_invalidPrefix() {
		let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableVaccinationQRCodeScannerViewModelTests(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)

		viewModel.activateScanning()
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC:\(validGuid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one unsuccessful scan
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
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableVaccinationQRCodeScannerViewModelTests(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { error in
				switch error {
				case .cameraPermissionDenied:
					onErrorExpectation.fulfill()
				case .codeNotFound:
					onErrorExpectation.fulfill()
				default:
					XCTFail("unexpected error")
				}
			}
		)
		viewModel.activateScanning()

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: emptyGuid)
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])
		
		wait(for: [onErrorExpectation], timeout: .short)
		
		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC1:\(validGuid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])
		
		wait(for: [onSuccessExpectation], timeout: .short)
	}
}
