//
// 🦠 Corona-Warn-App
//

import Foundation

enum AccessTokenRequestError: Error, Equatable {
	case ATR_JWT_VER_ALG_NOT_SUPPORTED
	case ATR_JWT_VER_EMPTY_JWKS
	case ATR_JWT_VER_NO_JWK_FOR_KID
	case ATR_JWT_VER_NO_KID
	case ATR_JWT_VER_SIG_INVALID
	case ATR_PARSE_ERR
	case ATR_TYPE_INVALID
	case ATR_AUD_INVALID
	case REST_SERVICE_ERROR(ServiceError<TicketValidationAccessTokenError>)
	case UNKNOWN
}
