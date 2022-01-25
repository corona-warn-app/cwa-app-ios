//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
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

	func testAdmissionStateThreeGWithAntigen() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try testCertificate(type: .antigen)]
		)
		healthCertifiedPerson.admissionState = .threeGWithAntigen

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertEqual(cellModel.shortStatus, "3G")
	}

	func testAdmissionStateThreeGWithPCR() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try testCertificate(type: .pcr)]
		)
		healthCertifiedPerson.admissionState = .threeGWithPCR

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertEqual(cellModel.shortStatus, "3G+")
	}

	func testAdmissionStateTwoG() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.admissionState = .twoG(twoG: try vaccinationCertificate())

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertEqual(cellModel.shortStatus, "2G")
	}
	
	func testAdmissionStateTwoGPlus() throws {
		let boosterCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 3, totalSeriesOfDoses: 3)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [boosterCertificate]
		)
		healthCertifiedPerson.admissionState = .twoG(twoG: boosterCertificate)

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertEqual(cellModel.shortStatus, "2G+")
	}

	func testAdmissionStateTwoGPlusAntigen() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .antigen)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate])
		healthCertifiedPerson.admissionState = .twoGPlusAntigen(twoG: twoGCertificate, antigenTest: testCertificate)

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertEqual(
			cellModel.switchableHealthCertificates,
			["2G-Zertifikat": twoGCertificate, "Testzertifikat": testCertificate]
		)
		XCTAssertEqual(cellModel.shortStatus, "2G+")
	}

	func testAdmissionStateTwoGPlusPCR() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .pcr)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate])
		healthCertifiedPerson.admissionState = .twoGPlusPCR(twoG: twoGCertificate, pcrTest: testCertificate)

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertEqual(
			cellModel.switchableHealthCertificates,
			["2G-Zertifikat": twoGCertificate, "Testzertifikat": testCertificate]
		)
		XCTAssertEqual(cellModel.shortStatus, "2G+")
	}

	func testAdmissionStateOther() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.admissionState = .other

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertFalse(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertNil(cellModel.shortStatus)
	}

	func testSolidGreyGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.gradientType = .solidGrey

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .solidGrey)
	}

	func testLightBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.gradientType = .lightBlue

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .lightBlue)
	}

	func testMediumBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.gradientType = .mediumBlue

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .mediumBlue)
	}

	func testDarkBlueGradient() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.gradientType = .darkBlue

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .darkBlue)
	}

}
