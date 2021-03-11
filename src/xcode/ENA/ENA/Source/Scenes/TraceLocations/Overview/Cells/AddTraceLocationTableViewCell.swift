////
// 🦠 Corona-Warn-App
//

import UIKit

class AddTraceLocationTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: AddTraceLocationCellModel) {
		label.text = cellModel.text
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
    
}
