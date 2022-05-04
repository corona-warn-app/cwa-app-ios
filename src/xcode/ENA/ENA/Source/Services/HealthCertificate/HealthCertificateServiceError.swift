////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateServiceError {

	enum RegistrationError: LocalizedError {
		case decodingError(CertificateDecodingError)
		case certificateAlreadyRegistered(HealthCertificate.CertificateType)
		case certificateHasTooManyEntries
		case tooManyPersonsRegistered
		case invalidSignature(DCCSignatureVerificationError)
		case other(Error)

		// MARK: - Protocol LocalizedError

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
				case .HC_COSE_NO_SIGN:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_NO_SIGN)"
				case .HC_COSE_PH_INVALID:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_PH_INVALID)"
				case .HC_COSE_UNKNOWN_ALG:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_UNKNOWN_ALG)"
				case .HC_COSE_NO_ALG:
					return "\(AppStrings.HealthCertificate.Error.hcInvalid) (HC_COSE_NO_ALG)"
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
				return AppStrings.UniversalQRScanner.MaxPersonAmountAlert.errorMessage
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
		case publicKeyRegistrationFailed(ServiceError<DCCPublicKeyRegistrationError>)
		case certificateRequestFailed(ServiceError<DigitalCovid19CertificateError>)
		case base64DecodingFailed
		case rsaKeyPairGenerationFailed(DCCRSAKeyPairError)
		case decryptionFailed(Error)
		case assemblyFailed(CertificateDecodingError)
		case registrationError(HealthCertificateServiceError.RegistrationError)
		case dgcNotSupportedByLab
		case other(Error)

		// MARK: - Protocol LocalizedError

		var errorDescription: String? {
			switch self {
			case .publicKeyRegistrationFailed(let serviceError):
				switch serviceError {
				case .receivedResourceError(let registrationError):
					return registrationError.localizedDescription
				default:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "PKR_FAILED (\(serviceError.localizedDescription)")
				}
			case .certificateRequestFailed(let serviceError):
				switch serviceError {
				case .receivedResourceError(let certificateError):
					return certificateError.localizedDescription
				default:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DCC_COMP_FAILED (\(serviceError.localizedDescription)")
				}
			case .base64DecodingFailed:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.tryAgain, "DEK_DECODING_FAILED")
			case .rsaKeyPairGenerationFailed(let keyPairError):
				return keyPairError.localizedDescription
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
				case .HC_COSE_NO_SIGN:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "HC_COSE_NO_SIGN")
				case .HC_COSE_PH_INVALID:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "HC_COSE_PH_INVALID")
				case .HC_COSE_UNKNOWN_ALG:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "HC_COSE_UNKNOWN_ALG")
				case .HC_COSE_NO_ALG:
					return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.e2eErrorCallHotline, "HC_COSE_NO_ALG")
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
				return error.localizedDescription
			case .dgcNotSupportedByLab:
				return String(format: AppStrings.HealthCertificate.Overview.TestCertificateRequest.Error.dgcNotSupportedByLab, "DGC_NOT_SUPPORTED_BY_LAB")
			}
		}
	}

}
