////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificateResponse: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case version = "ver"
		case name = "nam"
		case dateOfBirth = "dob"
		case vaccinationCertificates = "v"
	}

	// MARK: - Internal

	let version: String
	let name: HealthCertificateName
	let dateOfBirth: String
	let vaccinationCertificates: [VaccinationCertificate]

}
