////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct ProofCertificate: Codable, Equatable {

	// MARK: - Init

	init(representations: CertificateRepresentations) throws {
		self.representations = representations

		self.proofCertificateResponse = try JSONDecoder().decode(ProofCertificateResponse.self, from: representations.json)
	}

	// MARK: - Internal

	let representations: CertificateRepresentations

	var expirationDate: Date {
		proofCertificateResponse.expirationDate
	}

	// MARK: - Private

	private let proofCertificateResponse: ProofCertificateResponse

}
