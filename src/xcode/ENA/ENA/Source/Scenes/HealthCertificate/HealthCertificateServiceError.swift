////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

extension HealthCertificateService {

	enum RegistrationError: LocalizedError {
		case vaccinationCertificateAlreadyRegistered
		case dateOfBirthMismatch
		case nameMismatch
		case noVaccinationEntry
	}

	enum ProofRequestError: LocalizedError {
		case networkError
		case serverError
	}

}
