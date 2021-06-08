////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		backgroundGradientView.type = .solidGrey
		backgroundGradientView.layer.cornerRadius = 14
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell

		if #available(iOS 13.0, *) {
			backgroundGradientView.layer.cornerCurve = .continuous
		}
		setupAccessibility()
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		containerView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with cellModel: HomeHealthCertifiedPersonCellModel) {
		descriptionLabel.text = cellModel.description
		descriptionLabel.isHidden = cellModel.description == nil

		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name
		iconView.image = cellModel.iconImage
		backgroundImageView.image = cellModel.backgroundImage
		backgroundGradientView.type = cellModel.backgroundGradientType

		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var nameLabel: ENALabel!

	@IBOutlet private weak var backgroundImageView: UIImageView!
	@IBOutlet private weak var iconView: UIImageView!

	@IBOutlet private weak var containerView: CardView!
	@IBOutlet private weak var backgroundGradientView: GradientView!

	private func setupAccessibility() {
		containerView.accessibilityElements = [titleLabel as Any, nameLabel as Any, descriptionLabel as Any]

		titleLabel.accessibilityTraits = [.header, .button]
	}
}
