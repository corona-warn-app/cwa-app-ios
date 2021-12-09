////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateServiceError: Error {

	enum RegistrationError: LocalizedError {
		case decodingError(CertificateDecodingError)
		case certificateAlreadyRegistered(HealthCertificate.CertificateType)
		case certificateHasTooManyEntries
		case tooManyPersonsRegistered
		case invalidSignature(DCCSignatureVerificationError)
		case other(Error)

		var errorDescription: String? {
			switch self {
			case .decodingError(let decodingError):
				switch decodingError {
				case .HC_BASE45_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_BASE45_DECODING_FAILED)"
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_ZLIB_DECOMPRESSION_FAILED)"
				case .HC_COSE_TAG_OR_ARRAY_INVALID:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_TAG_OR_ARRAY_INVALID)"
				case .HC_COSE_MESSAGE_INVALID:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_MESSAGE_INVALID)"
				case .HC_COSE_NO_KEYIDENTIFIER:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_NO_KEYIDENTIFIER)"
				case .HC_CBOR_DECODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CBOR_DECODING_FAILED)"
				case .HC_CBOR_TRIMMING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CBOR_TRIMMING_FAILED)"
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CWT_NO_ISS)"
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CWT_NO_EXP)"
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CWT_NO_HCERT)"
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_CWT_NO_DGC)"
				case .HC_JSON_SCHEMA_INVALID:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (JSON_SCHEMA_INVALID)"
				case .HC_PREFIX_INVALID:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_PREFIX_INVALID)"
				case .AES_DECRYPTION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (AES_DECRYPTION_FAILED)"
				case .HC_BASE45_ENCODING_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcQRCodeError) (HC_BASE45_ENCODING_FAILED)"
				case .HC_ZLIB_COMPRESSION_FAILED:
					return "\(AppStrings.HealthCertificate.Error.hcQRCodeError) (HC_ZLIB_COMPRESSION_FAILED)"
				}
			case .certificateAlreadyRegistered(let certificateType):
				switch certificateType {
				case .vaccination:
					return "\(AppStrings.HealthCertificate.Error.hcAlreadyRegistered) (VC_ALREADY_REGISTERED)"
				case .test:
					return "\(AppStrings.HealthCertificate.Error.hcAlreadyRegistered) (TC_ALREADY_REGISTERED)"
				case .recovery:
					return "\(AppStrings.HealthCertificate.Error.hcAlreadyRegistered) (RC_ALREADY_REGISTERED)"
				}
			case .certificateHasTooManyEntries:
				return "\(AppStrings.HealthCertificate.Error.hcNotSupported) (HC_TOO_MANY_ENTRIES)"
			case .tooManyPersonsRegistered:
				return AppStrings.UniversalQRScanner.MaxPersonAmountAlert.message
			case .invalidSignature(let error):
				return "\(AppStrings.HealthCertificate.Error.invalidSignatureText) (\(error))"
			case .other(let error):
				return error.localizedDescription

			}
		}

		var errorTitle: String? {
			switch self {
			case .invalidSignature:
				return AppStrings.HealthCertificate.Error.invalidSignatureTitle
			default:
				return nil
			}
		}
	}

	enum TestCertificateRequestError: LocalizedError {
		case publicKeyRegistrationFailed(DCCErrors.RegistrationError)
		case certificateRequestFailed(DCCErrors.DigitalCovid19CertificateError)
		case base64DecodingFailed
		case rsaKeyPairGenerationFailed(DCCRSAKeyPairError)
		case decryptionFailed(Error)
		case assemblyFailed(CertificateDecodingError)
		case registrationError(HealthCertificateServiceError.RegistrationError)
		case dgcNotSupportedByLab
		case other(Error)

		var errorDescription: String? {
			switch self {
			case .publicKeyRegistrationFailed(let registrationError):
				switch registrationError {
				case .badRequest:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "PKR_400")
				case .tokenNotAllowed:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "PKR_403")
				case .tokenDoesNotExist:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "PKR_404")
				case .tokenAlreadyAssigned:
					// Not returned to the user, next request is started automatically
					return nil
				case .internalServerError:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_500")
				case .unhandledResponse(let code):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(code)")
				case .defaultServerError(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(error.localizedDescription)")
				case .urlCreationFailed:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_URL_CREATION_FAILED")
				case .noNetworkConnection:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.noNetwork, "PKR_NO_NETWORK")
				}
			case .certificateRequestFailed(let certificateError):
				switch certificateError {
				case .urlCreationFailed:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_URL_CREATION_FAILED")
				case .unhandledResponse(let code):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(code))")
				case .jsonError:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_JSON_ERROR")
				case .dccPending:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgainDCCNotAvailableYet, "DCC_COMP_202")
				case .badRequest:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "DCC_COMP_400")
				case .tokenDoesNotExist:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_404")
				case .dccAlreadyCleanedUp:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.dccExpired, "DCC_COMP_410")
				case .testResultNotYetReceived:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_412")
				case .internalServerError(reason: let reason):
					switch reason {
					case "INTERNAL":
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500_INTERNAL")
					case "LAB_INVALID_RESPONSE":
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_LAB_INVALID_RESPONSE")
					case "SIGNING_CLIENT_ERROR":
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_SIGNING_CLIENT_ERROR")
					case "SIGNING_SERVER_ERROR":
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COMP_500_SIGNING_SERVER_ERROR")
					case .some(let reason):
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500_\(reason)")
					case .none:
						return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_500")
					}

				case .defaultServerError(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(error.localizedDescription)")
				case .noNetworkConnection:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.noNetwork, "DGC_COMP_NO_NETWORK")
				}
			case .base64DecodingFailed:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DEK_DECODING_FAILED")
			case .rsaKeyPairGenerationFailed(let keyPairError):
				switch keyPairError {
				case .keyPairGenerationFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "RSA_KP_GENERATION_FAILED: \(error)")
				case .keychainRetrievalFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_KP_RETRIEVAL_FAILED: \(error)")
				case .gettingDataRepresentationFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "RSA_KP_GETTING_DATA_FAILED: \(String(describing: error?.localizedDescription))")
				case .decryptionFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "RSA_DECRYPTION_FAILED: \(String(describing: error?.localizedDescription)))")
				case .encryptionFailed(let error):
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "RSA_ENCRYPTION_FAILED: \(String(describing: error?.localizedDescription)))")
				}
			case .decryptionFailed(let error):
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "RSA_DECRYPTION_FAILED: \(error.localizedDescription)")
			case .assemblyFailed(let decodingError):
				switch decodingError {
				case .HC_BASE45_DECODING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_BASE45_DECODING_FAILED")
				case .HC_ZLIB_DECOMPRESSION_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_ZLIB_DECOMPRESSION_FAILED")
				case .HC_COSE_TAG_OR_ARRAY_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COSE_TAG_INVALID")
				case .HC_COSE_NO_KEYIDENTIFIER:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "HC_COSE_NO_KEYIDENTIFIER")
				case .HC_COSE_MESSAGE_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "DCC_COSE_MESSAGE_INVALID")
				case .HC_CBOR_DECODING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_CBOR_DECODING_FAILED")
				case .HC_CBOR_TRIMMING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "HC_CBOR_TRIMMING_FAILED")
				case .HC_CBORWEBTOKEN_NO_ISSUER:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_CWT_NO_ISS")
				case .HC_CBORWEBTOKEN_NO_EXPIRATIONTIME:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_CWT_NO_EXP")
				case .HC_CBORWEBTOKEN_NO_HEALTHCERTIFICATE:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_CWT_NO_HCERT")
				case .HC_CBORWEBTOKEN_NO_DIGITALGREENCERTIFICATE:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_CWT_NO_DGC")
				case .HC_JSON_SCHEMA_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_JSON_SCHEMA_INVALID")
				case .HC_PREFIX_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_PREFIX_INVALID")
				case .AES_DECRYPTION_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "AES_DECRYPTION_FAILED")
				case .HC_BASE45_ENCODING_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "HC_BASE45_ENCODING_FAILED")
				case .HC_ZLIB_COMPRESSION_FAILED:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.clientErrorCallHotline, "HC_ZLIB_COMPRESSION_FAILED")
				}
			case .other(let error):
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, error.localizedDescription)
			case .registrationError(let error):
				return error.errorDescription
			case .dgcNotSupportedByLab:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.dgcNotSupportedByLab, "DGC_NOT_SUPPORTED_BY_LAB")
			}
		}
	}

}
