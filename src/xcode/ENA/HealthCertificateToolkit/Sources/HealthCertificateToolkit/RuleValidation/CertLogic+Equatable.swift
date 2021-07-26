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

extension Rule: Equatable {
	// Note: We compare nearly every property, but almost everyone. So it should be enough comparisons to be sure that the object are really equal.
	public static func == (lhs: Rule, rhs: Rule) -> Bool {
		return lhs.identifier == rhs.identifier &&
			lhs.certificateType == rhs.certificateType &&
			lhs.logic == rhs.logic &&
			lhs.engine == rhs.engine &&
			lhs.countryCode == rhs.countryCode &&
			lhs.engineVersion == rhs.engineVersion &&
			lhs.hash == rhs.hash &&
			lhs.ruleType == rhs.ruleType &&
			lhs.schemaVersion == rhs.schemaVersion &&
			lhs.validFrom == rhs.validFrom &&
			lhs.validTo == rhs.validTo &&
			lhs.validToDate == rhs.validToDate &&
			lhs.validFromDate == rhs.validFromDate &&
			lhs.type == rhs.type &&
			lhs.version == rhs.version &&
			lhs.versionInt == rhs.versionInt
	}
}
