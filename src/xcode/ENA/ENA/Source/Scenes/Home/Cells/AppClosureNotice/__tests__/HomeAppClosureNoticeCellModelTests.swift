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
			localizedText: ["de": "Betriebsende"],
			parameters: []
		)

		let subtitleText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Der Betrieb der Corona-Warn-App wird am xx.xx.xxxx eingestellt."],
			parameters: []
		)
		
		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Sie erhalten dann keine Warnungen mehr über Risiko-begegnungen und können selbst andere nicht mehr warnen. Sie können keine Tests mehr registrieren und erhalten keine Testergebnisse mehr über die App. Auf Ihre Zertifikate und das Kontakt-Tagebuch haben Sie weiterhin Zugriff. Allerdings können Sie keine neuen Zertifikate mehr hinzufügen."],
			parameters: []
		)
		
		let faqText = "Mehr Informationen finden Sie in den FAQ."

		let cellModel = HomeAppClosureNoticeCellModel(cclService: cclService, statusTabNotice: StatusTabNotice(visible: true, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: faqText))

		// THEN
		XCTAssertEqual(cellModel.title, "Betriebsende")
		XCTAssertEqual(cellModel.subtitle, "Der Betrieb der Corona-Warn-App wird am xx.xx.xxxx eingestellt.")
		XCTAssertEqual(cellModel.icon, UIImage(named: "Icons_Attention_high"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.AppClosureNoticeCell.container)
	}

}
