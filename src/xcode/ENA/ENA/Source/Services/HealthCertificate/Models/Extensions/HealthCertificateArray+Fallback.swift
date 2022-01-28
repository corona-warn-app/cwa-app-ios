////
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == HealthCertificate {

	// MARK: - Internal

	var fallback: HealthCertificate? {
		let sortedCertificates = sorted(by: >)

		let sortedValidCertificates = sortedCertificates
			.filter {
				$0.validityState == .valid || $0.validityState == .expiringSoon
			}

		let mostRecentVaccinationOrRecoveryCertificate = sortedValidCertificates
			.first {
				$0.type == .vaccination || $0.type == .recovery
			}

		return mostRecentVaccinationOrRecoveryCertificate ?? sortedValidCertificates.first ?? sortedCertificates.first
	}

}
