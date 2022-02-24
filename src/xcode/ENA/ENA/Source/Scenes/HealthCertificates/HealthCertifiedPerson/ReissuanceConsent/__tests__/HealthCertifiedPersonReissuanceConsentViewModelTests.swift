//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertifiedPersonReissuanceConsentViewModelTests: CWATestCase {


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
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
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
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 6)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 1)
	}

	func testGIVEN_ViewModel_WHEN_OnlyOneTextIsPresent_THEN_NumberOfCellsMatches() throws {
		// GIVEN
		let certificate = HealthCertificate.mock()
		let viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
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
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 2), 6)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 3), 1)
	}

}
