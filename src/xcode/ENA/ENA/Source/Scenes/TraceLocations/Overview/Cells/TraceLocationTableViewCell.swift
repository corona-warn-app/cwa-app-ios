////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		containerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			containerView.layer.cornerCurve = .continuous
		}

		activeContainerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			activeContainerView.layer.cornerCurve = .continuous
		}

		durationTitleLabel.text = AppStrings.TraceLocations.Overview.durationTitle
		accessibilityTraits = [.button]
	}

	// MARK: - Internal

	func configure(cellModel: EventCellModel, onButtonTap: @escaping () -> Void) {
		cellModel.isInactiveIconHiddenPublisher
			.assign(to: \.isHidden, on: inactiveIconImageView)
			.store(in: &subscriptions)

		cellModel.isActiveContainerViewHiddenPublisher
			.assign(to: \.isHidden, on: activeContainerView)
			.store(in: &subscriptions)

		cellModel.isButtonHiddenPublisher
			.assign(to: \.isHidden, on: button)
			.store(in: &subscriptions)

		cellModel.durationPublisher
			.assign(to: \.text, on: durationLabel)
			.store(in: &subscriptions)

		cellModel.timePublisher
			.assign(to: \.text, on: timeLabel)
			.store(in: &subscriptions)

		activeIconImageView.isHidden = cellModel.isActiveIconHidden
		durationStackView.isHidden = cellModel.isDurationStackViewHidden

		titleLabel.text = cellModel.title
		addressLabel.text = cellModel.address
		dateLabel.text = cellModel.date

		button.setTitle(cellModel.buttonTitle, for: .normal)

		self.onButtonTap = onButtonTap

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var containerView: UIView!

	@IBOutlet private weak var inactiveIconImageView: UIImageView!

	@IBOutlet private weak var activeContainerView: UIView!
	@IBOutlet private weak var activeIconImageView: UIImageView!

	@IBOutlet private weak var durationStackView: UIStackView!
	@IBOutlet private weak var durationTitleLabel: ENALabel!
	@IBOutlet private weak var durationLabel: ENALabel!

	@IBOutlet private weak var dateLabel: ENALabel!

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var timeLabel: ENALabel!

	@IBOutlet private weak var button: ENAButton!

	private var onButtonTap: (() -> Void)?

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: EventCellModel?
    
	@IBAction private func didTapButton(_ sender: Any) {
		onButtonTap?()
	}

}
