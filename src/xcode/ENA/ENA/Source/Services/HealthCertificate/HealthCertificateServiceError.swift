////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateServiceError {

	enum RegistrationError: LocalizedError {
		case decodingError(CertificateDecodingError)
		case noVaccinationEntry
		case vaccinationCertificateAlreadyRegistered
		case dateOfBirthMismatch
		case nameMismatch
		case other(Error)

		var errorDescription: String? {
			switch self {
			case .decodingError(let decodingError):
				switch decodingError {
				case .HC_BASE45_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_BASE45_DECODING_FAILED)."
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_ZLIB_DECOMPRESSION_FAILED)."
				case .HC_COSE_TAG_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_TAG_INVALID)."
				case .HC_COSE_MESSAGE_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_MESSAGE_INVALID)."
				case .HC_CBOR_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CBOR_DECODING_FAILED)."
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_ISS)."
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_EXP)."
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_HCERT)."
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_DGC)."
				case .HC_JSON_SCHEMA_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_JSON_SCHEMA_INVALID)."
				case .HC_PREFIX_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_PREFIX_INVALID)."
				}
			case .noVaccinationEntry:
				return "\(AppStrings.HealthCertificate.Error.vcNotYetSupported) (VC_NO_VACCINATION_ENTRY)."
			case .vaccinationCertificateAlreadyRegistered:
				return "\(AppStrings.HealthCertificate.Error.vcAlreadyRegistered) (VC_ALREADY_REGISTERED)."
			case .dateOfBirthMismatch:
				return "\(AppStrings.HealthCertificate.Error.vcDifferentPerson) (VC_DOB_MISMATCH)."
			case .nameMismatch:
				return "\(AppStrings.HealthCertificate.Error.vcDifferentPerson) (VC_NAME_MISMATCH)."
			case .other(let error):
				return error.localizedDescription
			}
		}
	}

}
