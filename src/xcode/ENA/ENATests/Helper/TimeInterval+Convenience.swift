//
// 🦠 Corona-Warn-App
//

import Foundation

extension TimeInterval {

	init(hours: Int) {
		self = Double(hours * 60 * 60)
	}

	init(days: Int) {
		self = Double(days * 24 * 60 * 60)
	}

	/// One second
	static let short = 2.0
	/// Three seconds
	static let medium = 5.0
	/// Fife seconds
	static let long = 10.0

}
