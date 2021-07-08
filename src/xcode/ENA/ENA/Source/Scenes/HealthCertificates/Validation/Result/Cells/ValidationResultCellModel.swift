////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import class CertLogic.ValidationResult

final class ValidationResultCellModel {

	// MARK: - Init

	init(
		validationResult: ValidationResult
	) {
		self.validationResult = validationResult
	}

	// MARK: - Internal

	var ruleDescription: String? {
		validationResult.rule?.description.first(where: { $0.lang.lowercased() == "de" })?.desc
	}

	// MARK: - Private

	private let validationResult: ValidationResult

}
