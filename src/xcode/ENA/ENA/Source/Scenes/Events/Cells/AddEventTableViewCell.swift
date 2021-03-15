////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddEventTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: AddEventCellModel) {
		label.text = cellModel.text

		cellModel.iconImagePublisher
			.assign(to: \.image, on: iconImageView)
			.store(in: &subscriptions)

		cellModel.textColorPublisher
			.assign(to: \.textColor, on: label)
			.store(in: &subscriptions)

		cellModel.accessibilityTraitsPublisher
			.assign(to: \.accessibilityTraits, on: self)
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var iconImageView: UIImageView!
	@IBOutlet private weak var label: ENALabel!

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: AddEventCellModel?
    
}
