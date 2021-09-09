//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum BoosterNotificationServiceError: LocalizedError {
	case CERTIFICATE_VALIDATION_ERROR(HealthCertificateValidationError)
	case BOOSTER_VALIDATION_ERROR(BoosterNotificationRuleValidationError)
}

// swiftlint:disable pattern_matching_keywords
extension BoosterNotificationServiceError: Equatable {
	static func == (lhs: BoosterNotificationServiceError, rhs: BoosterNotificationServiceError) -> Bool {
		switch (lhs, rhs) {
		case (.CERTIFICATE_VALIDATION_ERROR(let lhsError), .CERTIFICATE_VALIDATION_ERROR(let rhsError)):
			return lhsError == rhsError
		case (.BOOSTER_VALIDATION_ERROR(let lhsError), .BOOSTER_VALIDATION_ERROR(let rhsError)):
			return lhsError == rhsError
		case (.BOOSTER_VALIDATION_ERROR(_), .CERTIFICATE_VALIDATION_ERROR(_)):
			return false
		case (.CERTIFICATE_VALIDATION_ERROR(_), .BOOSTER_VALIDATION_ERROR(_)):
			return false
		}
	}
}

