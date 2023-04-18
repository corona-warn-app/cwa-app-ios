//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeAppClosureNoticeCellModelTests: XCTestCase {

	func testGIVEN_cellModel_THEN_valuesAreCorrect() {
		// GIVEN
		let cclService = FakeCCLService()
		
		let titleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Achtung!", "en": "Important!"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Es wird nur noch bis zum 30. April 2023 möglich sein, andere Personen über die Corona-Warn-App zu warnen!", "en": "You will only be able to warn others through the Corona-Warn-App until April 30, 2023."],
			parameters: []
		)

		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Ab dem 1. Mai 2023 können Sie andere Personen hinsichtlich eines erhöhten Infektionsrisikos nicht mehr warnen und Sie erhalten keine Warnungen mehr über Risikobegegnungen. Ab dem 1. Juni 2023 wird die Corona-Warn-App nicht mehr weiterentwickelt. Auf Ihre in der App gespeicherten Zertifikate und das Kontakt-Tagebuch haben Sie jedoch weiterhin Zugriff. Allerdings können Sie keine neuen Zertifikate mehr hinzufügen."],
			parameters: []
		)
		
		let faqText = "Mehr Informationen finden Sie in den FAQ."

		let cellModel = HomeAppClosureNoticeCellModel(cclService: cclService, statusTabNotice: StatusTabNotice(visible: true, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: faqText))

		// THEN
		XCTAssertEqual(cellModel.title, "Achtung!")
		XCTAssertEqual(cellModel.subtitle, "Es wird nur noch bis zum 30. April 2023 möglich sein, andere Personen über die Corona-Warn-App zu warnen!")
		XCTAssertEqual(cellModel.icon, UIImage(named: "Icons_Attention_high"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.AppClosureNoticeCell.container)
	}

}
