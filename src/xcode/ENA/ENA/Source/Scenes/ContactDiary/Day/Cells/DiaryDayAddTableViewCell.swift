////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayAddTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: DiaryDayAddCellModel) {
		label.text = cellModel.text
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
    
}
