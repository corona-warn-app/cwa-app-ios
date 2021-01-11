//
// 🦠 Corona-Warn-App
//

import UIKit

protocol RiskFailedCollectionViewCellDelegate: AnyObject {
	func activeButtonTapped(cell: RiskFailedCollectionViewCell)
}

final class RiskFailedCollectionViewCell: HomeCardCollectionViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		stackView.setCustomSpacing(16.0, after: riskViewStackView)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		activeButton.titleLabel?.lineBreakMode = traitCollection.preferredContentSizeCategory >= .accessibilityMedium ? .byTruncatingMiddle : .byWordWrapping
	}

	// MARK: - Internal

	weak var delegate: RiskFailedCollectionViewCellDelegate?

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var bodyLabel: ENALabel!
	@IBOutlet var activeButton: ENAButton!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var riskViewStackView: UIStackView!

	@IBAction func activeButtonTapped(_: UIButton) {
		delegate?.activeButtonTapped(cell: self)
	}

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
	}

	func configureBody(text: String, bodyColor: UIColor) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureActiveButton(title: String) {
		UIView.performWithoutAnimation {
			activeButton.setTitle(title, for: .normal)
			activeButton.layoutIfNeeded()
		}
	}

	func configureRiskViews(cellConfigurators: [HomeRiskViewConfiguratorAny]) {
		riskViewStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for itemConfigurator in cellConfigurators {
			let nibName = itemConfigurator.viewAnyType.stringName()
			let nib = UINib(nibName: nibName, bundle: .main)
			if let riskView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
				riskViewStackView.addArrangedSubview(riskView)
				itemConfigurator.configureAny(riskView: riskView)
			}
		}
		if let riskItemView = riskViewStackView.arrangedSubviews.last as? RiskItemViewSeparatorable {
			riskItemView.hideSeparator()
		}
		riskViewStackView.isHidden = cellConfigurators.isEmpty
	}
}
