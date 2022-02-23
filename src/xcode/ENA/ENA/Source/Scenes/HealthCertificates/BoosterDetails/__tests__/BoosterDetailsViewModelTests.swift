//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class BoosterDetailsViewModelTests: CWATestCase {

	func testGIVEN_BoosterDetailsModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellCountsMatch() throws {
		// GIVEN
		let cclService = FakeCCLService()
		let healthCertificate = try vaccinationCertificate()
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			],
			boosterRule: .fake(),
			isNewBoosterRule: true
		)
		
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Hinweis zur Auffrischimpfung"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "auf Grundlage Ihrer gespeicherten Zertifikate"],
			parameters: []
		)
		
		let testLongText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Die Ständige Impfkommission (STIKO) empfiehlt allen Personen eine weitere Impfstoffdosis zur Optimierung der Grundimmunisierung, die mit einer Dosis des Janssen-Impfstoffs (Johnson & Johnson) grundimmunisiert wurden, bei denen keine Infektion mit dem Coronavirus SARS-CoV-2 nachgewiesen wurde und wenn ihre Janssen-Impfung über 4 Wochen her ist."],
			parameters: []
		)
		
		let viewModel = BoosterDetailsViewModel(cclService: cclService, healthCertifiedPerson: healthCertifiedPerson, boosterNotification: DCCBoosterNotification(visible: true, identifier: "hello", titleText: titleText, subtitleText: subtitleText, longText: testLongText, faqAnchor: "test"))

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 4)
	}
	
	func testGIVEN_BoosterDetailsModel_WHEN_ViewModel_THEN_MarkBoosterRuleAsSeen() throws {
		// GIVEN
		let cclService = FakeCCLService()
		let healthCertificate = try vaccinationCertificate()
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			],
			boosterRule: .fake(),
			isNewBoosterRule: true
		)
		
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Hinweis zur Auffrischimpfung"],
			parameters: []
		)
		
		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "auf Grundlage Ihrer gespeicherten Zertifikate"],
			parameters: []
		)
		
		let testLongText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Die Ständige Impfkommission (STIKO) empfiehlt allen Personen eine weitere Impfstoffdosis zur Optimierung der Grundimmunisierung, die mit einer Dosis des Janssen-Impfstoffs (Johnson & Johnson) grundimmunisiert wurden, bei denen keine Infektion mit dem Coronavirus SARS-CoV-2 nachgewiesen wurde und wenn ihre Janssen-Impfung über 4 Wochen her ist."],
			parameters: []
		)
		
		let viewModel = BoosterDetailsViewModel(cclService: cclService, healthCertifiedPerson: healthCertifiedPerson, boosterNotification: DCCBoosterNotification(visible: true, identifier: "hello", titleText: titleText, subtitleText: subtitleText, longText: testLongText, faqAnchor: "test"))

		// THEN
		XCTAssertTrue(healthCertifiedPerson.isNewBoosterRule)

		viewModel.markBoosterRuleAsSeen()

		XCTAssertFalse(healthCertifiedPerson.isNewBoosterRule)
	}
}
