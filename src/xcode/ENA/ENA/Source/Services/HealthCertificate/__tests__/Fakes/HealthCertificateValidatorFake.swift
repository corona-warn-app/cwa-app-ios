//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class HealthCertificateValidatorFake: HealthCertificateValidating {
	func isRevokedFromRevocationList(healthCertificate: HealthCertificate) -> Bool {
		false
	}
}
