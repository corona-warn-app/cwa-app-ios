import CryptoKit
import Foundation

enum Hasher {
	/// Hashes the given input string using SHA-256.
	static func sha256(_ input: String) -> String {
		let value = SHA256.hash(data: Data(input.utf8))
		let hash = value.compactMap { String(format: "%02x", $0) }.joined()
		return hash
	}
}
