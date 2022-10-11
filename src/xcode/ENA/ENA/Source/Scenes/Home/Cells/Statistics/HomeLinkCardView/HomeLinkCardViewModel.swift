//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeLinkCardViewModel {
	
	// MARK: - Init

	init(for linkCard: SAP_Internal_Stats_LinkCard) {
		switch HomeLinkCard(rawValue: linkCard.header.cardID) {
		case .pandemicRadar:
			setupPandemicRadar(for: linkCard)
		case .none:
			Log.info("Link card ID \(linkCard.header.cardID) is not supported", log: .ui)
		}
	}
	
	// MARK: - Internal
	
	@OpenCombine.Published private(set) var title: String?
	@OpenCombine.Published private(set) var subtitle: String?
	@OpenCombine.Published private(set) var description: String?
	@OpenCombine.Published private(set) var asset: UIImage?
	@OpenCombine.Published private(set) var buttonTitle: NSAttributedString?
	@OpenCombine.Published private(set) var buttonURL: URL?
	
	@OpenCombine.Published private(set) var titleAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var subtitleAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var descriptionAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var assetAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var buttonAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var infoButtonAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var deleteButtonAccessibilityIdentifier: String?
	
	@OpenCombine.Published private(set) var titleAccessibilityLabel: String?
	@OpenCombine.Published private(set) var subtitleAccessibilityLabel: String?
	@OpenCombine.Published private(set) var descriptionAccessibilityLabel: String?
	@OpenCombine.Published private(set) var assetAccessibilityLabel: String?
	@OpenCombine.Published private(set) var buttonAccessibilityLabel: String?
	@OpenCombine.Published private(set) var infoButtonAccessibilityLabel: String?
	@OpenCombine.Published private(set) var deleteButtonAccessibilityLabel: String?
	
	// MARK: - Private
	
	private let buttonTitleAttributedString: NSAttributedString = {
		let textAttachment = NSTextAttachment()
		if #available(iOS 13.0, *) {
			textAttachment.image = UIImage(
				systemName: "rectangle.portrait.and.arrow.right",
				withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
			)?.withTintColor(
				.enaColor(for: .buttonPrimary),
				renderingMode: .alwaysOriginal
			)
		} else {
			// Fallback iOS 12
			// UIImage(named: "Icons_Link")
		}

		let textString = NSMutableAttributedString(
			string: AppStrings.Statistics.Card.LinkCardCommon.buttonTitle,
			attributes: [
				.foregroundColor: UIColor.enaColor(for: .buttonPrimary),
				.font: UIFont.enaFont(for: .body, weight: .semibold)
			]
		)
		let imageString = NSMutableAttributedString(attachment: textAttachment)
		textString.append(imageString)
		
		return textString
	}()
	
	private func setupPandemicRadar(for linkCard: SAP_Internal_Stats_LinkCard) {
		title = AppStrings.Statistics.Card.PandemicRadar.title
		subtitle = AppStrings.Statistics.Card.PandemicRadar.subtitle
		description = AppStrings.Statistics.Card.PandemicRadar.description
		asset = UIImage(named: "Illu_Radar")
		buttonTitle = buttonTitleAttributedString
		buttonURL = URL(string: linkCard.url)
		
		titleAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.titleLabel
		subtitleAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.subtitleLabel
		descriptionAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.descriptionLabel
		assetAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.asset
		buttonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.button
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.infoButton
		deleteButtonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.deleteButton
	}
}
