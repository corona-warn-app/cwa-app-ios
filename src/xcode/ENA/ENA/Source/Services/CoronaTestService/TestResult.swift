//
// 🦠 Corona-Warn-App
//

import Foundation

enum TestResult: Int, CaseIterable, Codable {

	// MARK: - Init

	init?(serverResponse: Int) {
		// Values for antigen tests are pending = 5, negative = 6, ...
		self.init(rawValue: serverResponse % 5)
	}

	// MARK: - Internal

	case pending = 0
	case negative = 1
	case positive = 2
	case invalid = 3
	// On the server it's called "redeemed", but this state means that the test is expired.
	// Actually redeemed tests return a code 400 when registered.
	case expired = 4

}
