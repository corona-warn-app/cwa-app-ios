//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

extension DynamicCell {

	static func ticketValidationResult(
		_ validationResultItem: TicketValidationResult.ResultItem
	) -> Self {
		.custom(
			withIdentifier: TicketValidationResultTableViewCell.dynamicTableViewCellReuseIdentifier
		) { _, cell, _ in
			if let validationResultCell = cell as? TicketValidationResultTableViewCell {
				validationResultCell.configure(
					with: TicketValidationResultCellModel(
						validationResultItem: validationResultItem
					)
				)
			}
		}
	}

}
