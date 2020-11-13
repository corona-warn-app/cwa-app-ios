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

	static let short = 1.0
	static let medium = 3.0
	static let long = 5.0

}
