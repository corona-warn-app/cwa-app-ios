//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
class HealthCertificateReissuanceConsentViewModelTests: CWATestCase {

	let listTitleText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Zu erneuernde Zertifikate:"],
		parameters: []
	)
	
	let titleText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Zertifikate erneuern"],
		parameters: []
	)

	let subtitleText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Erneuerung direkt über die App vornehmen"],
		parameters: []
	)

	let bodyText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Für mindestens ein Zertifikat ist die Gültigkeit abgelaufen oder läuft in Kürze ab. Mit einem abgelaufenen Zertifikat können Sie Ihren Status nicht mehr nachweisen.\n\nIm Zeitraum von 28 Tagen vor Ablauf und bis zu 3 Monate nach Ablauf der Gültigkeit können Sie sich neue Zertifikate direkt kostenlos über die App ausstellen lassen. Hierfür ist Ihr Einverständnis erforderlich."],
		parameters: []
	)
	
	func testGIVEN_ViewModel_WHEN_AllTextsArePresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							listTitleText: listTitleText,
							titleText: titleText,
							consentSubtitleText: subtitleText,
							longText: bodyText
						)
					)
				)
			),
			appConfigProvider: CachedAppConfigurationMock(),
			restServiceProvider: RestServiceProviderStub(loadResources: []),
			healthCertificateService: HealthCertificateServiceFake(),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}
	
	func testGIVEN_ViewModel_WHEN_AllTextsArePresentWithoutConsentSubtitleText_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							listTitleText: listTitleText,
							titleText: titleText,
							consentSubtitleText: nil,
							subtitleText: subtitleText,
							longText: bodyText
						)
					)
				)
			),
			appConfigProvider: CachedAppConfigurationMock(),
			restServiceProvider: RestServiceProviderStub(loadResources: []),
			healthCertificateService: HealthCertificateServiceFake(),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}

	func testGIVEN_ViewModel_WHEN_AllTextsArePresentWithoutBothSubtitles_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							listTitleText: listTitleText,
							titleText: titleText,
							consentSubtitleText: nil,
							subtitleText: nil,
							longText: bodyText
						)
					)
				)
			),
			appConfigProvider: CachedAppConfigurationMock(),
			restServiceProvider: RestServiceProviderStub(loadResources: []),
			healthCertificateService: HealthCertificateServiceFake(),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 4)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}
	
	func testGIVEN_ViewModel_WHEN_OnlyOneTextIsPresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							listTitleText: nil,
							titleText: nil,
							subtitleText: subtitleText,
							longText: nil
						)
					)
				)
			),
			appConfigProvider: CachedAppConfigurationMock(),
			restServiceProvider: RestServiceProviderStub(loadResources: []),
			healthCertificateService: HealthCertificateServiceFake(),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 0)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 3)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}

	func test_submit_returns_success() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				   vaccinationEntries: [
					   VaccinationEntry.fake(
						   doseNumber: 1,
						   totalSeriesOfDoses: 2,
						   dateOfVaccination: "2021-06-01"
					   )
				   ]
			   )
		   )
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				   LoadResource(
					   result: .success(
						   [
							   DCCReissuanceCertificate(
								   certificate: healthCertificateBase45,
								   relations: [
										DCCReissuanceRelation(index: 0, action: "replace")
								   ]
							   )
						   ]
					   ),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let certificate = try HealthCertificate(base45: healthCertificateBase45)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { }
		)
		
		let submitExpectation = expectation(description: "Submit completion is called.")
		viewModel.submit { result in
			guard case .success = result else {
				XCTFail("Success was expected")
				submitExpectation.fulfill()
				return
			}
			submitExpectation.fulfill()
		}
			
		waitForExpectations(timeout: .short)
		XCTAssertTrue(healthCertificateServiceSpy.didCallReplaceHealthCertificate)
	}
	
	func test_submit_returns_error_noRelation() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				   vaccinationEntries: [
					   VaccinationEntry.fake(
						   doseNumber: 1,
						   totalSeriesOfDoses: 2,
						   dateOfVaccination: "2021-06-01"
					   )
				   ]
			   )
		   )
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				   LoadResource(
					   result: .success(
						   [
							   DCCReissuanceCertificate(
								   certificate: healthCertificateBase45,
								   relations: []
							   )
						   ]
					   ),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let certificate = try HealthCertificate(base45: healthCertificateBase45)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { }
		)
		
		let submitExpectation = expectation(description: "Submit completion is called.")
		viewModel.submit { result in
			guard case .failure(let error) = result,
				  case .noRelation = error else {
				XCTFail("noRelation error was expected")
				submitExpectation.fulfill()
				return
			}
			
			submitExpectation.fulfill()
		}
			
		waitForExpectations(timeout: .short)
		XCTAssertFalse(healthCertificateServiceSpy.didCallReplaceHealthCertificate)
	}
	
	func test_submit_returns_error_certificateToReissueMissing() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = nil
				
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				   vaccinationEntries: [
					   VaccinationEntry.fake(
						   doseNumber: 1,
						   totalSeriesOfDoses: 2,
						   dateOfVaccination: "2021-06-01"
					   )
				   ]
			   )
		   )
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				   LoadResource(
					   result: .success(
						   [
							   DCCReissuanceCertificate(
								   certificate: healthCertificateBase45,
								   relations: [
										DCCReissuanceRelation(index: 0, action: "replace")
								   ]
							   )
						   ]
					   ),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let certificate = try HealthCertificate(base45: healthCertificateBase45)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { }
		)
		
		let submitExpectation = expectation(description: "Submit completion is called.")
		viewModel.submit { result in
			guard case .failure(let error) = result,
				  case .certificateToReissueMissing = error else {
				XCTFail("certificateToReissueMissing error was expected")
				submitExpectation.fulfill()
				return
			}
			
			submitExpectation.fulfill()
		}
			
		waitForExpectations(timeout: .short)
		XCTAssertFalse(healthCertificateServiceSpy.didCallReplaceHealthCertificate)
	}
	
	func test_submit_returns_replaceHealthCertificateError() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				   vaccinationEntries: [
					   VaccinationEntry.fake(
						   doseNumber: 1,
						   totalSeriesOfDoses: 2,
						   dateOfVaccination: "2021-06-01"
					   )
				   ]
			   )
		   )
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				   LoadResource(
					   result: .success(
						   [
							   DCCReissuanceCertificate(
								   certificate: healthCertificateBase45,
								   relations: [
										DCCReissuanceRelation(index: 0, action: "replace")
								   ]
							   )
						   ]
					   ),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateServiceErrorStub = HealthCertificateServiceErrorStub()
		let appConfigMock = CachedAppConfigurationMock()
		let certificate = try HealthCertificate(base45: healthCertificateBase45)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceErrorStub,
			onDisclaimerButtonTap: { }
		)
		
		let submitExpectation = expectation(description: "Submit completion is called.")
		viewModel.submit { result in
			guard case .failure(let error) = result,
				  case .replaceHealthCertificateError = error else {
				XCTFail("replaceHealthCertificateError error was expected")
				submitExpectation.fulfill()
				return
			}
			
			submitExpectation.fulfill()
		}
			
		waitForExpectations(timeout: .short)
	}
	
	func test_submit_returns_restServiceError() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				   LoadResource(
					result: .failure(
						ServiceError.receivedResourceError(DCCReissuanceResourceError.DCC_RI_400(nil))
					),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake()
		)
		
		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let certificate = try HealthCertificate(base45: healthCertificateBase45)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [certificate],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { }
		)
		
		let submitExpectation = expectation(description: "Submit completion is called.")
		viewModel.submit { result in
			guard case .failure(let error) = result,
				  case .restServiceError = error else {
				XCTFail("restServiceError error was expected")
				submitExpectation.fulfill()
				return
			}
			
			submitExpectation.fulfill()
		}
			
		waitForExpectations(timeout: .short)
		XCTAssertFalse(healthCertificateServiceSpy.didCallReplaceHealthCertificate)
	}
}

class HealthCertificateServiceFake: HealthCertificateServiceServable {
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson,
		markAsNew: Bool,
		completedNotificationRegistration: @escaping () -> Void
	) throws { }
	
}

class HealthCertificateServiceSpy: HealthCertificateServiceServable {
	
	var didCallReplaceHealthCertificate = false
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson,
		markAsNew: Bool,
		completedNotificationRegistration: @escaping () -> Void
	) throws {
			didCallReplaceHealthCertificate = true
			completedNotificationRegistration()
	}
	
}

class HealthCertificateServiceErrorStub: HealthCertificateServiceServable {
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson,
		markAsNew: Bool,
		completedNotificationRegistration: @escaping () -> Void
	) throws {
			throw FakeError.fake
	}
	
}
