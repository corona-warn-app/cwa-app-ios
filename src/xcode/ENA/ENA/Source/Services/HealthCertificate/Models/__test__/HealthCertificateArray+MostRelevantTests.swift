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
		let expiredRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .expired)
		let invalidRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .invalid)

		let mostRecentValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let olderValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 23)
		let expiredRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .expired)
		let invalidRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .invalid)

		let mostRecentProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 17)
		let olderProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 296)
		let expiredRecentProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 15, validityState: .expired)
		let invalidRecentProtectingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 15, validityState: .invalid)

		let mostRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let olderValidRecoveryCertificate = try recoveryCertificate(ageInDays: 180)
		let expiredRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .expired)
		let invalidRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .invalid)

		let mostRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 3)
		let olderSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 14)
		let expiredRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 1, validityState: .expired)
		let invalidRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: true, ageInDays: 1, validityState: .invalid)

		let mostRecentOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 5)
		let olderOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 14)
		let expiredRecentOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 3, validityState: .expired)
		let invalidRecentOtherVaccinationCertificate = try vaccinationCertificate(isCompletingSeries: false, ageInDays: 14, validityState: .invalid)

		let mostRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 185)
		let olderOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 522)
		let expiredRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .expired)
		let invalidRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .invalid)

		let mostRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 48)
		let olderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 1068)
		let expiredRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 48, validityState: .expired)
		let invalidOlderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 48, validityState: .invalid)

		let mostRecentOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 24)
		let olderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 653)
		let expiredOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 24, validityState: .expired)
		let invalidOlderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 24, validityState: .invalid)

		var healthCertificates = [
			mostRecentValidPCRTest,
			olderValidPCRTest,
			expiredRecentPCRTest,
			invalidRecentPCRTest,
			
			mostRecentValidAntigenTest,
			olderValidAntigenTest,
			expiredRecentAntigenTest,
			invalidRecentAntigenTest,
			
			mostRecentProtectingVaccinationCertificate,
			olderProtectingVaccinationCertificate,
			expiredRecentProtectingVaccinationCertificate,
			invalidRecentProtectingVaccinationCertificate,
			
			mostRecentValidRecoveryCertificate,
			olderValidRecoveryCertificate,
			expiredRecentValidRecoveryCertificate,
			invalidRecentValidRecoveryCertificate,
			
			mostRecentSeriesCompletingVaccinationCertificate,
			olderSeriesCompletingVaccinationCertificate,
			expiredRecentSeriesCompletingVaccinationCertificate,
			invalidRecentSeriesCompletingVaccinationCertificate,
			
			mostRecentOtherVaccinationCertificate,
			olderOtherVaccinationCertificate,
			expiredRecentOtherVaccinationCertificate,
			invalidRecentOtherVaccinationCertificate,
			
			mostRecentOutdatedRecoveryCertificate,
			olderOutdatedRecoveryCertificate,
			expiredRecentOutdatedRecoveryCertificate,
			invalidRecentOutdatedRecoveryCertificate,
			
			mostRecentOutdatedPCRTest,
			olderOutdatedPCRTest,
			expiredRecentOutdatedPCRTest,
			invalidOlderOutdatedPCRTest,
			
			mostRecentOutdatedAntigenTest,
			olderOutdatedAntigenTest,
			expiredOutdatedAntigenTest,
			invalidOlderOutdatedAntigenTest
		].shuffled()

		// Valid and Expiring Soon Certificates are the most relevant
		
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
		
		// Expired Certificates are the second most relevant

		healthCertificates.removeAll(where: { $0 == olderOutdatedAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentPCRTest)
		
		healthCertificates.removeAll(where: { $0 == expiredRecentPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentAntigenTest)
		
		healthCertificates.removeAll(where: { $0 == expiredRecentAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == expiredRecentOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredOutdatedAntigenTest)

		// Invalid Certificates are the second most relevant
		
		healthCertificates.removeAll(where: { $0 == expiredOutdatedAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentPCRTest)

		healthCertificates.removeAll(where: { $0 == invalidRecentPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentAntigenTest)

		healthCertificates.removeAll(where: { $0 == invalidRecentAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidOlderOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == invalidOlderOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidOlderOutdatedAntigenTest)

		healthCertificates.removeAll(where: { $0 == invalidOlderOutdatedAntigenTest })
		XCTAssertTrue(healthCertificates.isEmpty)
	}
	// MARK: - Private

	private enum MockError: Error {
		case error(String)
	}

	private func recoveryCertificate(
		ageInDays: Int,
		validityState: HealthCertificateValidityState = .valid
	) throws -> HealthCertificate {
		guard let certificateValidityStartDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedCertificateValidityStartDate = ISO8601DateFormatter.string(from: certificateValidityStartDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				recoveryEntries: [
					RecoveryEntry.fake(
						certificateValidFrom: formattedCertificateValidityStartDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

	private func testCertificate(
		coronaTestType: CoronaTestType,
		ageInHours: Int,
		validityState: HealthCertificateValidityState = .valid
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
			from: DigitalCovidCertificate.fake(
				testEntries: [
					TestEntry.fake(
						typeOfTest: typeOfTest,
						dateTimeOfSampleCollection: formattedSampleCollectionDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

	private func vaccinationCertificate(
		isCompletingSeries: Bool,
		ageInDays: Int,
		validityState: HealthCertificateValidityState = .valid
	) throws -> HealthCertificate {
		let doseNumber = Int.random(in: 1...9)
		let totalSeriesOfDoses = isCompletingSeries ? doseNumber : Int.random(in: (doseNumber + 1)...10)

		guard let vaccinationDate = Calendar.current.date(byAdding: .day, value: -ageInDays, to: Date()) else {
			throw MockError.error("Could not create date")
		}
		let formattedVaccinationDate = ISO8601DateFormatter.string(from: vaccinationDate, timeZone: .current, formatOptions: .withFullDate)

		let base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						doseNumber: doseNumber,
						totalSeriesOfDoses: totalSeriesOfDoses,
						dateOfVaccination: formattedVaccinationDate
					)
				]
			)
		)

		return try HealthCertificate(base45: base45, validityState: validityState)
	}

}
