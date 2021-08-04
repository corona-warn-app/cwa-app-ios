//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertifiedPersonCellModelTests: XCTestCase {

	func testHealthCertifiedPersonWithValidVaccinationCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
	}

	func testHealthCertifiedPersonWithSoonExpiringVaccinationCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat läuft am 03.08.21 um 12:41 ab")
	}

	func testHealthCertifiedPersonWithExpiredVaccinationCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
	}

	func testHealthCertifiedPersonWithInvalidVaccinationCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
	}

	func testHealthCertifiedPersonWithValidTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
	}

	func testHealthCertifiedPersonWithSoonExpiringTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
	}

	func testHealthCertifiedPersonWithExpiredTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
	}

	func testHealthCertifiedPersonWithInvalidTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
	}

	func testHealthCertifiedPersonWithValidRecoveryCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
	}

	func testHealthCertifiedPersonWithSoonExpiringRecoveryCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat läuft am 03.08.21 um 12:41 ab")
	}

	func testHealthCertifiedPersonWithExpiredRecoveryCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
	}

	func testHealthCertifiedPersonWithInvalidRecoveryCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
	}

}
