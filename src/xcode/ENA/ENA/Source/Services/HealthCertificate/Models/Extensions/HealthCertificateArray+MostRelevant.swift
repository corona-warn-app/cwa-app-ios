////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

extension Array where Element == HealthCertificate {

	var mostRelevant: HealthCertificate? {
		let sortedHealthCertificates = sorted()

		// PCR Test Certificate < 48 hours

		let currentPCRTest = sortedHealthCertificates
			.last {
				guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
					return false
				}

				return coronaTestType == .pcr && ageInHours < 48
			}

		if let currentPCRTest = currentPCRTest {
			return currentPCRTest
		}

		// RAT Test Certificate < 24 hours

		let currentAntigenTest = sortedHealthCertificates
			.last {
				guard let coronaTestType = $0.testEntry?.coronaTestType, let ageInHours = $0.ageInHours else {
					return false
				}

				return coronaTestType == .antigen && ageInHours < 24
			}

		if let currentAntigenTest = currentAntigenTest {
			return currentAntigenTest
		}

		// Series-completing Vaccination Certificate > 14 days

		let protectingVaccinationCertificate = sortedHealthCertificates
			.last {
				guard let isLastDoseInASeries = $0.vaccinationEntry?.isLastDoseInASeries, let ageInDays = $0.ageInDays else {
					return false
				}

				return isLastDoseInASeries && ageInDays > 14
			}

		if let protectingVaccinationCertificate = protectingVaccinationCertificate {
			return protectingVaccinationCertificate
		}

		// Recovery Certificate <= 180 days

		let validRecoveryCertificate = sortedHealthCertificates
			.last {
				guard let ageInDays = $0.ageInDays else {
					return false
				}

				return $0.type == .recovery && ageInDays <= 180
			}

		if let validRecoveryCertificate = validRecoveryCertificate {
			return validRecoveryCertificate
		}

		// Series-completing Vaccination Certificate <= 14 days

		let seriesCompletingVaccinationCertificate = sortedHealthCertificates
			.last {
				guard let isLastDoseInASeries = $0.vaccinationEntry?.isLastDoseInASeries, let ageInDays = $0.ageInDays else {
					return false
				}

				return isLastDoseInASeries && ageInDays <= 14
			}

		if let seriesCompletingVaccinationCertificate = seriesCompletingVaccinationCertificate {
			return seriesCompletingVaccinationCertificate
		}

		// Other Vaccination Certificate

		if let otherVaccinationCertificate = sortedHealthCertificates.last(where: { $0.type == .vaccination }) {
			return otherVaccinationCertificate
		}

		// Recovery Certificate > 180 days

		if let otherRecoveryCertificate = sortedHealthCertificates.last(where: { $0.type == .recovery }) {
			return otherRecoveryCertificate
		}

		// PCR Test Certificate > 48 hours

		if let otherPCRTestCertificate = sortedHealthCertificates.last(where: { $0.testEntry?.coronaTestType == .pcr }) {
			return otherPCRTestCertificate
		}

		// RAT Test Certificate > 24 hours

		if let otherAntigenTestCertificate = sortedHealthCertificates.last(where: { $0.testEntry?.coronaTestType == .antigen }) {
			return otherAntigenTestCertificate
		}

		// Fallback

		return first
	}

}
