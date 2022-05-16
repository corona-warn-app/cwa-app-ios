//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
// swiftlint:disable file_length
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
			certificates: [.fake()],
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
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 6)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 7)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}
	
	func testGIVEN_ViewModel_WHEN_AllTextsArePresentWithoutConsentSubtitleText_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
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
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 6)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 7)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}

	func testGIVEN_ViewModel_WHEN_AllTextsArePresentWithoutBothSubtitles_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
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
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 7)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 4), 1)
	}
	
	func testGIVEN_ViewModel_WHEN_OnlyOneTextIsPresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
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
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 0)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 4)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 7)
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
			digitalCovidCertificate: .fake(
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
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
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
	
	func test_filtering_accompanying_certifcates() throws {
		let first = try base45Fake(
			digitalCovidCertificate: .fake(
				name: .fake(standardizedFamilyName: "Ahmed", standardizedGivenName: "OMAR"),
				vaccinationEntries: [.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "1"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let second = try base45Fake(
			digitalCovidCertificate: .fake(
				name: .fake(standardizedFamilyName: "Ahmed", standardizedGivenName: "OMAR"),
				vaccinationEntries: [.fake(
					dateOfVaccination: "2021-07-14",
					uniqueCertificateIdentifier: "2"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let third = try base45Fake(
			digitalCovidCertificate: .fake(
				name: .fake(standardizedFamilyName: "Ahmed", standardizedGivenName: "OMAR"),
				vaccinationEntries: [.fake(
					dateOfVaccination: "2021-03-14",
					uniqueCertificateIdentifier: "3"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let forth = try base45Fake(
			digitalCovidCertificate: .fake(
				name: .fake(standardizedFamilyName: "Ahmed", standardizedGivenName: "OMAR"),
				vaccinationEntries: [.fake(
					dateOfVaccination: "2021-09-14",
					uniqueCertificateIdentifier: "4"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		// create 2 DCCReissuanceCertificateContainer that include each other in the accompanyingCertificates and have duplicate accompanyingCertificates
		let firstCertificate = DCCReissuanceCertificateContainer(
			certificateToReissue:
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: first)
				),
			accompanyingCertificates: [
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: second)
				),
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: third)
				),
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: forth)
				)
			],
			action: "Replace"
		)
		let secondCertificate = DCCReissuanceCertificateContainer(
			certificateToReissue:
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: second)
				),
			accompanyingCertificates: [
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: first)
				),
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: third)
				),
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: forth)
				),
				DCCCertificateContainer(
					certificateRef: DCCCertificateReference(barcodeData: third)
				)
			],
			action: "Replace"
		)
		
		let firstHealthCertificate = try HealthCertificate(base45: first)
		let secondHealthCertificate = try HealthCertificate(base45: second)
		let thirdHealthCertificate = try HealthCertificate(base45: third)
		let forthHealthCertificate = try HealthCertificate(base45: forth)
		let fifthHealthCertificate = try HealthCertificate(base45: third)
		
		let person = HealthCertifiedPerson(
			healthCertificates: [
				firstHealthCertificate,
				secondHealthCertificate,
				thirdHealthCertificate,
				forthHealthCertificate,
				fifthHealthCertificate
			]
		)
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [firstCertificate, secondCertificate],
			certifiedPerson: person,
			appConfigProvider: CachedAppConfigurationMock(),
			restServiceProvider: RestServiceProviderStub(),
			healthCertificateService: HealthCertificateServiceSpy(),
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
		)
		XCTAssertEqual(viewModel.filteredAccompanyingCertificates.map({ $0.uniqueCertificateIdentifier }), ["4", "3"])
	}

	func test_submit_returns_error_certificateToReissueMissing() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: DCCCertificateReissuance(
				reissuanceDivision: DCCCertificateReissuanceDivision(
					visible: true,
					titleText: titleText,
					subtitleText: subtitleText,
					longText: .fake(),
					faqAnchor: "certificateReissuance",
					identifier: "renew",
					listTitleText: listTitleText,
					consentSubtitleText: subtitleText
				),
				certificateToReissue: nil,
				accompanyingCertificates: nil,
				certificates: [ DCCReissuanceCertificateContainer(
					certificateToReissue: DCCCertificateContainer(
						certificateRef: DCCCertificateReference(barcodeData: nil)
					),
					accompanyingCertificates: [],
					action: "renew"
				)]
			)
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
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
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
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceErrorStub,
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
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

		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificates: [DCCReissuanceCertificateContainer.fake()],
			certifiedPerson: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy,
			onDisclaimerButtonTap: { },
			onAccompanyingCertificatesButtonTap: { _ in }
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
		requestCertificates: [String],
		with newCertificates: [DCCReissuanceCertificate],
		for person: HealthCertifiedPerson,
		markAsNew: Bool,
		completedNotificationRegistration: @escaping () -> Void
	) throws { }
	
}

class HealthCertificateServiceSpy: HealthCertificateServiceServable {
	
	var didCallReplaceHealthCertificate = false
	
	func replaceHealthCertificate(
		requestCertificates: [String],
		with newCertificates: [DCCReissuanceCertificate],
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
		requestCertificates: [String],
		with newCertificates: [DCCReissuanceCertificate],
		for person: HealthCertifiedPerson,
		markAsNew: Bool,
		completedNotificationRegistration: @escaping () -> Void
	) throws {
		throw FakeError.fake
	}

}
