//
// 🦠 Corona-Warn-App
//

import UIKit

protocol RiskLevelCollectionViewCellDelegate: AnyObject {
	func updateButtonTapped(cell: RiskLevelCollectionViewCell)
}

/// A cell that visualizes the current risk and allows the user to calculate he/his current risk.
final class RiskLevelCollectionViewCell: HomeCardCollectionViewCell {
	// MARK: Properties

	weak var delegate: RiskLevelCollectionViewCellDelegate?

	// MARK: Outlets

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var bodyLabel: ENALabel!
	@IBOutlet var updateButton: ENAButton!

	@IBOutlet var viewContainer: UIView!
	@IBOutlet var topContainer: UIStackView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var riskViewStackView: UIStackView!

	// MARK: Nib Loading

	// Ignore touches on the button when it's disabled
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let buttonPoint = convert(point, to: updateButton)
		let containsPoint = updateButton.bounds.contains(buttonPoint)
		if containsPoint, !updateButton.isEnabled {
			return nil
		}
		return super.hitTest(point, with: event)
	}

	// MARK: Actions

	@IBAction func updateButtonTapped(_: UIButton) {
		delegate?.updateButtonTapped(cell: self)
	}

	// MARK: Configuring the UI

	func configureTitle(title: String, titleColor: UIColor) {
		titleLabel.text = title
		titleLabel.textColor = titleColor
	}

	func configureBody(text: String, bodyColor: UIColor, isHidden: Bool) {
		bodyLabel.text = text
		bodyLabel.textColor = bodyColor
		bodyLabel.isHidden = isHidden
	}

	func configureBackgroundColor(color: UIColor) {
		viewContainer.backgroundColor = color
	}

	func configureUpdateButton(title: String, isEnabled: Bool, isHidden: Bool, accessibilityIdentifier: String?) {
		updateButton.setTitle(title, for: .normal)
		updateButton.isEnabled = isEnabled
		updateButton.isHidden = isHidden
		updateButton.isHidden = isHidden
		updateButton.isAccessibilityElement = true
		updateButton.accessibilityLabel = title
		updateButton.accessibilityIdentifier = accessibilityIdentifier
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
