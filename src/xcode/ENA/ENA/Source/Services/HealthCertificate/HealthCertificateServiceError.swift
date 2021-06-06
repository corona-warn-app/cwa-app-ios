////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateServiceError {

	enum RegistrationError: LocalizedError {
		case decodingError(CertificateDecodingError)
		case certificateAlreadyRegistered
		case other(Error)

		var errorDescription: String? {
			switch self {
			case .decodingError(let decodingError):
				switch decodingError {
				case .HC_BASE45_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_BASE45_DECODING_FAILED)"
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_ZLIB_DECOMPRESSION_FAILED)"
				case .HC_COSE_TAG_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_TAG_INVALID)"
				case .HC_COSE_MESSAGE_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_MESSAGE_INVALID)"
				case .HC_CBOR_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CBOR_DECODING_FAILED)"
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_ISS)"
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_EXP)"
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_HCERT)"
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_DGC)"
				case .HC_JSON_SCHEMA_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_JSON_SCHEMA_INVALID)"
				case .HC_PREFIX_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_PREFIX_INVALID)"
				case .AES_DECRYPTION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (AES_DECRYPTION_FAILED)"
				}
			case .certificateAlreadyRegistered:
				return "\(AppStrings.HealthCertificate.Error.vcAlreadyRegistered) (VC_ALREADY_REGISTERED)"
			case .other(let error):
				return error.localizedDescription
			}
		}
	}

	enum VaccinationRegistrationError: LocalizedError {
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
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_BASE45_DECODING_FAILED)"
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_ZLIB_DECOMPRESSION_FAILED)"
				case .HC_COSE_TAG_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_TAG_INVALID)"
				case .HC_COSE_MESSAGE_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_COSE_MESSAGE_INVALID)"
				case .HC_CBOR_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CBOR_DECODING_FAILED)"
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_ISS)"
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_EXP)"
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_HCERT)"
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_HC_CWT_NO_DGC)"
				case .HC_JSON_SCHEMA_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_JSON_SCHEMA_INVALID)"
				case .HC_PREFIX_INVALID:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (VC_PREFIX_INVALID)"
				case .AES_DECRYPTION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.vcInvalid) (AES_DECRYPTION_FAILED)"
				}
			case .noVaccinationEntry:
				return "\(AppStrings.HealthCertificate.Error.vcNotYetSupported) (VC_NO_VACCINATION_ENTRY)"
			case .vaccinationCertificateAlreadyRegistered:
				return "\(AppStrings.HealthCertificate.Error.vcAlreadyRegistered) (VC_ALREADY_REGISTERED)."
			case .dateOfBirthMismatch:
				return "\(AppStrings.HealthCertificate.Error.vcDifferentPerson) (VC_DOB_MISMATCH)"
			case .nameMismatch:
				return "\(AppStrings.HealthCertificate.Error.vcDifferentPerson) (VC_NAME_MISMATCH)"
			case .other(let error):
				return error.localizedDescription
			}
		}
	}

	// TODO: Missing localizations!
	enum TestCertificateRequestError: LocalizedError {
		case publicKeyRegistrationFailed(DCCErrors.RegistrationError)
		case certificateRequestFailed(DCCErrors.DigitalCovid19CertificateError)
		case base64DecodingFailed
		case rsaKeyPairGenerationFailed(DCCRSAKeyPairError)
		case decryptionFailed(Error)
		case assemblyFailed(CertificateDecodingError)
		case other(Error)

		var errorDescription: String? {
			switch self {
			case .publicKeyRegistrationFailed(let registrationError):
				switch registrationError {
				case .badRequest:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_400")
				case .tokenNotAllowed:
					// TODO: Final text
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_403")
				case .tokenDoesNotExist:
					// TODO: Final text
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_404")
				case .tokenAlreadyAssigned:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_409")
				case .internalServerError:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_500")
				case .unhandledResponse(let code):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(code)")
				case .defaultServerError(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(error.localizedDescription)")
				case .urlCreationFailed:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_URL_CREATION_FAILED")
				case .noNetworkConnection:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_NO_NETWORK")
				}
			case .certificateRequestFailed(let certificateError):
				switch certificateError {
				case .urlCreationFailed:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_URL_CREATION_FAILED")
				case .unhandledResponse(let code):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(code)")
				case .jsonError:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_JSON_ERROR")
				case .dccPending:
					// TODO: Final text
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_202")
				case .badRequest:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_400")
				case .tokenDoesNotExist:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_404")
				case .dccAlreadyCleanedUp:
					// TODO: Final text
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_410")
				case .testResultNotYetReceived:
					// TODO: Final text
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_412")
				case .internalServerError(reason: let reason):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500_\(String(describing: reason))")
				case .defaultServerError(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(error.localizedDescription)")
				case .noNetworkConnection:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DGC_COMP_NO_NETWORK")
				}
			case .base64DecodingFailed:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DEK_DECODING_FAILED")
			case .rsaKeyPairGenerationFailed(let keyPairError):
				switch keyPairError {
				case .keyPairGenerationFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_KP_GENERATION_FAILED: \(error)")
				case .keychainRetrievalFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_KP_RETRIEVAL_FAILED: \(error)")
				case .gettingDataRepresentationFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_KP_GETTING_DATA_FAILED: \(String(describing: error?.localizedDescription))")
				case .decryptionFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_DECRYPTION_FAILED: \(String(describing: error?.localizedDescription)))")
				}
			case .decryptionFailed(let error):
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_DECRYPTION_FAILED: \(error.localizedDescription)")
			case .assemblyFailed(let decodingError):
				switch decodingError {
				case .HC_BASE45_DECODING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_BASE45_DECODING_FAILED")
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_ZLIB_DECOMPRESSION_FAILED")
				case .HC_COSE_TAG_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_COSE_TAG_INVALID")
				case .HC_COSE_MESSAGE_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_COSE_MESSAGE_INVALID")
				case .HC_CBOR_DECODING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_CBOR_DECODING_FAILED")
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_CWT_NO_ISS")
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_CWT_NO_EXP")
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_CWT_NO_HCERT")
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_CWT_NO_DGC")
				case .HC_JSON_SCHEMA_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_JSON_SCHEMA_INVALID")
				case .HC_PREFIX_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "TC_HC_PREFIX_INVALID")
				case .AES_DECRYPTION_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "AES_DECRYPTION_FAILED")
					// TODO: DGC_COSE_MESSAGE_INVALID, DGC_COSE_TAG_INVALID missing
				}
			case .other(let error):
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, error.localizedDescription)
			}
		}
	}

}
