////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RecycleBinItemCellModelTests: CWATestCase {

	func testViewModelWithVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: .fake(
					name: .fake(
						familyName: "Schmidt-Mustermann",
						givenName: "Erika Dörte"
					),
					vaccinationEntries: [
						.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-02-03"
						)
					]
				)
			)
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .certificate(healthCertificate))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_Certificate"))
		XCTAssertEqual(viewModel.name, "Erika Dörte Schmidt-Mustermann")
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.secondaryInfo, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.tertiaryInfo, "geimpft am 03.02.21")
	}

	func testViewModelWithPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: .fake(
					name: .fake(
						familyName: "Schmidt-Mustermann",
						givenName: "Tina Maria"
					),
					testEntries: [
						.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T12:34:17.595Z"
						)
					]
				)
			)
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .certificate(healthCertificate))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_Certificate"))
		XCTAssertEqual(viewModel.name, "Tina Maria Schmidt-Mustermann")
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.secondaryInfo, "PCR-Test")
		XCTAssertEqual(viewModel.tertiaryInfo, "Probenahme am 29.05.21")
	}

	func testViewModelWithAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: .fake(
					name: .fake(
						familyName: "Schmidt-Mustermann",
						givenName: "Tina Maria"
					),
					testEntries: [
						.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-28T20:16:45.384Z"
						)
					]
				)
			)
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .certificate(healthCertificate))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_Certificate"))
		XCTAssertEqual(viewModel.name, "Tina Maria Schmidt-Mustermann")
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.secondaryInfo, "Schnelltest")
		XCTAssertEqual(viewModel.tertiaryInfo, "Probenahme am 28.05.21")
	}

	func testViewModelWithTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: .fake(
					name: .fake(
						familyName: "Schmidt-Mustermann",
						givenName: "Erika Dörte"
					),
					testEntries: [
						.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-09-16T20:16:45.384Z"
						)
					]
				)
			)
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .certificate(healthCertificate))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_Certificate"))
		XCTAssertEqual(viewModel.name, "Erika Dörte Schmidt-Mustermann")
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.secondaryInfo)
		XCTAssertEqual(viewModel.tertiaryInfo, "Probenahme am 16.09.21")
	}

	func testViewModelWithRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: .fake(
					name: .fake(
						familyName: "Schmidt-Mustermann",
						givenName: "Erika Dörte"
					),
					recoveryEntries: [
						.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			)
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .certificate(healthCertificate))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_Certificate"))
		XCTAssertEqual(viewModel.name, "Erika Dörte Schmidt-Mustermann")
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.secondaryInfo)
		XCTAssertEqual(viewModel.tertiaryInfo, "gültig bis 18.03.22")
	}

	func testViewModelWithPCRTest() throws {
		let coronaTest: CoronaTest = .pcr(
			.mock(registrationDate: Date(timeIntervalSince1970: 1634217419))
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .coronaTest(coronaTest))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_CoronaTest"))
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.title, "Test")
		XCTAssertEqual(viewModel.secondaryInfo, "PCR-Test")
		XCTAssertEqual(viewModel.tertiaryInfo, "registriert am 14.10.21")
	}

	func testViewModelWithAntigenTest() throws {
		let coronaTest: CoronaTest = .antigen(
			.mock(sampleCollectionDate: Date(timeIntervalSince1970: 1634217419))
		)

		let viewModel = RecycleBinItemCellModel(
			recycleBinItem: RecycleBinItem(recycledAt: Date(), item: .coronaTest(coronaTest))
		)

		XCTAssertEqual(viewModel.iconImage, UIImage(imageLiteralResourceName: "Icons_RecycleBin_CoronaTest"))
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.title, "Test")
		XCTAssertEqual(viewModel.secondaryInfo, "Schnelltest")
		XCTAssertEqual(viewModel.tertiaryInfo, "durchgeführt am 14.10.21")
	}

}
