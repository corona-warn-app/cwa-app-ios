//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateReissuanceConsentViewModelTests: CWATestCase {


	let titleText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Zertifikat aktualisieren"],
		parameters: []
	)

	let subtitleText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Neuausstellung direkt über die App vornehmen"],
		parameters: []
	)

	let bodyText = DCCUIText(
		type: "string",
		quantity: nil,
		quantityParameterIndex: nil,
		functionName: nil,
		localizedText: ["de": "Die Spezifikationen der EU für Zertifikate von Auffrischimpfungen wurden geändert. Dieses Zertifikat entspricht nicht den aktuellen Spezifikationen. Das Impfzertifikat ist zwar weiterhin gültig, es kann jedoch sein, dass bei einer Prüfung die Auffrischimpfung nicht erkannt wird. Bitte lassen Sie sich daher ein neues Impfzertifikat ausstellen. Sie können ein neues Impfzertifikat direkt kostenlos über die App anfordern. Hierfür ist Ihr Einverständnis erforderlich."],
		parameters: []
	)

	func testGIVEN_ViewModel_WHEN_AllTextsArePresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificate: certificate,
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							titleText: titleText,
							subtitleText: subtitleText,
							longText: bodyText
						)
					)
				)
			),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 4)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 4)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 2)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 1)
	}

	func testGIVEN_ViewModel_WHEN_OnlyOneTextIsPresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: FakeCCLService(),
			certificate: certificate,
			certifiedPerson: HealthCertifiedPerson(
				healthCertificates: [certificate],
				isPreferredPerson: true,
				dccWalletInfo: .fake(
					certificateReissuance: .fake(
						reissuanceDivision: .fake(
							visible: true,
							titleText: nil,
							subtitleText: subtitleText,
							longText: nil
						)
					)
				)
			),
			onDisclaimerButtonTap: { }
		)

		// WHEN
		let sectionsCount = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(sectionsCount, 4)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 2)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 1), 2)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 5)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 1)
	}

	func test_submit_returns_success() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
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
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			person: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy
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
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
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
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			person: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy
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
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = nil
				
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
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
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			person: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy
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
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let person = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		
		person.dccWalletInfo = .fake(
			certificateReissuance: .fake()
		)
				
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
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
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			person: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceErrorStub
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
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
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
						ServiceError.receivedResourceError(DCCReissuanceResourceError.DCC_RI_400)
					),
					   willLoadResource: nil
				   )
			   ]
		   )

		let healthCertificateServiceSpy = HealthCertificateServiceSpy()
		let appConfigMock = CachedAppConfigurationMock()
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			person: person,
			appConfigProvider: appConfigMock,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateServiceSpy
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

class HealthCertificateServiceSpy: HealthCertificateServiceServable {
	
	var didCallReplaceHealthCertificate = false
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson) throws {
			didCallReplaceHealthCertificate = true
	}
	
}

class HealthCertificateServiceErrorStub: HealthCertificateServiceServable {
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson) throws {
			throw FakeError.fake
	}
	
}
