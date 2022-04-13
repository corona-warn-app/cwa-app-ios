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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let cclService = FakeCCLService()

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithSoonExpiringVaccinationCertificate() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				),
				webTokenHeader: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		// Not setting dccWalletInfo.verification here to check that the fallback certificate is used if it's not set

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		// Not setting dccWalletInfo.verification here to check that the fallback certificate is used if it's not set

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson, cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithSoonExpiringTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				),
				webTokenHeader: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		// Not setting dccWalletInfo.verification here to check that the fallback certificate is used if it's not set

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson, cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithExpiredTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithInvalidTestCertificate() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

		XCTAssertNil(viewModel.caption)
	}

	func testHealthCertifiedPersonWithSoonExpiringRecoveryCertificate() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				),
				webTokenHeader: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		// Not setting dccWalletInfo.verification here to check that the fallback certificate is used if it's not set

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			verification: .fake(
				certificates: [.fake(certificateRef: .fake(barcodeData: healthCertificate.base45))]
			)
		)

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let cclService = FakeCCLService()
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		// Not setting dccWalletInfo.verification here to check that the fallback certificate is used if it's not set

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)

		XCTAssertFalse(viewModel.isStatusTitleVisible)
		XCTAssertNil(viewModel.shortStatus)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)

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
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			isNew: true
		)

		let secondHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expired,
			isValidityStateNew: true
		)

		let thirdHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			isNew: false,
			isValidityStateNew: false
		)

		let fourthHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
				digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			dccWalletInfo: .fake(
				boosterNotification: .fake(
					identifier: "BoosterRule"
				)
			),
			isNewBoosterRule: true
		)

		let cclService = FakeCCLService()

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let viewModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		// THEN
		XCTAssertNil(viewModel.caption)
	}

	func testAdmissionStateWithBadgeAndOneCertificateToShow() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try testCertificate(type: .antigen)]
		)
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "1G+Z")),
			verification: .fake(certificates: [])
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertEqual(cellModel.shortStatus, "1G+Z")
	}

	func testAdmissionStateWithBadgeAndTwoCertificatesToShow() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .antigen)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "2G+Y")),
			verification: .fake(
				certificates: [
					.fake(
						buttonText: .fake(string: "2G-Zertifikat"),
						certificateRef: .fake(barcodeData: twoGCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Testzertifikat"),
						certificateRef: .fake(barcodeData: testCertificate.base45)
					)
				]
			)
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertEqual(
			cellModel.switchableHealthCertificates,
			["2G-Zertifikat": twoGCertificate, "Testzertifikat": testCertificate]
		)
		XCTAssertEqual(cellModel.shortStatus, "2G+Y")
	}

	func testAdmissionStateWithBadgeAndThreeCertificatesToShow() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .antigen)
		let thirdCertificate = try vaccinationCertificate(daysOffset: -5, doseNumber: 1, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate, thirdCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "2G+Y")),
			verification: .fake(
				certificates: [
					.fake(
						buttonText: .fake(string: "2G-Zertifikat"),
						certificateRef: .fake(barcodeData: twoGCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Testzertifikat"),
						certificateRef: .fake(barcodeData: testCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Drittes Zertifikat"),
						certificateRef: .fake(barcodeData: thirdCertificate.base45)
					)
				]
			)
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertEqual(
			cellModel.switchableHealthCertificates,
			["2G-Zertifikat": twoGCertificate, "Testzertifikat": testCertificate, "Drittes Zertifikat": thirdCertificate]
		)
		XCTAssertEqual(cellModel.shortStatus, "2G+Y")
	}

	func testFourthCertificateIsNotShown() throws {
		let twoGCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 2, totalSeriesOfDoses: 2)
		let testCertificate = try testCertificate(daysOffset: -1, type: .antigen)
		let thirdCertificate = try vaccinationCertificate(daysOffset: -5, doseNumber: 1, totalSeriesOfDoses: 2)
		let fourthCertificate = try vaccinationCertificate(daysOffset: -16, doseNumber: 0, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [twoGCertificate, testCertificate, thirdCertificate, fourthCertificate])
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "2G+Y")),
			verification: .fake(
				certificates: [
					.fake(
						buttonText: .fake(string: "2G-Zertifikat"),
						certificateRef: .fake(barcodeData: twoGCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Testzertifikat"),
						certificateRef: .fake(barcodeData: testCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Drittes Zertifikat"),
						certificateRef: .fake(barcodeData: thirdCertificate.base45)
					),
					.fake(
						buttonText: .fake(string: "Viertes Zertifikat"),
						certificateRef: .fake(barcodeData: fourthCertificate.base45)
					)
				]
			)
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertTrue(cellModel.isStatusTitleVisible)
		XCTAssertEqual(
			cellModel.switchableHealthCertificates,
			["2G-Zertifikat": twoGCertificate, "Testzertifikat": testCertificate, "Drittes Zertifikat": thirdCertificate]
		)
		XCTAssertEqual(cellModel.shortStatus, "2G+Y")
	}

	func testWithoutAdmissionState() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: false),
			verification: .fake(certificates: [])
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.qrCodeViewModel.covPassCheckInfoPosition, .bottom)
		XCTAssertFalse(cellModel.isStatusTitleVisible)
		XCTAssertTrue(cellModel.switchableHealthCertificates.isEmpty)
		XCTAssertNil(cellModel.shortStatus)
	}

	func testWithEmptyAdmissionState() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [try vaccinationCertificate()]
		)
		healthCertifiedPerson.dccWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "")),
			verification: .fake(certificates: [])
		)

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
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

		let cclService = FakeCCLService()

		let cellModel = try XCTUnwrap(
			HealthCertifiedPersonCellModel(
				healthCertifiedPerson: healthCertifiedPerson,
				cclService: cclService,
				onCovPassCheckInfoButtonTap: { }
			)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .darkBlue)
	}

}
