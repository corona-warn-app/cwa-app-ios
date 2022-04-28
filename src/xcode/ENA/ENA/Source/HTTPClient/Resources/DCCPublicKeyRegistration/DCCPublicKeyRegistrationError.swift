//
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCPublicKeyRegistrationError: Error, Equatable {
	case badRequest
	case tokenNotAllowed
	case tokenDoesNotExist
	case tokenAlreadyAssigned
	case internalServerError
	case unhandledResponse(Int)
	case noNetworkConnection

	// MARK: - Protocol Equatable

	static func == (lhs: DCCPublicKeyRegistrationError, rhs: DCCPublicKeyRegistrationError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
