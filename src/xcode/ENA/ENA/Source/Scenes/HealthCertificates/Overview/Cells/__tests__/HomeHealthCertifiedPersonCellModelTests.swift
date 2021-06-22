////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertifiedPersonCellModelTests: XCTestCase {

	func testGIVEN_healthCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try healthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1
			]
		)
		let viewModel = try XCTUnwrap(HealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson))

		guard case .partiallyVaccinated = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not partiallyVaccinated")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.backgroundGradientType, healthCertifiedPerson.vaccinationState.gradientType)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell)
	}

}

extension XCTestCase {

	enum Base45FakeError: Error {
		case failed
	}

	func base45Fake(from digitalGreenCertificate: DigitalGreenCertificate) throws -> Base45 {
		let base45Result = DigitalGreenCertificateFake.makeBase45Fake(
			from: digitalGreenCertificate,
			and: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result else {
			XCTFail("Could not make fake base45 certificate")
			throw Base45FakeError.failed
		}

		return base45
	}

	func healthCertificate(daysOffset: Int, doseNumber: Int, identifier: String, dateOfBirth: String) throws -> HealthCertificate {
		let date = Date(timeIntervalSinceNow: TimeInterval(24 * 60 * 60 * daysOffset))
		let vaccinationEntry = VaccinationEntry.fake(
			doseNumber: doseNumber,
			dateOfVaccination: ISO8601DateFormatter.justUTCDateFormatter.string(from: date),
			uniqueCertificateIdentifier: identifier
		)

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				dateOfBirth: dateOfBirth,
				vaccinationEntries: [
					vaccinationEntry
				]
			)
		)

		return try HealthCertificate(base45: firstTestCertificateBase45)
	}

}
