//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeThankYouTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		stackView.setCustomSpacing(16.0, after: headerImageView)
		stackView.setCustomSpacing(32.0, after: bodyLabel)
		stackView.setCustomSpacing(8.0, after: noteLabel)
		stackView.setCustomSpacing(22.0, after: riskViewStackView)
		stackView.setCustomSpacing(8.0, after: furtherInfoLabel)

		accessibilityIdentifier = AccessibilityIdentifiers.Home.thankYouCard
		setupAccessibility()
	}

	// MARK: - Internal

	func configure(
		with cellModel: HomeThankYouCellModel,
		onPrimaryAction: @escaping () -> Void
	) {
		containerView.backgroundColor = cellModel.backgroundColor

		titleLabel.text = cellModel.title
		titleLabel.textColor = cellModel.titleColor

		headerImageView.image = UIImage(named: cellModel.imageName)

		bodyLabel.text = cellModel.body
		bodyLabel.textColor = cellModel.titleColor

		noteLabel.text = cellModel.noteTitle

		furtherInfoLabel.text = cellModel.furtherInfoTitle

		// Configure risk stack view

		riskViewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for itemModel in cellModel.homeItemViewModels {
			let nibName = String(describing: itemModel.ViewType)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let itemView = nib.instantiate(withOwner: self, options: nil).first as? HomeItemViewAny {
				riskViewStackView.addArrangedSubview(itemView)
				itemView.configureAny(with: itemModel)
			}
		}

		riskViewStackView.isHidden = riskViewStackView.arrangedSubviews.isEmpty

		// Configure further info stack view

		furtherInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for itemModel in cellModel.furtherHomeItemViewModels {
			let nibName = String(describing: itemModel.ViewType)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let itemView = nib.instantiate(withOwner: self, options: nil).first as? HomeItemViewAny {
				furtherInfoStackView.addArrangedSubview(itemView)
				itemView.configureAny(with: itemModel)
			}
		}

		furtherInfoStackView.isHidden = furtherInfoStackView.arrangedSubviews.isEmpty

		reenableTitleLabel.text = cellModel.reenableTitle
		reenableBodyLabel.text = cellModel.reenableBody
		reenableButton.setTitle(cellModel.reenableButtonTitle, for: .normal)

		testResultTitleLabel.text = cellModel.reenableTestResultTitle

		var testResultSubtitle = cellModel.reenableTestResultSubtitle

		if let timeStamp = cellModel.testResultTimestamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			let dateString = formatter.string(from: date)

			testResultSubtitle += String(format: "\n\(cellModel.reenableTestResultRegistration)", dateString)
		}

		testResultSubtitleLabel.text = testResultSubtitle

		self.onPrimaryAction = onPrimaryAction
	}

	// MARK: - Private

	// MARK: Thank you card

	@IBOutlet private weak var containerView: UIView!
	@IBOutlet private weak var stackView: UIStackView!

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var headerImageView: UIImageView!
	@IBOutlet private weak var bodyLabel: ENALabel!

	@IBOutlet private weak var noteLabel: ENALabel!
	@IBOutlet private weak var riskViewStackView: UIStackView!

	@IBOutlet private weak var furtherInfoLabel: ENALabel!
	@IBOutlet private weak var furtherInfoStackView: UIStackView!

	// MARK: Reenable card

	@IBOutlet private weak var reenableTitleLabel: ENALabel!
	@IBOutlet private weak var testResultTitleLabel: ENALabel!
	@IBOutlet private weak var testResultSubtitleLabel: ENALabel!
	@IBOutlet private weak var reenableBodyLabel: ENALabel!
	@IBOutlet private weak var reenableButton: ENAButton!

	@IBAction func didTapReenableButton(_ sender: Any) {
		onPrimaryAction?()
	}

	private var onPrimaryAction: (() -> Void)?

	func setupAccessibility() {
		containerView.accessibilityElements = [
			titleLabel as Any,
			bodyLabel as Any,
			noteLabel as Any,
			riskViewStackView as Any,
			furtherInfoLabel as Any,
			furtherInfoStackView as Any,
			reenableTitleLabel as Any,
			testResultTitleLabel as Any,
			testResultSubtitleLabel as Any,
			reenableBodyLabel as Any,
			reenableButton as Any
		]

		titleLabel.accessibilityTraits = .header
	}

	@IBAction private func primaryActionTriggered() {
		onPrimaryAction?()
	}

}
