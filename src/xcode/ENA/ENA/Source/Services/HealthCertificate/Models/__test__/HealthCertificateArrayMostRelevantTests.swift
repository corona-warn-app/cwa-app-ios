//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateArrayMostRelevantTests: CWATestCase {

	func testMostRelevantHealthCertificate() throws {
		let validPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 47)
		let validAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 23)
		let protectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 15)
		let validRecoveryCertificate = try recoveryCertificate(ageInDays: 180)
		let seriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 14)
		let otherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 14)
		let outdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181)
		let outdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 48)
		let outdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 24)

		var healthCertificates = [
			validPCRTest,
			validAntigenTest,
			protectingVaccinationCertificate,
			validRecoveryCertificate,
			seriesCompletingVaccinationCertificate,
			otherVaccinationCertificate,
			outdatedRecoveryCertificate,
			outdatedPCRTest,
			outdatedAntigenTest
		].shuffled()

		XCTAssertEqual(healthCertificates.mostRelevant, validPCRTest)

		healthCertificates.removeAll(where: { $0 == validPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, validAntigenTest)

		healthCertificates.removeAll(where: { $0 == validAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, protectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == protectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, validRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == validRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, seriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == seriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, otherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == otherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, outdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == outdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, outdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == outdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, outdatedAntigenTest)
	}

	// MARK: - Private

	private enum MockError: Error {
		case error(String)
	}

	private func recoveryCertificate(
		ageInDays: Int
	) throws -> HealthCertificate {
		guard let certificateValidityStartDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedCertificateValidityStartDate = ISO8601DateFormatter.string(from: certificateValidityStartDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				recoveryEntries: [
					RecoveryEntry.fake(
						certificateValidFrom: formattedCertificateValidityStartDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45)
	}

	private func testCertificate(
		coronaTestType: CoronaTestType,
		ageInHours: Int
	) throws -> HealthCertificate {
		let typeOfTest: String
		switch coronaTestType {
		case .pcr:
			typeOfTest = TestEntry.pcrTypeString
		case .antigen:
			typeOfTest = TestEntry.antigenTypeString
		}

		guard let sampleCollectionDate = Calendar.current.date(byAdding: .hour, value: -ageInHours, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedSampleCollectionDate = ISO8601DateFormatter.string(from: sampleCollectionDate, timeZone: .current, formatOptions: .withInternetDateTime)

		let base45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				testEntries: [
					TestEntry.fake(
						typeOfTest: typeOfTest,
						dateTimeOfSampleCollection: formattedSampleCollectionDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45)
	}

	private func vaccinationCertificate(
		isCompletingSeries: Bool,
		ageInDays: Int
	) throws -> HealthCertificate {
		let doseNumber = Int.random(in: 1...9)
		let totalSeriesOfDoses = isCompletingSeries ? doseNumber : Int.random(in: (doseNumber + 1)...10)

		guard let vaccinationDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedVaccinationDate = ISO8601DateFormatter.string(from: vaccinationDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						doseNumber: doseNumber,
						totalSeriesOfDoses: totalSeriesOfDoses,
						dateOfVaccination: formattedVaccinationDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45)
	}

}
