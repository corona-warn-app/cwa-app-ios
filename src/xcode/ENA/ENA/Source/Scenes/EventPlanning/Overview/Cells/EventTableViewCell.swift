////
// 🦠 Corona-Warn-App
//

import UIKit

class EventTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: EventCellModel, onButtonTap: @escaping (Event) -> Void) {
		event = cellModel.event

		titleLabel.text = cellModel.title
		locationLabel.text = cellModel.location
		timeLabel.text = cellModel.time
		dateLabel.text = cellModel.date

		button.setTitle(cellModel.buttonTitle, for: .normal)

		accessibilityTraits = cellModel.accessibilityTraits

		self.onButtonTap = onButtonTap
	}

	// MARK: - Private

	private var event: Event!

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var locationLabel: ENALabel!
	@IBOutlet private weak var timeLabel: ENALabel!
	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var button: ENAButton!

	var onButtonTap: ((Event) -> Void)?
    
	@IBAction func didTapButton(_ sender: Any) {
		onButtonTap?(event)
	}

}
