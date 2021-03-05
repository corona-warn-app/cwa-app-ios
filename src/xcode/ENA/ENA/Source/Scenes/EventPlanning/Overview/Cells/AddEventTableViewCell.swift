////
// 🦠 Corona-Warn-App
//

import UIKit

class AddEventTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: AddEventCellModel) {
		label.text = cellModel.text
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
    
}
