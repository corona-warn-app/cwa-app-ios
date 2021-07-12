////
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.ValidationResult

enum HealthCertificateValidationReport {

	/// All validation rules have result = .passed
	case validationPassed

	/// At least one validation rule has result = .open and there is none containing = .fail
	case validationOpen([ValidationResult])

	/// At least one validation rule has result = .fail
	case validationFailed([ValidationResult])

}
