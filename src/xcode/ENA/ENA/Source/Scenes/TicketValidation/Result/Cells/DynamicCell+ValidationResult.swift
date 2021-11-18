//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import class CertLogic.ValidationResult

extension DynamicCell {

	static func ticketValidationResult(
		_ ticketValidationResultItem: TicketValidationResult.ResultItem
	) -> Self {
		.custom(
			withIdentifier: TicketValidationResultCellModel.dynamicTableViewCellReuseIdentifier
		) { viewController, cell, _ in
			if let validationResultCell = cell as? TicketValidationResultCellModel {
				validationResultCell.configure(
					with: TicketValidationResultCellModel(
						validationResultItem: validationResultItem
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
