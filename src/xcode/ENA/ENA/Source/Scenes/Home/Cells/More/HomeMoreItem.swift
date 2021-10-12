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
	

}
