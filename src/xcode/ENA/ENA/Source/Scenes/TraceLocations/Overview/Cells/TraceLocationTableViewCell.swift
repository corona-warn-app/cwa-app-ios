////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		containerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			containerView.layer.cornerCurve = .continuous
		}

		gradientContainer.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			gradientContainer.layer.cornerCurve = .continuous
		}

		accessibilityTraits = [.button]
	}

	// MARK: - Internal

	func configure(cellModel: TraceLocationCellModel, onButtonTap: @escaping () -> Void) {
		titleLabel.text = cellModel.title
		addressLabel.text = cellModel.address
		timeLabel.text = cellModel.time
		dateLabel.text = cellModel.date

		button.setTitle(cellModel.buttonTitle, for: .normal)

		self.onButtonTap = onButtonTap
	}

	// MARK: - Private

	@IBOutlet private weak var containerView: UIView!
	@IBOutlet private weak var gradientContainer: UIView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var timeLabel: ENALabel!
	@IBOutlet private weak var dateLabel: ENALabel!
	@IBOutlet private weak var button: ENAButton!

	private var onButtonTap: (() -> Void)?
    
	@IBAction private func didTapButton(_ sender: Any) {
		onButtonTap?()
	}

}
