//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeLinkCardViewModel {
	
	// TODO: SAP_Internal_Stats_LinkCard
	init() {
//		switch HomeLinkCard(rawValue: linkCard.header.cardID) {
//		case .pandemicRadar:
//			setupPandemicRadar()
//		}
	}
	
	// MARK: - Internal
	
	@OpenCombine.Published private(set) var title: String?
	@OpenCombine.Published private(set) var subtitle: String?
	@OpenCombine.Published private(set) var description: String?
	@OpenCombine.Published private(set) var asset: UIImage?
	@OpenCombine.Published private(set) var buttonTitle: String?
	
	var titleAccessibilityIdentifier: String?
	var subtitleAccessibilityIdentifier: String?
	var descriptionAccessibilityIdentifier: String?
	var assetAccessibilityIdentifier: String?
	var buttonTitleAccessibilityIdentifier: String?
	
	// MARK: - Private
	
	private func setupPandemicRadar() {
		
	}
}
