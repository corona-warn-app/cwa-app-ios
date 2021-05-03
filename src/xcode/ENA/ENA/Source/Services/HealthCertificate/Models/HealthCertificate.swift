////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct HealthCertificate: Codable, Equatable {

	// MARK: - Init

	init(representations: CertificateRepresentations) throws {
		self.representations = representations

		self.healthCertificateResponse = try JSONDecoder().decode(HealthCertificateResponse.self, from: representations.json)
	}

	// MARK: - Internal

	let representations: CertificateRepresentations

	var version: String {
		healthCertificateResponse.version
	}

	var name: HealthCertificateName {
		healthCertificateResponse.name
	}

	var dateOfBirth: String {
		healthCertificateResponse.dateOfBirth
	}

	var vaccinationCertificates: [VaccinationCertificate] {
		healthCertificateResponse.vaccinationCertificates
	}

	// MARK: - Private

	private let healthCertificateResponse: HealthCertificateResponse

}
