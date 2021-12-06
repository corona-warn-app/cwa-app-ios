//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

enum TicketValidationError: LocalizedError {
	case validationDecoratorDocument(ServiceIdentityValidationDecoratorError)
	case validationServiceDocument(ServiceIdentityRequestError)
	case keyPairGeneration(ECKeyPairGenerationError)
	case accessToken(TicketValidationAccessTokenProcessingError)
	case encryption(EncryptAndSignError)
	case resultToken(TicketValidationResultTokenProcessingError)
	case allowListError(AllowListError)
	case other

	// swiftlint:disable cyclomatic_complexity
	func errorDescription(serviceProvider: String) -> String? {
		let serviceProviderError = String(
			format: AppStrings.TicketValidation.Error.serviceProviderError,
			serviceProvider
		)

		switch self {
		case .validationDecoratorDocument(let error):
			switch error {
			case .REST_SERVICE_ERROR(.receivedResourceError(.VD_ID_CLIENT_ERR)), .VD_ID_EMPTY_X5C, .VD_ID_NO_ATS_SIGN_KEY, .VD_ID_NO_ATS_SVC_KEY, .VD_ID_NO_ATS, .VD_ID_NO_VS_SVC_KEY, .VD_ID_NO_VS, .REST_SERVICE_ERROR(.receivedResourceError(.VD_ID_PARSE_ERR)):
				return "\(serviceProviderError) (\(error))"
			default:
				return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
			}
		case .validationServiceDocument(let error):
			switch error {
			case .REST_SERVICE_ERROR(.receivedResourceError(.VS_ID_CERT_PIN_MISMATCH)), .REST_SERVICE_ERROR(.receivedResourceError(.VS_ID_CERT_PIN_HOST_MISMATCH)), .REST_SERVICE_ERROR(.receivedResourceError(.VS_ID_CLIENT_ERR)), .VS_ID_EMPTY_X5C, .VS_ID_NO_ENC_KEY, .VS_ID_NO_SIGN_KEY, .REST_SERVICE_ERROR(.receivedResourceError(.VS_ID_PARSE_ERR)):
				return "\(serviceProviderError) (\(error))"
			default:
				return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
			}
		case .keyPairGeneration(let error):
			return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
		case .accessToken(let error):
			switch error {
			case .ATR_AUD_INVALID, .REST_SERVICE_ERROR(.receivedResourceError(.ATR_CERT_PIN_MISMATCH)), .REST_SERVICE_ERROR(.receivedResourceError(.ATR_CERT_PIN_NO_JWK_FOR_KID)), .REST_SERVICE_ERROR(.receivedResourceError(.ATR_CLIENT_ERR)), .ATR_JWT_VER_ALG_NOT_SUPPORTED, .ATR_JWT_VER_EMPTY_JWKS, .ATR_JWT_VER_NO_JWK_FOR_KID, .ATR_JWT_VER_NO_KID, .ATR_JWT_VER_SIG_INVALID, .ATR_PARSE_ERR, .REST_SERVICE_ERROR(.receivedResourceError(.ATR_PARSE_ERR)), .ATR_TYPE_INVALID:
				return "\(serviceProviderError) (\(error))"
			default:
				return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
			}
		case .encryption(let error):
			return "\(serviceProviderError) (\(error))"
		case .resultToken(let error):
			switch error {
			case .REST_SERVICE_ERROR(.receivedResourceError(.RTR_CERT_PIN_MISMATCH)), .REST_SERVICE_ERROR(.receivedResourceError(.RTR_CERT_PIN_HOST_MISMATCH)), .REST_SERVICE_ERROR(.receivedResourceError(.RTR_CLIENT_ERR)), .RTR_JWT_VER_ALG_NOT_SUPPORTED, .RTR_JWT_VER_EMPTY_JWKS, .RTR_JWT_VER_NO_JWK_FOR_KID, .RTR_JWT_VER_NO_KID, .RTR_JWT_VER_SIG_INVALID, .RTR_PARSE_ERR, .REST_SERVICE_ERROR(.receivedResourceError(.RTR_PARSE_ERR)):
				return "\(serviceProviderError) (\(error))"
			default:
				return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
			}
		case .allowListError(let error):
			switch error {
			case .SP_ALLOWLIST_NO_MATCH:
				return "\(AppStrings.TicketValidation.Error.serviceProviderErrorNoName) (\(error))"
			case .REST_SERVICE_ERROR(let error):
				return "\(AppStrings.TicketValidation.Error.tryAgain) (\(error))"
			}
		default:
			return "\(AppStrings.TicketValidation.Error.tryAgain) (\(self))"
		}

	}


}
