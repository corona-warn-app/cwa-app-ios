//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeMoreTableViewCell: UITableViewCell {
	
	// MARK: - Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.accessibilityIdentifier = AccessibilityIdentifiers.Home.MoreCell.moreCell
	}

	// MARK: - Private
	
	@IBOutlet private weak var homeCardView: HomeCardView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!
}
