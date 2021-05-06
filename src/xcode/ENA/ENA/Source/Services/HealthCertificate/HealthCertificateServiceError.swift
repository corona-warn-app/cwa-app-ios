////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

extension HealthCertificateService {

	enum RegistrationError: LocalizedError {
		case decodingError(CertificateDecodingError)
		case noVaccinationEntry
		case vaccinationCertificateAlreadyRegistered
		case dateOfBirthMismatch
		case nameMismatch
		case proofRequestError(ProofRequestError)
	}

	enum ProofRequestError: LocalizedError {
		case fetchingError(ProofCertificateFetchingError)
	}

}
