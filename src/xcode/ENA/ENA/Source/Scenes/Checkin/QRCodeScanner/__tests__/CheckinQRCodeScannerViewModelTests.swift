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
	
	#endif
}

class CheckinQRCodeScannerViewModelTests: XCTestCase {
	
	func testSuccessfulScan() {
		let guid = "https://e.coronawarn.app?v=1#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1
		
		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.isInverted = true
		onErrorExpectation.expectedFulfillmentCount = 1
		
		let viewModel = TestableCheckinQRCodeScannerViewModel(
			verificationHelper: QRCodeVerificationHelper(),
			appConfiguration: CachedAppConfigurationMock(),
			onSuccess: { _ in
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
			verificationHelper: QRCodeVerificationHelper(),
			appConfiguration: CachedAppConfigurationMock(),
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
		let validGuid = "https://e.coronawarn.app?v=1#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let emptyGuid = ""
		
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1
		
		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1
		
		let viewModel = TestableCheckinQRCodeScannerViewModel(
			verificationHelper: QRCodeVerificationHelper(),
			appConfiguration: CachedAppConfigurationMock(),
			onSuccess: { _ in
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
