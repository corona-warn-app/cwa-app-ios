////
// 🦠 Corona-Warn-App
//

import Foundation

final class PPACDeviceCheckMock: DeviceCheckable {

	// MARK: - Init
	init(
		_ isSupported: Bool,
		deviceToken: String
	) {
		self.isSupported = isSupported
		self.deviceToken = deviceToken
	}

	// MARK: - Protocol DeviceCheckable

	let isSupported: Bool

	func deviceToken(
		apiToken: String,
		previousApiToken: String?,
		completion: @escaping (Result<PPACToken, PPACError>) -> Void
	) {
		if !isSupported {
			Log.error("Failed to create DeviceCheck token", log: .ppac)
			completion(.failure(.generationFailed))
			return
		}
		guard let deviceToken = deviceToken.data(using: .utf8)?.base64EncodedString() else {
			Log.error("Failed to create DeviceCheck token", log: .ppac)
			completion(.failure(.generationFailed))
			return
		}
		completion(
			.success(
				PPACToken(
					apiToken: apiToken,
					previousApiToken: previousApiToken ?? "",
					deviceToken: deviceToken
				)
			)
		)
	}

	// MARK: - Private

	private let deviceToken: String

}
