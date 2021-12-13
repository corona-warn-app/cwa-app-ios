//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

final class TestQRScannerViewModel: QRScannerViewModel {

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
// swiftlint:disable line_length
class QRScannerViewModelTests: XCTestCase {

	func test_ifValid_PCR_Test_Scanned_then_parsing_is_successful() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1
		let onFailureExpectation = expectation(description: "onFailure called")
		onFailureExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success(let result):
				switch result {
				case .coronaTest(let testInformation):
					XCTAssertEqual(testInformation.testType, .pcr, "Expected PCR test")
					onSuccessExpectation.fulfill()
				default:
					XCTFail("Expected a successful scan of PCR test")
				}
			case .failure(let parserError):
				XCTAssertEqual(parserError, .scanningError(.scanningDeactivated), "Expected PCR test")
				onFailureExpectation.fulfill()
			}
		}
		
		let validNegativePcrTest = "https://localhost/?18091E-18091EFE-1373-447C-A040-0DBCEE31E278"
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validNegativePcrTest)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		viewModel.didScan(metadataObjects: [metaDataObject])
		waitForExpectations(timeout: .short)
	}
	
	
	func test_ifValid_Antigen_Test_Scanned_then_parsing_is_successful() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success(let result):
				switch result {
				case .coronaTest(let testInformation):
					XCTAssertEqual(testInformation.testType, .antigen, "Expected Antigen test")
					onSuccessExpectation.fulfill()
				default:
					XCTFail("Expected a successful scan of Antigen test")
				}
			case .failure:
				XCTFail("Expected a successful scan of Antigen test")
			}
		}
		
		let validNegativePcrTest = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MzIxMzk0MzMsInNhbHQiOiJGODE4RTZFMjdDRkU0QkE2MDI1OTg3N0ZGRTZFREE4OCIsInRlc3RpZCI6IjUyOTA2NGVhLWVhZDItNGYwMC1iNzlmLTBjYjM4NDBiODkzYiIsImhhc2giOiIzNDgyMzU1NGUwNjhiODFhM2FkYWQ3Yzc5YWMzMGE4ZThkNmM4NzM3NjNkMGE1MmZiMGJjMjE3ZDUzNTI4YzgzIiwiZm4iOiJXaWxsaWUiLCJsbiI6IlVlZGEiLCJkb2IiOiIxOTkzLTA5LTI2In0"
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validNegativePcrTest)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		waitForExpectations(timeout: .short)
	}
	
	func test_ifValid_Event_Scanned_then_parsing_is_successful() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success(let result):
				switch result {
				case .traceLocation(let traceLocation):
					XCTAssertEqual(traceLocation.address, "1594 Deffe Avenue", "Expected correct event address")
					XCTAssertEqual(traceLocation.type, .locationTypePermanentFoodService, "Expected correct event type")
					onSuccessExpectation.fulfill()
				default:
					XCTFail("Expected a successful scan of traceLocation")
				}
			case .failure:
				XCTFail("Expected a successful scan of traceLocation")
			}
		}
		
		let validEventURL = "https://e.coronawarn.app?v=1#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validEventURL)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		waitForExpectations(timeout: .short)
	}
	
	func test_ifValid_Certificate_Scanned_then_parsing_is_successful() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)
		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success(let result):
				switch result {
				case let .certificate(certificateResult):
					XCTAssertEqual(certificateResult.person.dateOfBirth, "1981-08-30", "Expected correct person dateOfBirth")
					XCTAssertEqual(certificateResult.person.name?.standardizedName, "MITCHELL ROBERT", "Expected correct person standardizedName")
					XCTAssertEqual(certificateResult.certificate.type, .vaccination, "Expected correct person standardizedName")
					onSuccessExpectation.fulfill()
				default:
					XCTFail("Expected a successful scan of Vaccination Certificate")
				}
			case .failure:
				XCTFail("Expected a successful scan of Vaccination Certificate")
			}
		}
		
		let validCertificateURL = "HC1:6BFOXN*TS0BI$ZD8UHRTHZDE+VJG$L20I7*S1RO4.S-OPL-I0$E7XHQI5UTE8X6F/8X*G-O9UVPQRHIY1VS1NQ1 WUQRELS4HBT5IV6:IR4DN8TLS4J1TOX0O05L%2NS4KCTIYC1MFE67EHNTGV6ALD-I:X0YO74$0NS4.$S6ZC0JBX63*E3IFTIJ3N:IN1MPF5RBQ746B46O1N646RM93O5RF6$T61R6B46646O$9KZ56DE/.QC$Q3J62:6PV66RU%TE6UG+ZE V1+GOT*OBR7UX4NC6O67U96L*KDYPKCOJADBIHOHK1JAF.7H:SZJJ%U4:7P CF7:4OHT-3TB6JS1J6:IZW4I:A6J3ARN5TTHR98D39RM3P0PLN5:FX K.8N IJ67M.EN37J+ULD7J.HK AE29OJDNCZG$XQ* 646L+7MEKRJTEYYDYAU:0P7UUR9J6BM%BA0FE-VUYN73TTMF0UPM-73 OJS836VN++UTLISVIXE240HURI4UFPHLE*R%9N%2RB40.CKW3"
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validCertificateURL)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		waitForExpectations(timeout: .short)
	}
	
	func test_ifInValid_QRCode_Scanned_then_parsing_fails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)
		let onFailureExpectation = expectation(description: "onFailure called")
		onFailureExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success:
				XCTFail("Expected scan to fail")
			case .failure(let error):
				switch error {
				case .scanningError(let generalScanningError):
					XCTAssertEqual(generalScanningError, .codeNotFound, "Error type should be code not found")
				default:
					XCTFail("Expected the error type to be codeNotFound")

				}
				onFailureExpectation.fulfill()
			}
		}
		
		let invalidURL = "HfdfC1:6BFOXN*TS0BI$ZD8UHRTHZDE+VJG$L20I7*S1RO4.S-OPL-I0$E7XHQI5UTE8X6F/8X*G-O9UVPQRHIY1VS1NQ1 WUQRELS4HBT5IV6:IR4DN8TLS4J1TOX0O05L%2NS4KCTIYC1MFE67EHNTGV6ALD-I:X0YO74$0NS4.$S6ZC0JBX63"
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: invalidURL)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])
		waitForExpectations(timeout: .short)
	}

	func testInitialUnsuccessfulScanWithSuccessfulRetry() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let dscListProvider = MockDSCListProvider()
		let dccSignatureVerifier = DCCSignatureVerifyingStub()
		let boosterNotificationsService = BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(store: store, client: client)
		)
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			client: client,
			appConfiguration: appConfigurationProvider,
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)

		let validGuid = "https://e.coronawarn.app?v=1#CAESJQgBEgpBZ3dheSBJbmMuGhExNTk0IERlZmZlIEF2ZW51ZSgAMAAadggBEmA4xNrp5hKJoO_yVbXfF1gS8Yc5nURhOIVLG3nUcSg8IPsI2e8JSIhg-FrHUymQ3RR80KUKb1lZjLQkfTUINUP16r6-jFDURwUlCQQi6NXCgI0rQw0a4MrVrKMbF4NzhQMaEPXDJZ2XSeO0SY43-KCQlQciBggBEAQYHA"
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 1

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: false
		)

		let viewModel = TestQRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfigurationProvider,
			qrCodeParser: qrCodeParser
		) { result in
			switch result {
			case .success:
				onSuccessExpectation.fulfill()
			case .failure(let error):
				switch error {
				case .scanningError(.cameraPermissionDenied):
					onErrorExpectation.fulfill()
				case .scanningError(.codeNotFound):
					onErrorExpectation.fulfill()
				default:
					XCTFail("unexpected error")
				}
			}
		}

		viewModel.activateScanning()

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: emptyGuid)
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])

		wait(for: [onErrorExpectation], timeout: .short)

		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: validGuid)
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])

		wait(for: [onSuccessExpectation], timeout: .short)
	}

	func testDCCPersonCountMax() {
		var appFeature = SAP_Internal_V2_AppFeature()
		appFeature.label = "dcc-person-count-max"
		appFeature.value = 17

		var appFeatures = SAP_Internal_V2_AppFeatures()
		appFeatures.appFeatures = [appFeature]

		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		appConfig.appFeatures = appFeatures

		let appConfigProvider = CachedAppConfigurationMock(with: appConfig, store: MockTestStore())

		XCTAssertEqual(appConfigProvider.featureProvider.intValue(for: .dccPersonCountMax), 17)
	}

}
