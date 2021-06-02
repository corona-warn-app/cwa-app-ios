////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCErrors {

	enum RegistrationError: Error, Equatable {
		case badRequest
		case tokenNotAllowed
		case tokenDoesNotExist
		case tokenAlreadyAssigned
		case internalServerError
		case generalError
		case unhandledResponse(Int)
		case defaultServerError(Error)
		case urlCreationFailed

		// MARK: - Protocol Equatable

		static func == (lhs: RegistrationError, rhs: RegistrationError) -> Bool {
			lhs.localizedDescription == rhs.localizedDescription
		}
	}

}
