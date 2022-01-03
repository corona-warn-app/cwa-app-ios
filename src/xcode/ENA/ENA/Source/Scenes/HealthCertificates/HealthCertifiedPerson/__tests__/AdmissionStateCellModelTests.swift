////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit
import class CertLogic.Description

class AdmissionStateCellModelTests: XCTestCase {

	func testTitle() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Status-Nachweis")
	}

	func testThreeGWithAntigen() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.admissionState = .threeGWithAntigen

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "3G")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 3G-Regel. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
		XCTAssertEqual(cellModel.shortTitle, "3G")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

	func testThreeGWithPCR() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.admissionState = .threeGWithPCR

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "3G+")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 3G-Plus-Regel. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
		XCTAssertEqual(cellModel.shortTitle, "3G+")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

	func testTwoG() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		healthCertifiedPerson.admissionState = .twoG

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "2G")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 2G-Regel. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
		XCTAssertEqual(cellModel.shortTitle, "2G")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

	func testTwoGPlusAntigen() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .antigen)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate])
		healthCertifiedPerson.admissionState = .twoGPlusAntigen(twoG: twoGCertificate, antigenTest: testCertificate)

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "2G+ Schnelltest")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 2G-Plus-Regel, es sei denn, es wird ein PCR-Test benötigt. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
		XCTAssertEqual(cellModel.shortTitle, "2G+")
		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
	}

	func testTwoGPlusPCR() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .pcr)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate])
		healthCertifiedPerson.admissionState = .twoGPlusPCR(twoG: twoGCertificate, pcrTest: testCertificate)

		let cellModel = AdmissionStateCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.subtitle, "2G+ PCR-Test")
		XCTAssertEqual(cellModel.description, "Ihre Zertifikate erfüllen die 2G-Plus-Regel. Wenn Sie Ihren aktuellen Status vorweisen müssen, schließen sie diese Ansicht und zeigen Sie den QR-Code auf der Zertifikatsübersicht.")
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
