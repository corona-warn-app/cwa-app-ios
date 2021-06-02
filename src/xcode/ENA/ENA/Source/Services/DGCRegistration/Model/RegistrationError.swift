////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCErrors {

	enum RegistrationError: Error {
		case badRequest
		case tokenNotAllowed
		case tokenDoesNotExist
		case tokenAlreadyAssigned
		case internalServerError
		case generalError
		case unhandledResponse(Int)
		case defaultServerError(Error)
		case urlCreationFailed
	}

}
