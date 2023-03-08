//
// 🦠 Corona-Warn-App
//

import UIKit

struct EndOfLifeThankYouCellViewModel {

	// MARK: - Internal

	var title = AppStrings.Home.EndOfLifeThankYouTile.title

	var image = UIImage(named: "EndOfLifeThankYouIllustration")
	
	var description: NSAttributedString {
		let faqLinkText = AppStrings.Home.EndOfLifeThankYouTile.faqLinkText
		let faqLinkAnchor = AppStrings.Home.EndOfLifeThankYouTile.faqLinkAnchor

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

		// to.do 08.03.2023: wait for final decision whether the FAQ link is tappable or not
		// attributedString.mark(
		// 	 faqLinkText,
		//	 with: LinkHelper.urlString(suffix: faqLinkAnchor, type: .faq)
		// )

		return attributedString
	}
	
	// MARK: - Accessibility

	var titleAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.titleLabel
	var descriptionAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.descriptionLabel
	var imageAccessibilityIdentifier = AccessibilityIdentifiers.Home.EndOfLifeThankYouCell.image
}
