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
