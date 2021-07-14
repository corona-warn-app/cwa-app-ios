//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import class CertLogic.ValidationResult

extension DynamicCell {

	static func validationResult(
		_ validationResult: ValidationResult,
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) -> Self {
		.custom(
			withIdentifier: ValidationResultTableViewCell.dynamicTableViewCellReuseIdentifier
		) { viewController, cell, _ in
			if let validationResultCell = cell as? ValidationResultTableViewCell {
				validationResultCell.configure(
					with: ValidationResultCellModel(
						validationResult: validationResult,
						healthCertificate: healthCertificate,
						vaccinationValueSetsProvider: vaccinationValueSetsProvider
					),
					onUpdate: {
						UIView.performWithoutAnimation {
							viewController.tableView.beginUpdates()
							viewController.tableView.endUpdates()
						}
					}
				)
			}
		}
	}

}
