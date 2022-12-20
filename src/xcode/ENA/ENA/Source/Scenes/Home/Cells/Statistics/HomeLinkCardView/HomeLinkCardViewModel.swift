//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeLinkCardViewModel {
	
	// MARK: - Init

	init(for linkCard: SAP_Internal_Stats_LinkCard) {
		switch HomeLinkCard(rawValue: linkCard.header.cardID) {
		case .rkiPandemicRadar:
			setupPandemicRadar(for: linkCard, type: .rkiPandemicRadar)
		case .bmgPandemicRadar:
			setupPandemicRadar(for: linkCard, type: .bmgPandemicRadar)
		case .none:
			Log.info("Link card ID \(linkCard.header.cardID) is not supported", log: .ui)
		}
	}
	
	// MARK: - Internal
	
	@OpenCombine.Published private(set) var title: String?
	@OpenCombine.Published private(set) var subtitle: String?
	@OpenCombine.Published private(set) var description: String?
	@OpenCombine.Published private(set) var image: UIImage?
	@OpenCombine.Published private(set) var buttonTitle: NSAttributedString?
	@OpenCombine.Published private(set) var buttonURL: URL?
	
	@OpenCombine.Published private(set) var titleAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var subtitleAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var descriptionAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var imageAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var buttonAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var infoButtonAccessibilityIdentifier: String?
	@OpenCombine.Published private(set) var deleteButtonAccessibilityIdentifier: String?
	
	@OpenCombine.Published private(set) var titleAccessibilityLabel: String?
	@OpenCombine.Published private(set) var subtitleAccessibilityLabel: String?
	@OpenCombine.Published private(set) var descriptionAccessibilityLabel: String?
	@OpenCombine.Published private(set) var imageAccessibilityLabel: String?
	@OpenCombine.Published private(set) var buttonAccessibilityLabel: String?
	@OpenCombine.Published private(set) var infoButtonAccessibilityLabel: String?
	@OpenCombine.Published private(set) var deleteButtonAccessibilityLabel: String?
	
	func updateButtonTitle() {
		buttonTitle = buttonTitleAttributedString
	}
	
	// MARK: - Private
	
	private enum pandemicRadarType {
		// < 3.0.0
		case rkiPandemicRadar
		// >= 3.0.0
		case bmgPandemicRadar
	}
	
	private var buttonTitleAttributedString: NSAttributedString {
		let textAttachment = NSTextAttachment()
		
		if #available(iOS 15.0, *) {
			textAttachment.image = .sfSymbol(
				.rectanglePortraitAndArrowRight,
				withConfiguration: .init(weight: .semibold),
				withTintColor: .enaColor(for: .buttonLinkCard)
			)
		} else {
			textAttachment.image = UIImage(named: "export_icon")
		}

		let textString = NSMutableAttributedString(
			string: "\(AppStrings.Statistics.Card.LinkCard.buttonTitle)  ",
			attributes: [
				.foregroundColor: UIColor.enaColor(for: .buttonLinkCard),
				.font: UIFont.enaFont(for: .body, weight: .semibold)
			]
		)
		let imageString = NSMutableAttributedString(attachment: textAttachment)
		textString.append(imageString)
		
		return textString
	}
	
	private func setupPandemicRadar(for linkCard: SAP_Internal_Stats_LinkCard, type: pandemicRadarType) {
		title = AppStrings.Statistics.Card.PandemicRadar.title
		subtitle = AppStrings.Statistics.Card.PandemicRadar.subtitle
		description = AppStrings.Statistics.Card.PandemicRadar.description
		image = UIImage(named: "Illu_Radar")
		buttonTitle = buttonTitleAttributedString
		
		switch type {
		case .rkiPandemicRadar:
			buttonURL = URL(string: linkCard.url)
		case .bmgPandemicRadar:
			if let locale = (Locale.current.languageCode == "de" || Locale.current.languageCode == "tr") ? Locale.current.languageCode : "en" {
				let urlString = linkCard.url.replacingOccurrences(of: ":lang", with: locale)
				buttonURL = URL(string: urlString)
			}
		}
		
		titleAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.titleLabel
		subtitleAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.subtitleLabel
		descriptionAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.descriptionLabel
		imageAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.image
		buttonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.button
		infoButtonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.infoButton
		deleteButtonAccessibilityIdentifier = AccessibilityIdentifiers.LinkCard.PandemicRadar.deleteButton
	}
}
