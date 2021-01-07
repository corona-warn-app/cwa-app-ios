//
// 🦠 Corona-Warn-App
//

import UIKit

protocol RiskCollectionViewCellDelegate: AnyObject {
	func contactButtonTapped(cell: RiskCollectionViewCell)
}

/// A cell that visualizes the current risk and allows the user to calculate he/his current risk.
final class RiskCollectionViewCell: HomeCardCollectionViewCell {
	// MARK: Properties

	weak var delegate: RiskCollectionViewCellDelegate?

	// MARK: Outlets

	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var bodyLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var contactButton: UIButton!
	@IBOutlet var viewContainer: UIView!

	// MARK: Actions

	@IBAction func contactButtonTapped(_: UIButton) {
		delegate?.contactButtonTapped(cell: self)
	}

	// MARK: Configuring the UI

	func configure(with propertyHolder: HomeRiskCellPropertyHolder, delegate: RiskCollectionViewCellDelegate) {
		self.delegate = delegate

		print(#function)

		titleLabel.text = propertyHolder.title
		titleLabel.textColor = propertyHolder.titleColor
		bodyLabel.text = propertyHolder.body
		dateLabel.text = propertyHolder.date
		dateLabel.isHidden = propertyHolder.date == nil
		viewContainer.backgroundColor = propertyHolder.color
		chevronImageView.tintColor = propertyHolder.chevronTintColor
		chevronImageView.image = propertyHolder.chevronImage
		iconImageView.image = propertyHolder.iconImage
		contactButton.setTitle(AppStrings.Home.riskCardButton, for: .normal)

		backgroundColor = UIColor.preferredColor(for: .backgroundBase)
		viewContainer.backgroundColor = UIColor.preferredColor(for: .backgroundBase)
	}
}
