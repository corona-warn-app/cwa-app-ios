////
// 🦠 Corona-Warn-App
//

import Foundation

enum RuleType {
	case acceptance
	case invalidation
	
	var urlPath: String {
		switch self {
		case .acceptance:
			return "acceptance-rules"
		case .invalidation:
			return "invalidation-rules"
		}
	}
}
