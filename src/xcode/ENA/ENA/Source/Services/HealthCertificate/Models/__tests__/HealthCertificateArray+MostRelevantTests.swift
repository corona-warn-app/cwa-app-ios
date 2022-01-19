//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateArrayMostRelevantTests: CWATestCase {
	
	// swiftlint:disable:next function_body_length
	func testMostRelevantHealthCertificate() throws {
		let mostRecentValidPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
   		let olderValidPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 47)
		let expiredRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .expired)
		let invalidRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .invalid)
		let blockedRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 14, validityState: .blocked)

		let mostRecentValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let olderValidAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 23)
		let expiredRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .expired)
		let invalidRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .invalid)
		let blockedRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2, validityState: .blocked)

		let mostRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 10)
		let expiredRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 1, validityState: .expired)
		let invalidRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 1, validityState: .invalid)
		let blockedRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 2, validityState: .blocked)

		let mostRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16)
		let olderProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 30)
		let expiredRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 15, validityState: .expired)
		let invalidRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 15, validityState: .invalid)
		let blockedRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16, validityState: .blocked)

		let mostRecentRecoveryVaccinationCertificate = try vaccinationCertificate(type: .recovery, ageInDays: 45)

		let mostRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let olderValidRecoveryCertificate = try recoveryCertificate(ageInDays: 180)
		let expiredRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .expired)
		let invalidRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .invalid)
		let blockedRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 6, validityState: .blocked)

		let mostRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 3)
		let olderSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 14)
		let expiredRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 1, validityState: .expired)
		let invalidRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 1, validityState: .invalid)
		let blockedRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 2, validityState: .blocked)

		let mostRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 5)
		let olderOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 14)
		let expiredRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 3, validityState: .expired)
		let invalidRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 14, validityState: .invalid)
		let blockedRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 15, validityState: .blocked)

		let mostRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 185)
		let olderOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 522)
		let expiredRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .expired)
		let invalidRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .invalid)
		let blockedRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 182, validityState: .blocked)

		let mostRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72)
		let olderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 1068)
		let expiredRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72, validityState: .expired)
		let invalidOlderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72, validityState: .invalid)
		let blockedOlderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 73, validityState: .blocked)

		let mostRecentOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48)
		let olderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 653)
		let expiredOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48, validityState: .expired)
		let invalidOlderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48, validityState: .invalid)
		let blockedOlderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 49, validityState: .blocked)

		var healthCertificates = [
			mostRecentValidPCRTest,
			olderValidPCRTest,
			expiredRecentPCRTest,
			invalidRecentPCRTest,
			blockedRecentPCRTest,
			
			mostRecentValidAntigenTest,
			olderValidAntigenTest,
			expiredRecentAntigenTest,
			invalidRecentAntigenTest,
			blockedRecentAntigenTest,

			mostRecentBoosterVaccinationCertificate,
			expiredRecentBoosterVaccinationCertificate,
			invalidRecentBoosterVaccinationCertificate,
			blockedRecentBoosterVaccinationCertificate,
			
			mostRecentProtectingVaccinationCertificate,
			olderProtectingVaccinationCertificate,
			expiredRecentProtectingVaccinationCertificate,
			invalidRecentProtectingVaccinationCertificate,
			blockedRecentProtectingVaccinationCertificate,
			
			mostRecentRecoveryVaccinationCertificate,

			mostRecentValidRecoveryCertificate,
			olderValidRecoveryCertificate,
			expiredRecentValidRecoveryCertificate,
			invalidRecentValidRecoveryCertificate,
			blockedRecentValidRecoveryCertificate,
			
			mostRecentSeriesCompletingVaccinationCertificate,
			olderSeriesCompletingVaccinationCertificate,
			expiredRecentSeriesCompletingVaccinationCertificate,
			invalidRecentSeriesCompletingVaccinationCertificate,
			blockedRecentSeriesCompletingVaccinationCertificate,
			
			mostRecentOtherVaccinationCertificate,
			olderOtherVaccinationCertificate,
			expiredRecentOtherVaccinationCertificate,
			invalidRecentOtherVaccinationCertificate,
			blockedRecentOtherVaccinationCertificate,
			
			mostRecentOutdatedRecoveryCertificate,
			olderOutdatedRecoveryCertificate,
			expiredRecentOutdatedRecoveryCertificate,
			invalidRecentOutdatedRecoveryCertificate,
			blockedRecentOutdatedRecoveryCertificate,
			
			mostRecentOutdatedPCRTest,
			olderOutdatedPCRTest,
			expiredRecentOutdatedPCRTest,
			invalidOlderOutdatedPCRTest,
			blockedOlderOutdatedPCRTest,
			
			mostRecentOutdatedAntigenTest,
			olderOutdatedAntigenTest,
			expiredOutdatedAntigenTest,
			invalidOlderOutdatedAntigenTest,
			blockedOlderOutdatedAntigenTest
		].shuffled()

		// Valid and Expiring Soon Certificates are the most relevant

		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentBoosterVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentBoosterVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == olderProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentRecoveryVaccinationCertificate)
		
		healthCertificates.removeAll(where: { $0 == mostRecentRecoveryVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == mostRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == olderValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidPCRTest)

		healthCertificates.removeAll(where: { $0 == mostRecentValidPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidPCRTest)

		healthCertificates.removeAll(where: { $0 == olderValidPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentValidAntigenTest)

		healthCertificates.removeAll(where: { $0 == mostRecentValidAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, olderValidAntigenTest)

		healthCertificates.removeAll(where: { $0 == olderValidAntigenTest })
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
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentBoosterVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentBoosterVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentPCRTest)

		healthCertificates.removeAll(where: { $0 == expiredRecentPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentAntigenTest)

		healthCertificates.removeAll(where: { $0 == expiredRecentAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == expiredRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredRecentOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == expiredRecentOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, expiredOutdatedAntigenTest)

		// Invalid Certificates are the least relevant
		
		healthCertificates.removeAll(where: { $0 == expiredOutdatedAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentBoosterVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentBoosterVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentBoosterVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentBoosterVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentProtectingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentProtectingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentValidRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentValidRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentPCRTest)

		healthCertificates.removeAll(where: { $0 == invalidRecentPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentPCRTest)

		healthCertificates.removeAll(where: { $0 == blockedRecentPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentAntigenTest)

		healthCertificates.removeAll(where: { $0 == invalidRecentAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentAntigenTest)

		healthCertificates.removeAll(where: { $0 == blockedRecentAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentSeriesCompletingVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentSeriesCompletingVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentOtherVaccinationCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentOtherVaccinationCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == invalidRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedRecentOutdatedRecoveryCertificate)

		healthCertificates.removeAll(where: { $0 == blockedRecentOutdatedRecoveryCertificate })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidOlderOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == invalidOlderOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedOlderOutdatedPCRTest)

		healthCertificates.removeAll(where: { $0 == blockedOlderOutdatedPCRTest })
		XCTAssertEqual(healthCertificates.mostRelevant, invalidOlderOutdatedAntigenTest)

		healthCertificates.removeAll(where: { $0 == invalidOlderOutdatedAntigenTest })
		XCTAssertEqual(healthCertificates.mostRelevant, blockedOlderOutdatedAntigenTest)

		healthCertificates.removeAll(where: { $0 == blockedOlderOutdatedAntigenTest })
		XCTAssertTrue(healthCertificates.isEmpty)
	}

	func testMostRelevantHealthCertificateWithSameDate() throws {
		let today = Date()
		
		let issueDate1 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 2, to: today))
		let firstHeader = CBORWebTokenHeader.fake(issuer: "test1", issuedAt: issueDate1, expirationTime: Date())

		let issueDate2 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 5, to: today))
		let secondHeader = CBORWebTokenHeader.fake(issuer: "test2", issuedAt: issueDate2, expirationTime: Date())

		let mostRecentSeriesCompletingVaccinationCertificate1 = try vaccinationCertificate(type: .booster, ageInDays: 3, cborWebTokenHeader: firstHeader)
		let mostRecentSeriesCompletingVaccinationCertificate2 = try vaccinationCertificate(type: .booster, ageInDays: 3, cborWebTokenHeader: secondHeader)
		let mostRecentSeriesCompletingVaccinationCertificate3 = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 8)
		let mostRecentSeriesCompletingVaccinationCertificate4 = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 21)
		
		let healthCertificates = [
			mostRecentSeriesCompletingVaccinationCertificate1,
			mostRecentSeriesCompletingVaccinationCertificate2,
			mostRecentSeriesCompletingVaccinationCertificate3,
			mostRecentSeriesCompletingVaccinationCertificate4
			].shuffled()
		
		XCTAssertEqual(healthCertificates.mostRelevant, mostRecentSeriesCompletingVaccinationCertificate2)
	}
}
