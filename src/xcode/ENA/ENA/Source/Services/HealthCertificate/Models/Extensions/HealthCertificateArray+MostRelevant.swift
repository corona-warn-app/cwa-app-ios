////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

extension Array where Element == HealthCertificate {

	var nextMostRelevantChangeDate: Date? {
		guard let mostRelevant = mostRelevant,
			  let ageInHours = mostRelevant.ageInHours,
			  let ageInDays = mostRelevant.ageInDays else {
			return nil
		}

		switch mostRelevant.entry {
		case .vaccination(let vaccinationEntry) where vaccinationEntry.isLastDoseInASeries && ageInDays <= 14:
			return vaccinationEntry.localVaccinationDate.flatMap {
				Calendar.current.date(byAdding: .day, value: 15, to: $0)
			}
		case .test(let testEntry) where testEntry.coronaTestType == .antigen && ageInHours < 24:
			return testEntry.sampleCollectionDate.flatMap {
				Calendar.current.date(byAdding: .hour, value: 24, to: $0)
			}
		case .test(let testEntry) where testEntry.coronaTestType == .pcr && ageInHours < 48:
			return testEntry.sampleCollectionDate.flatMap {
				Calendar.current.date(byAdding: .hour, value: 48, to: $0)
			}
		case .recovery(let recoveryEntry):
			return recoveryEntry.localCertificateValidityStartDate.flatMap {
				Calendar.current.date(byAdding: .day, value: 181, to: $0)
			}
		default:
			return nil
		}
	}

	var mostRelevant: HealthCertificate? {
		mostRelevantValidOrExpiringSoon ?? mostRelevantExpired ?? mostRelevantInvalidOrBlocked ?? first
	}

	private var mostRelevantValidOrExpiringSoon: HealthCertificate? {
		sorted()
			.filter {
				$0.validityState == .valid || $0.validityState == .expiringSoon
			}
			.mostRelevantIgnoringValidityState
	}

	private var mostRelevantExpired: HealthCertificate? {
		sorted()
			.filter {
				$0.validityState == .expired
			}
			.mostRelevantIgnoringValidityState
	}

	private var mostRelevantInvalidOrBlocked: HealthCertificate? {
		sorted()
			.filter {
				$0.validityState == .invalid || $0.validityState == .blocked
			}
			.mostRelevantIgnoringValidityState
	}
	
	private var mostRelevantIgnoringValidityState: HealthCertificate? {
		// PCR Test Certificate < 48 hours

		let currentPCRTestCertificate = last {
			guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
				return false
			}
			
			return coronaTestType == .pcr && ageInHours < 48
		}

		if let currentPCRTestCertificate = currentPCRTestCertificate {
			return currentPCRTestCertificate
		}

		// RAT Test Certificate < 24 hours

		let currentAntigenTestCertificate = last {
			guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
				return false
			}
			
			return coronaTestType == .antigen && ageInHours < 24
		}

		if let currentAntigenTestCertificate = currentAntigenTestCertificate {
			return currentAntigenTestCertificate
		}
		
		// Valid / Complete Vaccination Certificate
		
		// Booster (3/3) on Biontech, Moderna, Astra (2/2) -> gets priority
		// Booster (2/2) on J&J (1/1) -> gets priority

		// Booster with Moderna, Biontech, Astra (2/2) after Recovery Vaccination (1/1) -> gets priority after 14 days
		// Booster with Moderna, Biontech, Astra (2/2) after J&J (1/1) -> gets priority after 14 days

		// Vaccination with Moderna, Biontech, Astra (1/1) after recovery -> gets priority
		// Vaccination with J&J (1/1) after recovery -> get priority after 14 days

		if let completeVaccinationCertificate = last(where: {
			guard let vaccinationEntry = $0.vaccinationEntry else {
				return false
			}
			return vaccinationEntry.doseNumber >= vaccinationEntry.totalSeriesOfDoses && (
				$0.ageInDays ?? 0 > 14 ||
				vaccinationEntry.isBoosterVaccination ||
				vaccinationEntry.isRecoveredVaccination)
		}) {
			return completeVaccinationCertificate
		}

		// Recovery Certificate <= 180 days

		let validRecoveryCertificate = last {
			guard let ageInDays = $0.ageInDays else {
				return false
			}
			
			return $0.type == .recovery && ageInDays <= 180
		}

		if let validRecoveryCertificate = validRecoveryCertificate {
			return validRecoveryCertificate
		}

		// Series-completing Vaccination Certificate <= 14 days

		let seriesCompletingVaccinationCertificate = last {
			guard let isLastDoseInASeries = $0.vaccinationEntry?.isLastDoseInASeries, let ageInDays = $0.ageInDays else {
				return false
			}
			
			return isLastDoseInASeries && ageInDays <= 14
		}

		if let seriesCompletingVaccinationCertificate = seriesCompletingVaccinationCertificate {
			return seriesCompletingVaccinationCertificate
		}

		// Other Vaccination Certificate

		if let otherVaccinationCertificate = last(where: { $0.type == .vaccination }) {
			return otherVaccinationCertificate
		}

		// Recovery Certificate > 180 days

		if let outdatedRecoveryCertificate = last(where: { $0.type == .recovery }) {
			return outdatedRecoveryCertificate
		}

		// PCR Test Certificate > 48 hours

		if let outdatedPCRTestCertificate = last(where: { $0.testEntry?.coronaTestType == .pcr }) {
			return outdatedPCRTestCertificate
		}

		// RAT Test Certificate > 24 hours

		if let outdatedAntigenTestCertificate = last(where: { $0.testEntry?.coronaTestType == .antigen }) {
			return outdatedAntigenTestCertificate
		}

		return nil
	}
}
