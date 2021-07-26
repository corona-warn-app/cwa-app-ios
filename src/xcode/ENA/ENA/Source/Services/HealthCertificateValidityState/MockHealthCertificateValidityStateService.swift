//
// 🦠 Corona-Warn-App
//

import Foundation

struct MockHealthCertificateValidityStateService: HealthCertificateValidityStateProviding {

	let validityState: HealthCertificateValidityState = .valid

	func determineValidityState(
		for healthCertificate: HealthCertificate,
		completion: (HealthCertificateValidityState) -> Void
	) {
		completion(validityState)
	}

	func scheduleUserNotificationsIfNecessary() {

	}

}
