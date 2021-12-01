//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

enum ServiceIdentityRequestError: Error {
	case VS_ID_NO_ENC_KEY
	case VS_ID_NO_SIGN_KEY
	case VS_ID_EMPTY_X5C
	case REST_SERVICE_ERROR(ServiceError<ServiceIdentityDocumentResourceError>)
	case UNKOWN
}
