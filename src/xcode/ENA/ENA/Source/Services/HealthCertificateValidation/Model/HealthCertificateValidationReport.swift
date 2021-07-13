////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.ValidationResult

enum HealthCertificateValidationReport {

	/// All validation rules have result = .passed
	case validationPassed([ValidationResult])

	/// At least one validation rule has result = .open and there is none containing = .fail
	case validationOpen([ValidationResult])
	
	/// At least one validation rule has result = .fail
	case validationFailed([ValidationResult])
}

extension HealthCertificateValidationReport: Equatable {
	static func == (lhs: HealthCertificateValidationReport, rhs: HealthCertificateValidationReport) -> Bool {
		switch (lhs, rhs) {
		case (.validationPassed, .validationPassed):
			return true
		case let (.validationOpen(lhsRules), .validationOpen(rhsRules)):
			return lhsRules == rhsRules
		case let (.validationFailed(lhsRules), .validationFailed(rhsRules)):
			return lhsRules == rhsRules
		default:
			return false
		}
	}
}
