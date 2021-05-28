////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		titleLabel.text = AppStrings.HealthCertificate.Overview.VaccinationCertificate.title
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
		vaccinationStateLabel.text = cellModel.vaccinationStateDescription
		vaccinationStateLabel.isHidden = cellModel.vaccinationStateDescription == nil

		nameLabel.text = cellModel.name
		iconView.image = cellModel.iconImage
		backgroundImageView.image = cellModel.backgroundImage
		backgroundGradientView.type = cellModel.backgroundGradientType
	}
	
	// MARK: - Private

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var vaccinationStateLabel: ENALabel!
	@IBOutlet private weak var nameLabel: ENALabel!

	@IBOutlet private weak var backgroundImageView: UIImageView!
	@IBOutlet private weak var iconView: UIImageView!

	@IBOutlet private weak var containerView: HomeCardView!
	@IBOutlet private weak var backgroundGradientView: GradientView!

	private func setupAccessibility() {
		containerView.accessibilityElements = [titleLabel as Any, nameLabel as Any, vaccinationStateLabel as Any]

		titleLabel.accessibilityTraits = [.header, .button]
	}
}
