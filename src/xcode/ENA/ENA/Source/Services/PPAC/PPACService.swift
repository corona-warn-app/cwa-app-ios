////
// 🦠 Corona-Warn-App
//

import Foundation
import DeviceCheck

enum PPACError: Error {
	case generationFailed
	case deviceNotSupported
	case timeIncorrect
	case timeUnverified
}

struct PPACToken {
	let apiToken: String
	let deviceToken: String
}


protocol PrivacyPreservingAccessControl {
	func invalidateAPIToken()
	func getPPACToken(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void)
}


final class PrivacyPreservingAccessControlService: PrivacyPreservingAccessControl {

	// MARK: - Init

	init(store: Store) throws {
		self.store = store

		let deviceTimeCheck = DeviceTimeCheck(store: store)
		guard deviceTimeCheck.isDeviceTimeCorrect else {
			// add loggin here
			throw PPACError.timeIncorrect
		}

		// add new time check here

		guard DCDevice.current.isSupported else {
			// add loggin here
			throw PPACError.deviceNotSupported
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol PrivacyPreservingAccessControl

	// this will invalidat a stored API token
	func invalidateAPIToken() {

	}

	func getPPACToken(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {

		DCDevice.current.generateToken { tokenData, error in
			guard error != nil,
				let data = tokenData else {
				completion(.failure(.generationFailed))
				return
			}
			completion(.success(PPACToken(apiToken: UUID().uuidString, deviceToken: data.base64EncodedString())))
		}
	}

	// MARK: - Public

	// MARK: - Internal

	struct Token: Codable {
		let token: String
		let timestamp: Date
	}

	// MARK: - Private

	private let store: Store
	
	private var apiToken: Token {
		guard let storedToken = store.apiToken else {
			return generateAndStoreFreshAPIToken()
		}

		// check if still valid

		return storedToken
	}

	private func generateAndStoreFreshAPIToken() -> Token {
		let uuid = UUID().uuidString
		let utcDate = Date() // todo: check if this is a UTC date!
		let token = Token(token: uuid, timestamp: utcDate)
		store.apiToken = token
		return token
	}

}
