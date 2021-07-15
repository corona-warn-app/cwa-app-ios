//
// 🦠 Corona-Warn-App
//

import Foundation

struct MockHealthCertificateSignatureVerificationService: HealthCertificateSignatureVerifying {

	let verificationResult: Result<Void, HealthCertificateSignatureVerificationError> = .success(())

	func verifySignature(
		for healthCertificate: HealthCertificate,
		completion: (Result<Void, HealthCertificateSignatureVerificationError>) -> Void
	) {
		completion(verificationResult)
	}

}
