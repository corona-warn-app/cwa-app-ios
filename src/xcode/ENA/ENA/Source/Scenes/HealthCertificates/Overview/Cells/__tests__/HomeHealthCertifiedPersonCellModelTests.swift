////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HomeHealthCertifiedPersonCellModelTests: XCTestCase {

	func testGIVEN_completelyProtectedCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try getHealthCertificate(daysOffset: -35, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try getHealthCertificate(daysOffset: -20, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1,
				healthCertificate2
			]
		)

		let viewModel = HomeHealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson)

		guard case let .completelyProtected(expirationDate) = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not completelyProtected")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.VaccinationCertificate.title)
		XCTAssertEqual(viewModel.backgroundGradientType, healthCertifiedPerson.vaccinationState.gradientType)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.backgroundImage, UIImage(named: "VaccinationCertificate_CompletelyProtected_Background"))
		XCTAssertEqual(viewModel.iconImage, UIImage(named: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertEqual(viewModel.description, String(
						format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.vaccinationValidUntil,
						DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none
						))
		)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell)
	}

	func testGIVEN_partiallyVaccinatedCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try getHealthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1
			]
		)
		let viewModel = HomeHealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson)

		guard case .partiallyVaccinated = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not partiallyVaccinated")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.VaccinationCertificate.title)
		XCTAssertEqual(viewModel.backgroundGradientType, healthCertifiedPerson.vaccinationState.gradientType)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.backgroundImage, UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Background"))
		XCTAssertEqual(viewModel.iconImage, UIImage(named: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertEqual(viewModel.description, AppStrings.HealthCertificate.Overview.VaccinationCertificate.partiallyVaccinated)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell)
	}

	func testGIVEN_fullyVaccinatedCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try getHealthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try getHealthCertificate(daysOffset: -12, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1,
				healthCertificate2
			]
		)
		let viewModel = HomeHealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson)

		guard case let .fullyVaccinated(daysUntilCompleteProtection) = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not fullyVaccinated")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.VaccinationCertificate.title)
		XCTAssertEqual(viewModel.backgroundGradientType, healthCertifiedPerson.vaccinationState.gradientType)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.backgroundImage, UIImage(named: "VaccinationCertificate_FullyVaccinated_Background"))
		XCTAssertEqual(viewModel.iconImage, UIImage(named: "VaccinationCertificate_FullyVaccinated_Icon"))
		XCTAssertEqual(viewModel.description, String(
			format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.daysUntilCompleteProtection,
			daysUntilCompleteProtection
		))
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell)
	}

	// MARK: - Private

	private func getHealthCertificate(daysOffset: Int, doseNumber: Int, identifier: String, dateOfBirth: String) throws -> HealthCertificate {
		let date = Date(timeIntervalSinceNow: TimeInterval(24 * 60 * 60 * daysOffset))
		let vaccinationEntry = VaccinationEntry.fake(
			doseNumber: doseNumber,
			dateOfVaccination: ISO8601DateFormatter.justUTCDateFormatter.string(from: date),
			uniqueCertificateIdentifier: identifier
		)

		let dgcCertificate = DigitalGreenCertificate.fake(
			dateOfBirth: dateOfBirth,
			vaccinationEntries: [
				vaccinationEntry
			]
		)

		guard case let .success(firstBase45) = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		) else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			throw CertificateDecodingError.HC_BASE45_DECODING_FAILED(nil)
		}

		return try HealthCertificate(base45: firstBase45)
	}

}
