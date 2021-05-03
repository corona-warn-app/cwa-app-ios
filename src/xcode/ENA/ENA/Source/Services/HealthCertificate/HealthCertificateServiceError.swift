////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

extension HealthCertificateService {

	enum RegistrationError: LocalizedError {
		case decodingError(HealthCertificateDecodingError)
		case jsonDecodingError(Error)
		case noVaccinationEntry
		case vaccinationCertificateAlreadyRegistered
		case dateOfBirthMismatch
		case nameMismatch
	}

	enum ProofRequestError: LocalizedError {
		case fetchingError(ProofCertificateFetchingError)
		case jsonDecodingError(Error)
	}

}
