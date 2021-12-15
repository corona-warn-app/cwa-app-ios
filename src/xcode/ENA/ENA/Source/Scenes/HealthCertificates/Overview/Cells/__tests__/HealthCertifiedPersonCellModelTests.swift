//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable type_body_length
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithSoonExpiringVaccinationCertificate() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiringSoon"))
			XCTAssertEqual(
				description,
				String(
					format: "Zertifikat läuft am %@ um %@ ab",
					DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
				)
			)
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat abgelaufen")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat (Signatur) ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
	}

	func testHealthCertifiedPersonWithBlockedVaccinationCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.caption)
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.caption)
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.caption)
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat (Signatur) ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
	}

	func testHealthCertifiedPersonWithBlockedTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithSoonExpiringRecoveryCertificate() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiringSoon"))
			XCTAssertEqual(
				description,
				String(
					format: "Zertifikat läuft am %@ um %@ ab",
					DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
				)
			)
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat abgelaufen")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
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
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat (Signatur) ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
	}

	func testHealthCertifiedPersonWithBlockedRecoveryCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		if case let .validityState(image: image, description: description) = viewModel.caption {
			XCTAssertEqual(image, UIImage(named: "Icon_ExpiredInvalid"))
			XCTAssertEqual(description, "Zertifikat ungültig")
		} else {
			XCTFail("Expected caption to be set to validityState")
		}
	}

	func testCaptionOnHealthCertifiedPersonWithUnseenNews() throws {
		// GIVEN
		let firstHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			isNew: true
		)

		let secondHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expired,
			isValidityStateNew: true
		)

		let thirdHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			isNew: false,
			isValidityStateNew: false
		)

		let fourthHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .invalid,
			isNew: true,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				firstHealthCertificate,
				secondHealthCertificate,
				thirdHealthCertificate,
				fourthHealthCertificate
			],
			boosterRule: .fake(),
			isNewBoosterRule: true
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		if case let .unseenNews(count: count) = viewModel.caption {
			XCTAssertEqual(count, 4)
		} else {
			XCTFail("Expected caption to be set to unseenNews")
		}
	}

	func testCaptionOnHealthCertifiedPersonWithUnseenNewBoosterRuleStateInconsistent() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [.mock()],
			boosterRule: nil,
			isNewBoosterRule: true
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertNil(viewModel.caption)
	}

	func testCaptionOnHealthCertifiedPersonWithoutUnseenNews() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [.mock()],
			boosterRule: nil,
			isNewBoosterRule: false
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertNil(viewModel.caption)
	}

}
