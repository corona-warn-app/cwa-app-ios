////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateRequestTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell

		titleLabel.accessibilityTraits = [.header]
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		containerView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with cellModel: TestCertificateRequestCellModel) {
		titleLabel.text = cellModel.title
		subtitleLabel.text = cellModel.subtitle
		registrationDateLabel.text = cellModel.registrationDate

		loadingStateLabel.text = cellModel.loadingStateDescription
		loadingStateStackView.isHidden = cellModel.isLoadingStateHidden

		tryAgainButton.setTitle(cellModel.buttonTitle, for: .normal)
		tryAgainButton.isHidden = cellModel.isButtonHidden

		containerView.accessibilityElements = [titleLabel as Any, subtitleLabel as Any, registrationDateLabel as Any]

		if !cellModel.isLoadingStateHidden {
			containerView.accessibilityElements?.append(loadingStateLabel as Any)
		}

		if !cellModel.isButtonHidden {
			containerView.accessibilityElements?.append(tryAgainButton as Any)
		}
	}
	
	// MARK: - Private

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var registrationDateLabel: ENALabel!

	@IBOutlet private weak var loadingStateStackView: UIStackView!
	@IBOutlet private weak var loadingStateLabel: ENALabel!

	@IBOutlet private weak var tryAgainButton: ENAButton!

	@IBOutlet private weak var containerView: CardView!

}
