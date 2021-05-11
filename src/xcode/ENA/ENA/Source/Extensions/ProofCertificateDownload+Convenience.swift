////
// 🦠 Corona-Warn-App
//

import HealthCertificateToolkit
import Foundation

extension ProofCertificateDownload {

	func fetchProofCertificate(
		for healthCertificates: [Base45],
		completion: @escaping (Result<Base45?, ProofCertificateFetchingError>) -> Void
	) {
		let pinningKeyHash = Environments().currentEnvironment().healthCertificatePinningKeyHash
		let session = URLSession.coronaWarnSession(
			pinningKeyHash: pinningKeyHash,
			configuration: .coronaWarnSessionConfiguration()
		)
		fetchProofCertificate(
			for: healthCertificates,
			baseURL: Environments().currentEnvironment().healthCertificateProofURL,
			urlSession: session,
			completion: completion
		)
	}
}
