//
// 🦠 Corona-Warn-App
//

import Foundation

enum TicketValidationResultTokenProcessingError: Error, Equatable {
	case RTR_JWT_VER_ALG_NOT_SUPPORTED
	case RTR_JWT_VER_EMPTY_JWKS
	case RTR_JWT_VER_NO_JWK_FOR_KID
	case RTR_JWT_VER_NO_KID
	case RTR_JWT_VER_SIG_INVALID
	case RTR_PARSE_ERR
	case REST_SERVICE_ERROR(ServiceError<TicketValidationResultTokenError>)
	case UNKNOWN
}
