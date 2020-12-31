//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeInfoCellModel {

	// MARK: - Init

	init(infoCellType: InfoCellType) {
		switch infoCellType {
		case .inviteFriends:
			self.title = AppStrings.Home.infoCardShareTitle
			self.description = AppStrings.Home.infoCardShareBody
			self.position = .first
			self.accessibilityIdentifier = AccessibilityIdentifiers.Home.infoCardShareTitle
		case .faq:
			self.title = AppStrings.Home.infoCardAboutTitle
			self.description = AppStrings.Home.infoCardAboutBody
			self.position = .last
			self.accessibilityIdentifier = AccessibilityIdentifiers.Home.infoCardAboutTitle
		case .appInformation:
			self.title = AppStrings.Home.appInformationCardTitle
			self.description = nil
			self.position = .first
			self.accessibilityIdentifier = AccessibilityIdentifiers.Home.appInformationCardTitle
		case .settings:
			self.title = AppStrings.Home.settingsCardTitle
			self.description = nil
			self.position = .last
			self.accessibilityIdentifier = AccessibilityIdentifiers.Home.settingsCardTitle
		}

	}

	// MARK: - Internal

	enum InfoCellType {
		case inviteFriends
		case faq
		case appInformation
		case settings
	}

	var title: String
	var description: String?
	var position: CellPositionInSection
	var accessibilityIdentifier: String

}
