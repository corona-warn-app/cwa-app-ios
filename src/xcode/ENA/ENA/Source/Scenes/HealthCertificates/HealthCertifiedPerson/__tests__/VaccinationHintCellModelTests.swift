////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit
import class CertLogic.Description

class VaccinationHintCellModelTests: XCTestCase {

	func testAdmissionStateFromWalletInfo() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.dccWalletInfo = .fake(
			vaccinationState: .fake(
				visible: true,
				titleText: .fake(string: "Impfstatus"),
				subtitleText: .fake(string: "Letzte Impfung vor 1 Tag"),
				longText: .fake(string: "Sie haben noch nicht alle derzeit geplanten Impfungen erhalten. Daher ist Ihr Impfschutz noch nicht vollständig."),
				faqAnchor: "admission"
			)
		)

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 1 Tag")
		XCTAssertEqual(cellModel.description, "Sie haben noch nicht alle derzeit geplanten Impfungen erhalten. Daher ist Ihr Impfschutz noch nicht vollständig.")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

}
