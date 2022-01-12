////
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertificateValidationRuleType: CaseIterable {
	case acceptance
	case invalidation
	case boosterNotification
	
	var urlPath: String {
		switch self {
		case .acceptance:
			return "acceptance-rules"
		case .invalidation:
			return "invalidation-rules"
		case .boosterNotification:
			return "booster-notification-rules"
		}
	}
	
	var errorPrefix: String {
		switch self {
		case .acceptance:
			return "ACCEPTANCE"
		case .invalidation:
			return "INVALIDATION"
		case .boosterNotification:
			return "BOOSTER_NOTIFICATION"
		}
	}
}
