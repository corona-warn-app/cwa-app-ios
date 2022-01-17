////
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == HealthCertificate {

	// MARK: - Internal

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
		case .test(let testEntry) where testEntry.coronaTestType == .antigen && ageInHours < 48:
			return testEntry.sampleCollectionDate.flatMap {
				Calendar.current.date(byAdding: .hour, value: 48, to: $0)
			}
		case .test(let testEntry) where testEntry.coronaTestType == .pcr && ageInHours < 72:
			return testEntry.sampleCollectionDate.flatMap {
				Calendar.current.date(byAdding: .hour, value: 72, to: $0)
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

	var lastCompleteVaccinationCertificate: HealthCertificate? {
		// 1- we filter all the certificates to get an array with only complete Vaccination Certificates
		let completeVaccinationCertificates = filter {
			guard let vaccinationEntry = $0.vaccinationEntry else {
				return false
			}
			
			return vaccinationEntry.doseNumber >= vaccinationEntry.totalSeriesOfDoses && (
				$0.ageInDays ?? 0 > 14 ||
				vaccinationEntry.isBoosterVaccination ||
				vaccinationEntry.isRecoveredVaccination ||
				vaccinationEntry.doseNumber > vaccinationEntry.totalSeriesOfDoses
			)
		}
		guard let latestCompleteVaccinationCertificateAgeInDays = completeVaccinationCertificates.last?.ageInDays else {
			return nil
		}
		
		// 2- check if there is multiple complete vaccination certificates that have the same ageInDays
		let completeVaccinationCertificatesWithTheSameAgeInDays = completeVaccinationCertificates.filter {
			$0.ageInDays == latestCompleteVaccinationCertificateAgeInDays
		}
		
		// 3- return the certificate with the latest issuedAt date
		return completeVaccinationCertificatesWithTheSameAgeInDays.sorted(by: {
			$0.cborWebTokenHeader.issuedAt < $1.cborWebTokenHeader.issuedAt
		}).max()
	}
	
	var lastValidRecoveryCertificate: HealthCertificate? {
		last {
			guard let ageInDays = $0.ageInDays else {
				return false
			}

			return $0.type == .recovery && ageInDays <= 180
		}
	}

	var currentPCRTestCertificate: HealthCertificate? {
		last {
			guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
				return false
			}

			return coronaTestType == .pcr && ageInHours < 72
		}
	}

	var currentAntigenTestCertificate: HealthCertificate? {
		last {
			guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
				return false
			}

			return coronaTestType == .antigen && ageInHours < 48
		}
	}

	// MARK: - Private

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
		// Valid / Complete Vaccination Certificate

		if let completeVaccinationCertificate = lastCompleteVaccinationCertificate {
			return completeVaccinationCertificate
		}

		// Recovery Certificate <= 180 days

		if let validRecoveryCertificate = lastValidRecoveryCertificate {
			return validRecoveryCertificate
		}

		// PCR Test Certificate < 72 hours

		if let currentPCRTestCertificate = currentPCRTestCertificate {
			return currentPCRTestCertificate
		}

		// RAT Test Certificate < 48 hours

		if let currentAntigenTestCertificate = currentAntigenTestCertificate {
			return currentAntigenTestCertificate
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

		// PCR Test Certificate > 72 hours

		if let outdatedPCRTestCertificate = last(where: { $0.testEntry?.coronaTestType == .pcr }) {
			return outdatedPCRTestCertificate
		}

		// RAT Test Certificate > 48 hours

		if let outdatedAntigenTestCertificate = last(where: { $0.testEntry?.coronaTestType == .antigen }) {
			return outdatedAntigenTestCertificate
		}

		return nil
	}

}
