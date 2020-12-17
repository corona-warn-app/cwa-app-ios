//
// 🦠 Corona-Warn-App
//

import Foundation

#if canImport(CryptoKit)
import CryptoKit
#else
import CommonCrypto
#endif


// DEV NOTE: structure might change ⚠️⚠️⚠️

// MARK: - Protocols

extension Data {

	/// SHA 256 hash of the current Data
	/// - Returns: Data representation of the hash value
	func sha256() -> Data {
		if #available(iOS 13.0, *) {
			return Data(SHA256.hash(data: self))
		} else {
			preconditionFailure("not implemented")
		}
	}

	/// SHA 256 hash of the current Data
	/// - Returns: String representation of the hash value
	func sha256String() -> String {
		if #available(iOS 13.0, *) {
			// compact map removes 'SHA256 digest:' prefix
			return sha256().compactMap { String(format: "%02x", $0) }.joined()
		} else {
			preconditionFailure("not implemented")
		}
	}
}
