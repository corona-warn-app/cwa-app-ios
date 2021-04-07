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

extension String {
	/// Encodes or decodes into a base64url safe representation
	///
	/// - Parameter on: Whether or not the string should be made safe for URL strings
	/// - Returns: if `on`, then a base64url string; if `off` then a base64 string
	func toggleBase64URLSafe(on: Bool) -> String {
		if on {
			// Make base64 string safe for passing into URL query params
			let base64url = self.replacingOccurrences(of: "/", with: "_")
				.replacingOccurrences(of: "+", with: "-")
				.replacingOccurrences(of: "=", with: "")
			return base64url
		} else {
			// Return to base64 encoding
			var base64 = self.replacingOccurrences(of: "_", with: "/")
				.replacingOccurrences(of: "-", with: "+")
			// Add any necessary padding with `=`
			if !base64.count.isMultiple(of: 4) {
				base64.append(String(repeating: "=", count: 4 - base64.count % 4))
			}
			return base64
		}
	}
	
//	func encodedDataIn64Bit() {
//		let utf8str = self.data(using: .utf8)
//
//		if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
//			print("Encoded: \(base64Encoded)")
//
//			if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
//			.map({ String(data: $0, encoding: .utf8) }) {
//				// Convert back to a string
//				print("Decoded: \(base64Decoded ?? "")")
//			}
//		}
//	}
	/// Converts  Base64URL encoded String into Data
	func base64URLEncodedData() -> Data? {
		/// First Convert Base64URL encoded String into Base64 Encoded String
		let base64String = self.toggleBase64URLSafe(on: false)
		
		/// Convert Base64Encoded String into Data
		return Data(base64Encoded: base64String)
	}
}
