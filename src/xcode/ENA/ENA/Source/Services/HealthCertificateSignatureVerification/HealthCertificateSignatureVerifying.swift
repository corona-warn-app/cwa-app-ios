//
// 🦠 Corona-Warn-App
//

import Foundation

protocol HealthCertificateSignatureVerifying {

	func verifySignature(
		for healthCertificate: HealthCertificate,
		completion: (Result<Void, HealthCertificateSignatureVerificationError>) -> Void
	)

}
