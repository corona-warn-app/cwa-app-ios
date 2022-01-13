//
// 🦠 Corona-Warn-App
//

import Foundation

enum AllowListError: LocalizedError {
	case SP_ALLOWLIST_NO_MATCH
	case REST_SERVICE_ERROR(ServiceError<AllowListResource.CustomError>)
}

// swiftlint:disable pattern_matching_keywords
extension AllowListError: Equatable {
	public static func == (lhs: AllowListError, rhs: AllowListError) -> Bool {
		switch (lhs, rhs) {
		case (.REST_SERVICE_ERROR(let lhsError), .REST_SERVICE_ERROR(let rhsError)):
			return lhsError == rhsError
		case (.SP_ALLOWLIST_NO_MATCH, .SP_ALLOWLIST_NO_MATCH):
			return true
		default:
			return false
		}
	}
}
