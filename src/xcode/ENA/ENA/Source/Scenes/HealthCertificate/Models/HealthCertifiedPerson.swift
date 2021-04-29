////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HealthCertifiedPerson: OpenCombine.ObservableObject, Codable, Equatable {

	init(proofCertificate: ProofCertificate?, healthCertificates: [HealthCertificate]) {
		self.proofCertificate = proofCertificate
		self.healthCertificates = healthCertificates
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case proofCertificate
		case healthCertificates
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		proofCertificate = try container.decode(ProofCertificate.self, forKey: .proofCertificate)
		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(proofCertificate, forKey: .proofCertificate)
		try container.encode(healthCertificates, forKey: .healthCertificates)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.proofCertificate == rhs.proofCertificate && lhs.healthCertificates == rhs.healthCertificates
	}

	// MARK: - Internal

	@OpenCombine.Published var proofCertificate: ProofCertificate?
	@OpenCombine.Published var healthCertificates: [HealthCertificate]

}
