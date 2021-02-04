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

	/// 5 seconds
	static let short = 5.0
	/// 10 seconds
	static let medium = 10.0
	/// 20 seconds
	static let long = 20.0
	/// 30 seconds
	static let extraLong = 30.0

}
