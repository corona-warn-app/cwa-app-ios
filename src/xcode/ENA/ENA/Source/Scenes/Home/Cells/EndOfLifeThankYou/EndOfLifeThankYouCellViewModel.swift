//
// 🦠 Corona-Warn-App
//

import UIKit

class EndOfLifeThankYouCellViewModel {

	// MARK: - Internal

	var title = AppStrings.Home.EndOfLifeThankYouTile.title

	var image = UIImage(named: "EndOfLifeThankYouIllustration")
	
	var description: NSAttributedString {
		let faqLinkText = AppStrings.Home.EndOfLifeThankYouTile.faqLinkText

		let string = String(
			format: AppStrings.Home.EndOfLifeThankYouTile.description,
			faqLinkText
		)

		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.enaFont(for: .body),
			.foregroundColor: UIColor.enaColor(for: .textPrimary2)
		]
		
		
		let attributedString = NSMutableAttributedString(
			string: string,
			attributes: textAttributes
		)

		 attributedString.mark(faqLinkText, with: AppStrings.Home.EndOfLifeThankYouTile.faqLinkAnchor)

		return attributedString
	}
	
	// MARK: - Accessibility

	var titleAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.titleLabel
	var descriptionAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.descriptionLabel
	var imageAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.image
}
