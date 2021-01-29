////
// 🦠 Corona-Warn-App
//

import Foundation
import DeviceCheck

struct TimestampedToken: Codable {
	let token: String
	let timestamp: Date
}

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

		// check if time isn't incorrect
		if store.deviceTimeCheckResult == .incorrect {
			Log.error("device time is incorrect", log: .ppac)
			throw PPACError.timeIncorrect
		}

		// check if time isn't unknown
		if store.deviceTimeCheckResult == .assumedCorrect {
			Log.error("device time is unverified", log: .ppac)
			throw PPACError.timeUnverified
		}

		// check if device supports DeviceCheck
		guard DCDevice.current.isSupported else {
			Log.error("device token not supported", log: .ppac)
			throw PPACError.deviceNotSupported
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol PrivacyPreservingAccessControl

	func getPPACToken(_ completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		DCDevice.current.generateToken { [weak self] tokenData, error in
			guard error != nil,
				  let deviceToken = tokenData?.base64EncodedString(),
				  let apiToken = self?.apiToken.token else {
				Log.error("Failed to creatd DeviceCheck token", log: .ppac)
				completion(.failure(.generationFailed))
				return
			}
			completion(
				.success(
					PPACToken(
						apiToken: apiToken,
						deviceToken: deviceToken
					)
				)
			)
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let store: Store

	/// will return the current API Token amd create a new one if needed
	private var apiToken: TimestampedToken {
		let today = Date()
		/// check if we alread hav a token and if it was created in this month / year
		guard let storedToken = store.apiToken,
			  storedToken.timestamp.isEqual(to: today, toGranularity: .month),
			  storedToken.timestamp.isEqual(to: today, toGranularity: .year)
		else {
			return generateAndStoreFreshAPIToken()
		}
		return storedToken
	}

	/// generate a new API Toke and store it
	private func generateAndStoreFreshAPIToken() -> TimestampedToken {
		let uuid = UUID().uuidString
		let utcDate = Date()
		let token = TimestampedToken(token: uuid, timestamp: utcDate)
		store.apiToken = token
		return token
	}

}
