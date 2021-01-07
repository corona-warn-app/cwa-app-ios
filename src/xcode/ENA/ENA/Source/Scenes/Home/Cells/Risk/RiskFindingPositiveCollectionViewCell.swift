//
// 🦠 Corona-Warn-App
//

import UIKit

protocol RiskFindingPositiveCollectionViewCellDelegate: AnyObject {
	func nextButtonTapped(cell: RiskFindingPositiveCollectionViewCell)
}

final class RiskFindingPositiveCollectionViewCell: HomeCardCollectionViewCell {

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var chevronImageView: UIImageView!

	@IBOutlet var statusTitleLabel: ENALabel!
	@IBOutlet var statusSubtitleLabel: ENALabel!
	@IBOutlet var statusImageView: UIImageView!
	@IBOutlet var statusLineView: UIView!

	@IBOutlet var noteLabel: ENALabel!
	@IBOutlet var nextButton: ENAButton!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIView!
	@IBOutlet var statusContainer: UIView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var riskViewStackView: UIStackView!

	weak var delegate: RiskFindingPositiveCollectionViewCellDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
		stackView.setCustomSpacing(32.0, after: topContainer)
		stackView.setCustomSpacing(32.0, after: statusContainer)
		stackView.setCustomSpacing(8.0, after: noteLabel)
	}

	@IBAction func nextButtonTapped(_: UIButton) {
		delegate?.nextButtonTapped(cell: self)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		nextButton.titleLabel?.lineBreakMode = traitCollection.preferredContentSizeCategory >= .accessibilityMedium ? .byTruncatingMiddle : .byWordWrapping
		configureStackView()
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			statusImageView.isHidden = true
		} else {
			statusImageView.isHidden = false
		}
	}

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
	}

	func configureStatus(title: String, subtitle: String, titleColor: UIColor, lineColor: UIColor, imageName: String) {
		statusTitleLabel.text = title
		statusSubtitleLabel.text = subtitle

		statusTitleLabel.textColor = titleColor
		statusSubtitleLabel.textColor = titleColor

		statusLineView.backgroundColor = lineColor

		let image = UIImage(named: imageName)
		statusImageView.image = image
	}

	func configureNoteLabel(title: String) {
		noteLabel.text = title
	}

	func configureNextButton(title: String) {
		UIView.performWithoutAnimation {
			nextButton.setTitle(title, for: .normal)
			nextButton.layoutIfNeeded()
		}
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureNotesRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		riskViewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				riskViewStackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		riskViewStackView.isHidden = cellConfigurators.isEmpty
	}
}
