////
// 🦠 Corona-Warn-App
//

import Foundation

extension Data {
	/// Instantiates data by decoding a base64url string into base64
	///
	/// - Parameter string: A base64url encoded string
	init?(base64URLEncoded string: String) {
		self.init(base64Encoded: string.toggleBase64URLSafe(on: false))
	}
	/// Encodes the string into a base64url safe representation
	///
	/// - Returns: A string that is base64 encoded but made safe for passing
	///            in as a query parameter into a URL string
	func base64URLEncodedString() -> String {
		return self.base64EncodedString().toggleBase64URLSafe(on: true)
	}
}
