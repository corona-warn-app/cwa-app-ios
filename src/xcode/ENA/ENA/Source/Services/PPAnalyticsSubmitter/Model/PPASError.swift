////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPASError: Error {

	case generalError
	case urlCreationError
	case responseError(Int)
	case jsonError
	case serverError(PPAServerErrorCode)
	case serverFailure(Error)
}

extension PPASError: Equatable {
	static func == (lhs: PPASError, rhs: PPASError) -> Bool {
		switch(lhs, rhs) {
		case (.generalError, .generalError):
			return true
		case (.urlCreationError, .urlCreationError):
			return true
		case let (.responseError(lhsCode), .responseError(rhsCode)):
			return lhsCode == rhsCode ? true : false
		case (.jsonError, .jsonError):
			return true
		case let (.serverError(lhsError), .serverError(rhsError)):
			return lhsError == rhsError ? true : false
		case (.serverFailure, .serverFailure):
			return true
		default:
			return false
		}
	}
}
