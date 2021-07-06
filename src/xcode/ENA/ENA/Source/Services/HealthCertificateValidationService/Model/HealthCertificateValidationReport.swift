////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.ValidationResult

enum HealthCertificateValidationReport {

	/// All validation rules have result = .passed
	case validationPassed
	
	/// All validation rules have result = .open
	case validationOpen([ValidationResult])
	
	/// At least one validation rule has result = .fail
	case validationFailed([ValidationResult])
}

extension HealthCertificateValidationReport: Equatable {
	static func == (lhs: HealthCertificateValidationReport, rhs: HealthCertificateValidationReport) -> Bool {
		switch lhs {
		case .validationPassed:
			return rhs == .validationPassed ? true : false
		case .validationOpen:
			return rhs == .validationOpen([]) ? true : false
		case .validationFailed:
			return rhs == .validationFailed([]) ? true : false
			
		}
	}
}
