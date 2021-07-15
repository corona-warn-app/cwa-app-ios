//
// 🦠 Corona-Warn-App
//

import Foundation

protocol HealthCertificateValidityStateProviding {

	func determineValidityState(
		for healthCertificate: HealthCertificate,
		completion: (HealthCertificateValidityState) -> Void
	)

}
