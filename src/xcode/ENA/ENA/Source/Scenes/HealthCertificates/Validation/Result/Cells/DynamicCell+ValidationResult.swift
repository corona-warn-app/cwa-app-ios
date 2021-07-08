////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import class CertLogic.ValidationResult

extension DynamicCell {

	static func validationResult(_ validationResult: ValidationResult) -> Self {
		.custom(
			withIdentifier: ValidationResultTableViewCell.dynamicTableViewCellReuseIdentifier
		) { _, cell, _ in
			if let validationResultCell = cell as? ValidationResultTableViewCell {
				validationResultCell.configure(
					with: ValidationResultCellModel(validationResult: validationResult)
				)
			}
		}
	}

}
