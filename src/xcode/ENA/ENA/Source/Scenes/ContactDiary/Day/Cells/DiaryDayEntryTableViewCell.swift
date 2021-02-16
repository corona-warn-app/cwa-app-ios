////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: DiaryDayEntryCellModel) {
		checkboxImageView.image = cellModel.image
		label.text = cellModel.text

		parametersContainerStackView.isHidden = cellModel.parametersHidden

		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
	@IBOutlet private weak var checkboxImageView: UIImageView!
	@IBOutlet private weak var parametersContainerStackView: UIStackView!
	@IBOutlet private weak var parametersStackView: UIStackView!

}
