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

	private var apiToken: String {
		return UUID().uuidString
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

	// MARK: - Private

	private let store: Store

}
