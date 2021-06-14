////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HomeHealthCertifiedPersonCellModelTests: XCTestCase {

	func testGIVEN_completelyProtectedCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try healthCertificate(daysOffset: -35, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try healthCertificate(daysOffset: -20, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

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
		let healthCertificate1 = try healthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

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
		let healthCertificate1 = try healthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try healthCertificate(daysOffset: -12, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

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

	func testGIVEN_testCertificate_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "TEUBER", standardizedGivenName: "KAI"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		let testCertificate = try HealthCertificate(base45: firstTestCertificateBase45)

		let viewModel = HomeHealthCertifiedPersonCellModel(testCertificate: testCertificate)
		let sampleCollectionDate = try XCTUnwrap(testCertificate.testEntry?.sampleCollectionDate)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.TestCertificate.title)
		XCTAssertEqual(viewModel.backgroundGradientType, .green)
		XCTAssertEqual(viewModel.name, testCertificate.name.fullName)
		XCTAssertEqual(viewModel.backgroundImage, UIImage(named: "TestCertificate_Background"))
		XCTAssertEqual(viewModel.iconImage, UIImage(named: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.description, String(
			format: AppStrings.HealthCertificate.Overview.TestCertificate.testDate,
			DateFormatter.localizedString(from: sampleCollectionDate, dateStyle: .medium, timeStyle: .short)
		))
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell)
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
