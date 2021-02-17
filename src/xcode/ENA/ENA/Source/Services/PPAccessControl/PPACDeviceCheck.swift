////
// 🦠 Corona-Warn-App
//

import Foundation
import DeviceCheck

protocol DeviceCheckable {
	var isSupported: Bool { get }
	func deviceToken(_ apiToken: String, completion: @escaping (Result<PPACToken, PPACError>) -> Void)
}

final class PPACDeviceCheck: DeviceCheckable {

	// MARK: - Protocol DeviceCheckable

	var isSupported: Bool {
		return DCDevice.current.isSupported
	}

	func deviceToken(_ apiToken: String, completion: @escaping (Result<PPACToken, PPACError>) -> Void) {
		DCDevice.current.generateToken { tokenData, error in
			guard error == nil,
				  let deviceToken = tokenData?.base64EncodedString() else {
				switch error {
				case .none:
					Log.error("DeviceCheck token base64 encoding failed", log: .ppa)
				case .some(let error):
					Log.error("Failed to creatd DeviceCheck token, error: \(error.localizedDescription)", log: .ppac)
				}
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

}
