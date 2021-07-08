////
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertificateValidationRuleType {
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
