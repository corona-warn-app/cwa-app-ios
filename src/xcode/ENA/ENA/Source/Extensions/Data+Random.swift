//
// 🦠 Corona-Warn-App
//

import Foundation

extension Data {
	
	static func randomBytes(length: Int) -> Data? {
		var randomData = Data(count: length)

		let result: Int32? = randomData.withUnsafeMutableBytes {
			guard let baseAddress = $0.baseAddress else {
				Log.error("Could not access base address.", log: .checkin)
				return nil
			}
			return SecRandomCopyBytes(kSecRandomDefault, length, baseAddress)
		}
		if let result = result, result == errSecSuccess {
			return randomData
		} else {
			Log.error("Failed to generate random bytes.", log: .checkin)
			return nil
		}
	}
}
