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

		// swiftlint:disable line_length
		let longText = DCCUIText(
			type: "string",
			quantity: nil,
			quantityParameterIndex: nil,
			functionName: nil,
			localizedText: ["de": "Ab dem 1. Mai 2023 können Sie andere Personen hinsichtlich eines erhöhten Infektionsrisikos nicht mehr warnen und Sie erhalten keine Warnungen mehr über Risikobegegnungen. Ab dem 1. Juni 2023 wird die Corona-Warn-App nicht mehr weiterentwickelt. Auf Ihre in der App gespeicherten Zertifikate und das Kontakt-Tagebuch haben Sie jedoch weiterhin Zugriff. Allerdings können Sie keine neuen Zertifikate mehr hinzufügen.", "en": "As of May 1, 2023, you will no longer be able to warn others of an increased risk of infection, nor will you receive warnings from your own risk exposures. Development of the Corona-Warn-App will be discontinued as of June 1, 2023. You will still be able to access the certificates you have saved in the app, as well as your contact diary, but you will not be able to add new certificates."],
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
