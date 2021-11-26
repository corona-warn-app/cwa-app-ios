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

// swiftlint:disable pattern_matching_keywords
extension ServiceIdentityValidationDecoratorError: Equatable {
	static func == (lhs: ServiceIdentityValidationDecoratorError, rhs: ServiceIdentityValidationDecoratorError) -> Bool {
		switch (lhs, rhs) {
		case (.VD_ID_NO_ATS, .VD_ID_NO_ATS):
			return true
		case (.VD_ID_NO_ATS_SIGN_KEY, .VD_ID_NO_ATS_SIGN_KEY):
			return true
		case (.VD_ID_NO_ATS_SVC_KEY, .VD_ID_NO_ATS_SVC_KEY):
			return true
		case (.VD_ID_NO_VS, .VD_ID_NO_VS):
			return true
		case (.VD_ID_NO_VS_SVC_KEY, .VD_ID_NO_VS_SVC_KEY):
			return true
		case (.VD_ID_EMPTY_X5C, .VD_ID_EMPTY_X5C):
			return true
		case (.REST_SERVICE_ERROR(let lhsResult), .REST_SERVICE_ERROR(let rhsResult)):
			return lhsResult == rhsResult
		default:
			return false
		}
	}
}
