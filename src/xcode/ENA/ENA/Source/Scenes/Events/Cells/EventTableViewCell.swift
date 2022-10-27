////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class EventTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

		durationTitleLabel.text = AppStrings.Checkins.Overview.durationTitle
		accessibilityTraits = [.button]

		setCellBackgroundColor()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		subscriptions = []
		cellModel = nil
		onButtonTap = nil
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		if highlighted {
			containerView.backgroundColor = .enaColor(for: .listHighlight)
		} else {
			containerView.backgroundColor = cellBackgroundColor
		}
	}

	// MARK: - Internal

	func configure(cellModel: EventCellModel, onButtonTap: @escaping () -> Void) {
		inactiveIconImageView.isHidden = cellModel.isInactiveIconHiddenPublisher.value
		cellModel.isInactiveIconHiddenPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: inactiveIconImageView)
			.store(in: &subscriptions)

		activeContainerView.isHidden = cellModel.isActiveContainerViewHiddenPublisher.value
		cellModel.isActiveContainerViewHiddenPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: activeContainerView)
			.store(in: &subscriptions)

		button.isHidden = cellModel.isButtonHiddenPublisher.value
		cellModel.isButtonHiddenPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isHidden, on: button)
			.store(in: &subscriptions)

		durationLabel.text = cellModel.durationPublisher.value
		cellModel.durationPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: durationLabel)
			.store(in: &subscriptions)
		
		durationLabel.accessibilityLabel = cellModel.durationAccessibilityPublisher.value
		cellModel.durationAccessibilityPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.accessibilityLabel, on: durationLabel)
			.store(in: &subscriptions)
		
		timeLabel.text = cellModel.timePublisher.value
		cellModel.timePublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.text, on: timeLabel)
			.store(in: &subscriptions)
		
		timeLabel.isHidden = cellModel.timePublisher.value == nil
		cellModel.timePublisher
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.timeLabel.isHidden = $0 == nil
			}
			.store(in: &subscriptions)

		timeLabel.accessibilityLabel = cellModel.timeAccessibilityPublisher.value
		cellModel.timeAccessibilityPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.accessibilityLabel, on: timeLabel)
			.store(in: &subscriptions)
		
		activeIconImageView.isHidden = cellModel.isActiveIconHidden
		durationStackView.isHidden = cellModel.isDurationStackViewHidden

		titleLabel.attributedText = cellModel.title
		titleLabel.accessibilityLabel = cellModel.titleAccessibilityLabelPublisher.value
		titleLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Overview.eventTableViewCellTitleLabel
		cellModel.titleAccessibilityLabelPublisher
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.accessibilityLabel, on: titleLabel)
			.store(in: &subscriptions)
		
		addressLabel.text = cellModel.address
		addressLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Overview.eventTableViewCellAddressLabel

		button.setTitle(cellModel.buttonTitle, for: .normal)
		button.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton

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

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var timeLabel: ENALabel!

	@IBOutlet private weak var button: ENAButton!

	private var onButtonTap: (() -> Void)?

	private var subscriptions = Set<AnyCancellable>()
	private var cellModel: EventCellModel?
	private var cellBackgroundColor: UIColor = .enaColor(for: .cellBackground)

	private func setCellBackgroundColor() {
		if #available(iOS 13.0, *) {
			if traitCollection.userInterfaceLevel == .elevated {
				cellBackgroundColor = .enaColor(for: .cellBackground3)
			} else {
				cellBackgroundColor = .enaColor(for: .cellBackground)
			}
		}

		containerView.backgroundColor = cellBackgroundColor
	}
    
	@IBAction private func didTapButton(_ sender: Any) {
		onButtonTap?()
	}

}
