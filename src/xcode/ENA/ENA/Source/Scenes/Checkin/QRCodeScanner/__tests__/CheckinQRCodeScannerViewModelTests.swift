////
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import XCTest
@testable import ENA

final class TestableCheckinQRCodeScannerViewModel: CheckinQRCodeScannerViewModel {

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
	
	override var captureSession: AVCaptureSession? = {
		guard isScanningActivated else {
			onError(.cameraPermissionDenied, {})
			return
		}
	}
	#endif
}

class CheckinQRCodeScannerViewModelTests: XCTestCase {
	
	func testSuccessfulScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1
		
		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.isInverted = true
		onErrorExpectation.expectedFulfillmentCount = 1
		
		let viewModel = TestableCheckinQRCodeScannerViewModel(
			onSuccess: { qrCodeString in
				XCTAssertEqual(qrCodeString, guid)
				
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)
		
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: guid)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		viewModel.didScan(metadataObjects: [metaDataObject])
		
		waitForExpectations(timeout: .short)
	}
	
	func testUnsuccessfulScan() {
		let emptyGuid = ""
		
		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true
		
		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1
		
		let viewModel = TestableCheckinQRCodeScannerViewModel(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)
		
		viewModel.activateScanning()
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: emptyGuid)
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
		
		let viewModel = TestableCheckinQRCodeScannerViewModel(
			onSuccess: { qrCodeString in
				XCTAssertEqual(qrCodeString, validGuid)
				
				onSuccessExpectation.fulfill()
			},
			onError: { error  in
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
		
		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validGuid)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])
		
		wait(for: [onSuccessExpectation], timeout: .short)
	}
}
