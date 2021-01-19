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

	/// zero seconds
	static let zero = 0.0
	/// two seconds
	static let short = 2.0
	/// five seconds
	static let medium = 5.0
	/// ten seconds
	static let long = 10.0
	// twentyfive seconds
	static let extraLong = 25.0

}
