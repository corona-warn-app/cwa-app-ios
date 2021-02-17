//
// 🦠 Corona-Warn-App
//

import Foundation

enum TestResult: Int, CaseIterable, Codable {
	case pending = 0
	case negative = 1
	case positive = 2
	case invalid = 3
	case expired = 4
}
