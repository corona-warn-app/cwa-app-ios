//
// 🦠 Corona-Warn-App
//

import UIKit

class EndOfLifeThankYouCellViewModel {

	// MARK: - Internal

	var title = AppStrings.Home.EndOfLifeThankYouTile.title
	var description = AppStrings.Home.EndOfLifeThankYouTile.description
	var image = UIImage(named: "EndOfLifeThankYouIllustration")
	var tintColor: UIColor = .enaColor(for: .textPrimary1)

	var titleAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.titleLabel
	var descriptionAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.descriptionLabel
	var imageAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.image
}
