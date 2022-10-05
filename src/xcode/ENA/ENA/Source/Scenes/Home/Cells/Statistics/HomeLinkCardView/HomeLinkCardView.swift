//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeLinkCardView: UIView {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupLayout()
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var containerStackView: UIStackView!
	@IBOutlet private weak var middleStackView: UIStackView!

	@IBOutlet private weak var infoButton: UIButton!
	@IBOutlet private weak var deleteButton: UIButton!

	// Content dependent elements
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: StackViewLabel!
	@IBOutlet private weak var assetImageView: UIImageView!
	@IBOutlet private weak var button: ENAButton!
	
	@IBAction private func infoButtonTapped(_ sender: UIButton) {
	}
	
	@IBAction private func deleteButtonTapped(_ sender: UIButton) {
	}

	private func setupLayout() {
		containerStackView.setCustomSpacing(16, after: middleStackView)
		
	}
}
