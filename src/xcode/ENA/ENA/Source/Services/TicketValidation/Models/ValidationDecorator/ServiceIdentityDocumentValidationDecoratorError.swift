//
// 🦠 Corona-Warn-App
//

import Foundation
enum ServiceIdentityValidationDecoratorError: Error {
	case VD_ID_NO_ATS
	case VD_ID_NO_ATS_SIGN_KEY
	case VD_ID_NO_ATS_SVC_KEY
	case VD_ID_NO_VS
	case VD_ID_NO_VS_SVC_KEY
	case VD_ID_EMPTY_X5C
	case REST_SERVICE_ERROR(ServiceError<ServiceIdentityResourceDecoratorError>)
}

enum ServiceIdentityResourceDecoratorError: Error {
	case VD_ID_CLIENT_ERR
	case VD_ID_NO_NETWORK
	case VD_ID_SERVER_ERR
	case VD_ID_PARSE_ERR
}
