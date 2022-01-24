////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit
import class CertLogic.Description

class AdmissionStateCellModelTests: XCTestCase {

	func testAdmissionStateFromWalletInfo() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(
				visible: true,
				badgeText: .fake(string: "2G+"),
				titleText: .fake(string: "Status-Nachweis"),
				subtitleText: .fake(string: "2G+ Schnelltest"),
				longText: .fake(string: "Ihre Zertifikate erfüllen die 2G-Plus-Regel, es sei denn, es wird ein PCR-Test benötigt. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen Sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht."),
				faqAnchor: "admission"
			)
		)

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "2G+ Schnelltest")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 2G-Plus-Regel, es sei denn, es wird ein PCR-Test benötigt. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen Sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
		XCTAssertEqual(cellModel.shortTitle, "2G+")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

	func testSolidGreyGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.gradientType = .solidGrey

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.gradientType, .solidGrey)
	}

	func testLightBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.gradientType = .lightBlue

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.gradientType, .lightBlue)
	}

	func testMediumBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.gradientType = .mediumBlue

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.gradientType, .mediumBlue)
	}

	func testDarkBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.gradientType = .darkBlue

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.gradientType, .darkBlue)
	}

}
