////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddTraceLocationTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: AddTraceLocationCellModel) {
		label.text = cellModel.text

		cellModel.$iconImage
			.assign(to: \.image, on: iconImageView)
			.store(in: &subscriptions)

		cellModel.$textColor
			.assign(to: \.textColor, on: label)
			.store(in: &subscriptions)

		cellModel.$accessibilityTraits
			.assign(to: \.accessibilityTraits, on: self)
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var iconImageView: UIImageView!
	@IBOutlet private weak var label: ENALabel!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: AddTraceLocationCellModel?
    
}
