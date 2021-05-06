////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HealthCertifiedPerson: OpenCombine.ObservableObject, Codable, Equatable {

	// MARK: - Init

	init(healthCertificates: [HealthCertificate], proofCertificate: ProofCertificate?) {
		self.healthCertificates = healthCertificates
		self.proofCertificate = proofCertificate
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case healthCertificates
		case proofCertificate
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		healthCertificates = try container.decode([HealthCertificate].self, forKey: .healthCertificates)
		proofCertificate = try container.decode(ProofCertificate.self, forKey: .proofCertificate)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(healthCertificates, forKey: .healthCertificates)
		try container.encode(proofCertificate, forKey: .proofCertificate)
	}

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertifiedPerson, rhs: HealthCertifiedPerson) -> Bool {
		lhs.proofCertificate == rhs.proofCertificate && lhs.healthCertificates == rhs.healthCertificates
	}

	// MARK: - Internal

	@OpenCombine.Published var healthCertificates: [HealthCertificate]
	@OpenCombine.Published var proofCertificate: ProofCertificate?

}
