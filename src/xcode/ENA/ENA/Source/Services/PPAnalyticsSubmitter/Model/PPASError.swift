////
// 🦠 Corona-Warn-App
//

import Foundation

enum PPASError: Error {

	case submissionInProgress
	case generalError
	case urlCreationError
	case responseError(Int)
	case jsonError
	case serverError(PPAServerErrorCode)
	case serverFailure(Error)
	case ppacError(PPACError)
	case appResetError
	case onboardingError
	case submissionTimeAmountUndercutError
	case probibilityError
	case userConsentError
	
	case restServiceError(ServiceError<PPASubmitResourceError>)
}

extension PPASError: Equatable {
	static func == (lhs: PPASError, rhs: PPASError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
