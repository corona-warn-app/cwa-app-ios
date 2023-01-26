//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AppClosureNoticeDetailsViewModelTests: CWATestCase {

	func testGIVEN_AppClosureNoticeModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellCountsMatch() throws {
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
			localizedText: ["de": "Sie erhalten dann keine Warnungen mehr über Risikobegegnungen und können selbst andere nicht mehr warnen. Sie können keine Tests mehr registrieren und erhalten keine Testergebnisse mehr über die App. Auf Ihre Zertifikate und das Kontakt-Tagebuch haben Sie weiterhin Zugriff. Allerdings können Sie keine neuen Zertifikate mehr hinzufügen."],
			parameters: []
		)
		
		let faqText = "Mehr Informationen finden Sie in den FAQ."

		let viewModel = AppClosureNoticeDetailsViewModel(cclService: cclService, statusTabNotice: StatusTabNotice(visible: true, titleText: titleText, subtitleText: subtitleText, longText: longText, faqAnchor: faqText))
		
		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 4)
	}
}
