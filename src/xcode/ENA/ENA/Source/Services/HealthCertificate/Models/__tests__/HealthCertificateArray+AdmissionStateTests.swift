//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateArrayAdmissionStateTests: CWATestCase {

	func testTwoGPlusPCRWithVaccination() throws {
		let validProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16)
		let validPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
		let certificates = try nonValidCertificates() + [validProtectingVaccinationCertificate, validPCRTest]

		XCTAssertEqual(certificates.admissionState, .twoGPlusPCR(twoG: validProtectingVaccinationCertificate, pcrTest: validPCRTest))
	}

	func testTwoGPlusPCRWithRecovery() throws {
		let validRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let validPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
		let certificates = try nonValidCertificates() + [validRecoveryCertificate, validPCRTest]

		XCTAssertEqual(certificates.admissionState, .twoGPlusPCR(twoG: validRecoveryCertificate, pcrTest: validPCRTest))
	}

	func testTwoGPlusAntigenWithVaccination() throws {
		let validProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16)
		let validAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let certificates = try nonValidCertificates() + [validProtectingVaccinationCertificate, validAntigenTest]

		XCTAssertEqual(certificates.admissionState, .twoGPlusAntigen(twoG: validProtectingVaccinationCertificate, antigenTest: validAntigenTest))
	}

	func testTwoGPlusAntigenWithRecovery() throws {
		let validRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let validAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let certificates = try nonValidCertificates() + [validRecoveryCertificate, validAntigenTest]

		XCTAssertEqual(certificates.admissionState, .twoGPlusAntigen(twoG: validRecoveryCertificate, antigenTest: validAntigenTest))
	}

	func testTwoGWithVaccination() throws {
		let validProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16)
		let certificates = try nonValidCertificates() + [validProtectingVaccinationCertificate]

		XCTAssertEqual(certificates.admissionState, .twoG(twoG: validProtectingVaccinationCertificate))
	}

	func testTwoGWithRecovery() throws {
		let validRecoveryCertificate = try recoveryCertificate(ageInDays: 10)
		let certificates = try nonValidCertificates() + [validRecoveryCertificate]

		XCTAssertEqual(certificates.admissionState, .twoG(twoG: validRecoveryCertificate))
	}

	func testThreeGWithPCR() throws {
		let validPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
		let certificates = try nonValidCertificates() + [validPCRTest]

		XCTAssertEqual(certificates.admissionState, .threeGWithPCR)
	}

	func testThreeGWithPCRAndAntigen() throws {
		let validPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 18)
		let validAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let certificates = try nonValidCertificates() + [validPCRTest, validAntigenTest]

		XCTAssertEqual(certificates.admissionState, .threeGWithPCR)
	}

	func testThreeGWithAntigen() throws {
		let validAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2)
		let certificates = try nonValidCertificates() + [validAntigenTest]

		XCTAssertEqual(certificates.admissionState, .threeGWithAntigen)
	}

	func testNoValidCertificate() throws {
		let certificates = try nonValidCertificates()

		XCTAssertEqual(certificates.admissionState, .other)
	}

	// MARK: - Private

	private func nonValidCertificates() throws -> [HealthCertificate] {
		let expiredRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .expired)
		let invalidRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 12, validityState: .invalid)
		let blockedRecentPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 14, validityState: .blocked)

		let expiredRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .expired)
		let invalidRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 1, validityState: .invalid)
		let blockedRecentAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 2, validityState: .blocked)

		let expiredRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 1, validityState: .expired)
		let invalidRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 1, validityState: .invalid)
		let blockedRecentBoosterVaccinationCertificate = try vaccinationCertificate(type: .booster, ageInDays: 2, validityState: .blocked)

		let expiredRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 15, validityState: .expired)
		let invalidRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 15, validityState: .invalid)
		let blockedRecentProtectingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 16, validityState: .blocked)

		let expiredRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .expired)
		let invalidRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 5, validityState: .invalid)
		let blockedRecentValidRecoveryCertificate = try recoveryCertificate(ageInDays: 6, validityState: .blocked)

		let expiredRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 1, validityState: .expired)
		let invalidRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 1, validityState: .invalid)
		let blockedRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 2, validityState: .blocked)

		let expiredRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 3, validityState: .expired)
		let invalidRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 14, validityState: .invalid)
		let blockedRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 15, validityState: .blocked)

		let expiredRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .expired)
		let invalidRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 181, validityState: .invalid)
		let blockedRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 182, validityState: .blocked)

		let expiredRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72, validityState: .expired)
		let invalidOlderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72, validityState: .invalid)
		let blockedOlderOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 73, validityState: .blocked)

		let expiredOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48, validityState: .expired)
		let invalidOlderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48, validityState: .invalid)
		let blockedOlderOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 49, validityState: .blocked)

		let mostRecentSeriesCompletingVaccinationCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 3)
		let mostRecentOtherVaccinationCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 5)
		let mostRecentOutdatedRecoveryCertificate = try recoveryCertificate(ageInDays: 185)
		let mostRecentOutdatedPCRTest = try testCertificate(coronaTestType: .pcr, ageInHours: 72)
		let mostRecentOutdatedAntigenTest = try testCertificate(coronaTestType: .antigen, ageInHours: 48)

		return [
			expiredRecentPCRTest,
			invalidRecentPCRTest,
			blockedRecentPCRTest,

			expiredRecentAntigenTest,
			invalidRecentAntigenTest,
			blockedRecentAntigenTest,

			expiredRecentBoosterVaccinationCertificate,
			invalidRecentBoosterVaccinationCertificate,
			blockedRecentBoosterVaccinationCertificate,

			expiredRecentProtectingVaccinationCertificate,
			invalidRecentProtectingVaccinationCertificate,
			blockedRecentProtectingVaccinationCertificate,

			expiredRecentValidRecoveryCertificate,
			invalidRecentValidRecoveryCertificate,
			blockedRecentValidRecoveryCertificate,

			expiredRecentSeriesCompletingVaccinationCertificate,
			invalidRecentSeriesCompletingVaccinationCertificate,
			blockedRecentSeriesCompletingVaccinationCertificate,

			expiredRecentOtherVaccinationCertificate,
			invalidRecentOtherVaccinationCertificate,
			blockedRecentOtherVaccinationCertificate,

			expiredRecentOutdatedRecoveryCertificate,
			invalidRecentOutdatedRecoveryCertificate,
			blockedRecentOutdatedRecoveryCertificate,

			expiredRecentOutdatedPCRTest,
			invalidOlderOutdatedPCRTest,
			blockedOlderOutdatedPCRTest,

			expiredOutdatedAntigenTest,
			invalidOlderOutdatedAntigenTest,
			blockedOlderOutdatedAntigenTest,

			mostRecentSeriesCompletingVaccinationCertificate,
			mostRecentOtherVaccinationCertificate,
			mostRecentOutdatedRecoveryCertificate,
			mostRecentOutdatedPCRTest,
			mostRecentOutdatedAntigenTest
		]
	}

}
