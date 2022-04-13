//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificate_PDFTests: XCTestCase {

    func test_VaccinationCertificate() throws {
		let testBundle = Bundle(for: type(of: self))

		let base45Result = DigitalCovidCertificateFake.makeBase45Fake(
			certificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [VaccinationEntry.fake()]
			),
			header: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result,
			let vaccinationCertificate = try? HealthCertificate(base45: base45) else {
			XCTFail("Success expected.")
			return
		}

		_ = try vaccinationCertificate.pdfDocument(
			with: SAP_Internal_Dgc_ValueSets(),
			from: testBundle
		)
    }

	func test_TestCertificate() throws {
		let testBundle = Bundle(for: type(of: self))

		let base45Result = DigitalCovidCertificateFake.makeBase45Fake(
			certificate: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			),
			header: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result,
			let testCertificate = try? HealthCertificate(base45: base45) else {
			XCTFail("Success expected.")
			return
		}

		_ = try testCertificate.pdfDocument(
			with: SAP_Internal_Dgc_ValueSets(),
			from: testBundle
		)
	}

	func test_RecoveryCertificate() throws {
		let testBundle = Bundle(for: type(of: self))

		let base45Result = DigitalCovidCertificateFake.makeBase45Fake(
			certificate: DigitalCovidCertificate.fake(
				recoveryEntries: [RecoveryEntry.fake()]
			),
			header: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result,
			let recoveryCertificate = try? HealthCertificate(base45: base45) else {
			XCTFail("Success expected.")
			return
		}

		_ = try recoveryCertificate.pdfDocument(
			with: SAP_Internal_Dgc_ValueSets(),
			from: testBundle
		)
	}

}
