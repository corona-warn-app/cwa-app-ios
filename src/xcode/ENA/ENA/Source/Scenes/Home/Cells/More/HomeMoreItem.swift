//
// 🦠 Corona-Warn-App
//

import UIKit

enum MoreActionItem: Int, CaseIterable {
	case settings
	case recycleBin
	case appInformation
	case faq
	case share
	
	var title: String {
		switch self {
		case .settings:
			return AppStrings.Home.MoreCard.settingsTitle
		case .recycleBin:
			return AppStrings.Home.MoreCard.recycleBinTitle
		case .appInformation:
			return AppStrings.Home.MoreCard.appInformationTitle
		case .faq:
			return AppStrings.Home.MoreCard.faqTitle
		case .share:
			return AppStrings.Home.MoreCard.shareTitle
		}
	}
	
	var accessibilityIdentifier: String {
		switch self {
		case .settings:
			return AccessibilityIdentifiers.Home.MoreCell.settingsActionView
		case .recycleBin:
			return AccessibilityIdentifiers.Home.MoreCell.recycleBinActionView
		case .appInformation:
			return AccessibilityIdentifiers.Home.MoreCell.appInformationActionView
		case .faq:
			return AccessibilityIdentifiers.Home.MoreCell.faqActionView
		case .share:
			return AccessibilityIdentifiers.Home.MoreCell.shareActionView
		}
	}
	
	var image: UIImage? {
		switch self {
		case .settings:
			return UIImage(named: "more_settings")
		case .recycleBin:
			return UIImage(named: "more_recycle_bin")
		case .appInformation:
			return UIImage(named: "more_info")
		case .faq:
			return UIImage(named: "more_faq")
		case .share:
			return UIImage(named: "more_share")
		}
	}

}
