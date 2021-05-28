////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		captionLabel.text = AppStrings.HealthCertificate.Overview.Person.caption
		titleLabel.text = AppStrings.HealthCertificate.Overview.Person.title
		backgroundGradientView.type = .solidGrey
		backgroundGradientView.layer.cornerRadius = 14
		accessibilityIdentifier = AccessibilityIdentifiers.Home.healthCertificateButton

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

		iconView.image = cellModel.iconImage
		backgroundGradientView.type = cellModel.backgroundGradientType
	}
	
	// MARK: - Private

	@IBOutlet private weak var captionLabel: ENALabel!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var vaccinationStateLabel: ENALabel!

	@IBOutlet private weak var iconView: UIImageView!

	@IBOutlet private weak var containerView: HomeCardView!
	@IBOutlet private weak var backgroundGradientView: GradientView!

	private func setupAccessibility() {
		containerView.accessibilityElements = [captionLabel as Any, titleLabel as Any, vaccinationStateLabel as Any]

		captionLabel.accessibilityTraits = [.header, .button]

	}
}
