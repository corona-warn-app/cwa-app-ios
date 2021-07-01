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
