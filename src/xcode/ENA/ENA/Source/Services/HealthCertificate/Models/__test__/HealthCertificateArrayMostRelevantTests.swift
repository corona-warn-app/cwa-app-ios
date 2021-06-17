//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateArrayMostRelevantTests: CWATestCase {

	func testMostRelevantHealthCertificate() throws {
		let mostRecentValidPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
		let olderValidPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 47)

		let mostRecentValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let olderValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 23)

		let mostRecentProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 15)
		let olderProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 296)

		let mostRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let olderValidRecoveryCertificate = try recoveryCertificate(ageInDays: 180)

		let mostRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 3)
		let olderSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 14)

		let mostRecentOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 5)
		let olderOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 14)

		let mostRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181)
		let olderOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 522)

		let mostRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 48)
		let olderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 1068)

		let mostRecentOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 24)
		let olderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 653)

		var healthCertificates = [
			mostRecentValidPCRTest,
			olderValidPCRTest,
			mostRecentValidAntigenTest,
			olderValidAntigenTest,
			mostRecentProtectingVaccinationCertificate,
			olderProtectingVaccinationCertificate,
			mostRecentValidRecoveryCertificate,
			olderValidRecoveryCertificate,
			mostRecentSeriesCompletingVaccinationCertificate,
			olderSeriesCompletingVaccinationCertificate,
			mostRecentOtherVaccinationCertificate,
			olderOtherVaccinationCertificate,
			mostRecentOutdatedRecoveryCertificate,
			olderOutdatedRecoveryCertificate,
			mostRecentOutdatedPCRTest,
			olderOutdatedPCRTest,
			mostRecentOutdatedAntigenTest,
			olderOutdatedAntigenTest
		].shuffled()

		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidPCRTest)

		healthCertificates.removeAll(where: { $0 == mostRecentValidPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidPCRTest)

		healthCertificates.removeAll(where: { $0 == olderValidPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidAntigenTest)

		healthCertificates.removeAll(where: { $0 == mostRecentValidAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidAntigenTest)

		healthCertificates.removeAll(where: { $0 == olderValidAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == olderProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == olderValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == olderSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == olderOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == olderOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == mostRecentOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == olderOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentOutdatedAntigenTest)

		healthCertificates.removeAll(where: { $0 == mostRecentOutdatedAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderOutdatedAntigenTest)
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
