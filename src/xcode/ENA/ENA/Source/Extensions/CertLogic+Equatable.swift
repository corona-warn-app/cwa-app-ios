////
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

extension ValidationResult: Equatable {
	public static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
		return lhs.result == rhs.result &&
			lhs.rule == rhs.rule
	}
}
