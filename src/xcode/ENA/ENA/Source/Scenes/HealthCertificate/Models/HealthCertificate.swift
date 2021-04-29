////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificate: Codable, Equatable {

	// MARK: - Internal

	let representations: HealthCertificateRepresentations

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
