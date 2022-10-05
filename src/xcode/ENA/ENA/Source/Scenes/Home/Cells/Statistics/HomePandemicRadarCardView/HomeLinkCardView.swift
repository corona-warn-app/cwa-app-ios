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
	
	@IBOutlet weak var containerStackView: UIStackView!
	@IBOutlet weak var middleStackView: UIStackView!
	@IBOutlet private weak var infoButton: UIButton!
	@IBOutlet private weak var deleteButton: UIButton!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet weak var descriptionLabel: StackViewLabel!
	@IBOutlet weak var illustrationImageView: UIImageView!
	@IBOutlet private weak var button: ENAButton!
	
	@IBAction private func infoButtonTapped(_ sender: UIButton) {
	}
	
	@IBAction private func deleteButtonTapped(_ sender: UIButton) {
	}

	private func setupLayout() {
		containerStackView.setCustomSpacing(16, after: middleStackView)
		
	}
}
