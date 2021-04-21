//
// 🦠 Corona-Warn-App
//

import Foundation

enum ENAHasher {
	/// Hashes the given input string using SHA-256.
	static func sha256(_ input: String) -> String {
		return Data(input.utf8).sha256String()
	}
}
