////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(entry: DiaryEntry) {
		let cellModel = DiaryDayEntryCellModel(entry: entry)

		checkboxImageView.image = cellModel.image
		label.text = cellModel.text
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	@IBOutlet private weak var label: ENALabel!
	@IBOutlet private weak var checkboxImageView: UIImageView!

}
