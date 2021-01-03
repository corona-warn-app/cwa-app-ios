//
// 🦠 Corona-Warn-App
//

import Foundation

enum Hasher {
	/// Hashes the given input string using SHA-256.
	static func sha256(_ input: String) -> String {
		return Data(input.utf8).sha256String()
	}
}
