////
// 🦠 Corona-Warn-App
//

import XCTest
import AVFoundation
@testable import ENA

final class TestableHealthCertificateQRCodeScannerViewModelTests: HealthCertificateQRCodeScannerViewModel {

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

class HealthCertificateQRCodeScannerViewModelTests: CWATestCase {

	func testSuccessfulScan() {
		let base45 = mockBase45

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		onErrorExpectation.isInverted = true

		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableHealthCertificateQRCodeScannerViewModelTests(
			healthCertificateService: HealthCertificateService(store: MockTestStore()),
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC1:\(base45)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
		
	func testUnsuccessfulScan_invalidPrefix() {
		let base45 = mockBase45

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableHealthCertificateQRCodeScannerViewModelTests(
			healthCertificateService: HealthCertificateService(store: MockTestStore()),
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)

		viewModel.activateScanning()
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC:\(base45)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one unsuccessful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testInitalUnsuccessfulScanWithSuccessfulRetry() {
		let validBase45 = mockBase45
		let emptyBase45 = ""

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableHealthCertificateQRCodeScannerViewModelTests(
			healthCertificateService: HealthCertificateService(store: MockTestStore()),
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _ in
				onErrorExpectation.fulfill()
			}
		)
		viewModel.activateScanning()

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: emptyBase45)
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])
		
		wait(for: [onErrorExpectation], timeout: .short)
		
		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "HC1:\(validBase45)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])
		
		wait(for: [onSuccessExpectation], timeout: .short)
	}

	// MARK: - Private

	// swiftlint:disable:next line_length
	private let mockBase45 = "6BFOXN*TS0BI$ZD4N9:9S6RCVN5+O30K3/XIV0W23NTDEXWK G2EP4J0BGJLFX3R3VHXK.PJ:2DPF6R:5SVBHABVCNN95SWMPHQUHQN%A0SOE+QQAB-HQ/HQ7IR.SQEEOK9SAI4- 7Y15KBPD34  QWSP0WRGTQFNPLIR.KQNA7N95U/3FJCTG90OARH9P1J4HGZJKBEG%123ZC$0BCI757TLXKIBTV5TN%2LXK-$CH4TSXKZ4S/$K%0KPQ1HEP9.PZE9Q$95:UENEUW6646936HRTO$9KZ56DE/.QC$Q3J62:6LZ6O59++9-G9+E93ZM$96TV6NRN3T59YLQM1VRMP$I/XK$M8PK66YBTJ1ZO8B-S-*O5W41FD$ 81JP%KNEV45G1H*KESHMN2/TU3UQQKE*QHXSMNV25$1PK50C9B/9OK5NE1 9V2:U6A1ELUCT16DEETUM/UIN9P8Q:KPFY1W+UN MUNU8T1PEEG%5TW5A 6YO67N6BBEWED/3LS3N6YU.:KJWKPZ9+CQP2IOMH.PR97QC:ACZAH.SYEDK3EL-FIK9J8JRBC7ADHWQYSK48UNZGG NAVEHWEOSUI2L.9OR8FHB0T5HM7I"

}
