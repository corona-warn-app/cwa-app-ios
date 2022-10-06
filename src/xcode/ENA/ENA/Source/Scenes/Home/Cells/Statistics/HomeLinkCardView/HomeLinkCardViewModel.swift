//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeLinkCardViewModel {
	
	// TODO: SAP_Internal_Stats_LinkCard
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
	private(set) var buttonURL: URL?
	
	var titleAccessibilityIdentifier: String?
	var subtitleAccessibilityIdentifier: String?
	var descriptionAccessibilityIdentifier: String?
	var assetAccessibilityIdentifier: String?
	var buttonAccessibilityIdentifier: String?
	
	// MARK: - Private
	
	private let buttonTitleAttributedString: NSAttributedString = {
		let attachment = NSTextAttachment()
		if #available(iOS 13.0, *) {
			attachment.image = UIImage(
				systemName: "rectangle.portrait.and.arrow.right"
			)?.withTintColor(
				.enaColor(for: .buttonPrimary),
				renderingMode: .alwaysOriginal
			)
		} else {
			// Fallback on earlier versions
		}

		let textString = NSMutableAttributedString(
			string: "Externen Link öffnen  ",
			attributes: [
				.foregroundColor: UIColor.enaColor(for: .buttonPrimary)
			]
		)
		let imageString = NSMutableAttributedString(attachment: attachment)
		textString.append(imageString)
		
		return textString
	}()
	
	private func setupPandemicRadar(for linkCard: SAP_Internal_Stats_LinkCard) {
		title = "Pandemieradar"
		subtitle = "des Robert-Koch-Instituts"
		description = "Entdecken Sie weitere Statistiken zur Pandemie"
		asset = UIImage(named: "Illu_Radar")
		buttonTitle = buttonTitleAttributedString
		buttonURL = URL(string: linkCard.url)
	}
}

// TODO: DELETE
extension HomeLinkCardViewModel {
	static func mock(
		cardID: Int32 = 0,
		updatedAt: Int64 = 0
	) -> SAP_Internal_Stats_LinkCard {
		var cardHeader = SAP_Internal_Stats_CardHeader()
		cardHeader.cardID = cardID
		cardHeader.updatedAt = updatedAt
		
		var card = SAP_Internal_Stats_LinkCard()
		card.header = cardHeader
		card.url = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Situationsberichte/COVID-19-Trends/COVID-19-Trends.html?__blob=publicationFile#/home"
		return card
	}
}
