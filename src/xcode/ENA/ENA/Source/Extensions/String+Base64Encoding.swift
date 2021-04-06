////
// 🦠 Corona-Warn-App
//

import Foundation

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
			if base64.count % 4 != 0 {
				base64.append(String(repeating: "=", count: 4 - base64.count % 4))
			}
			return base64
		}
	}
}
