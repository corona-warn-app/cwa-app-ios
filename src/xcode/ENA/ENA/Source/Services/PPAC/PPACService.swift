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

