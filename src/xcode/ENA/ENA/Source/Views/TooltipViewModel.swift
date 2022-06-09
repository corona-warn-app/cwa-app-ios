//
// 🦠 Corona-Warn-App
//

import UIKit

class TooltipViewModel {
	var title: String {
		switch info {
		case .exportCertificates:
			return AppStrings.Tooltip.ExportCertificates.title
		case let .custom(title, _):
			return title
		}
	}

	var description: String {
		switch info {
		case .exportCertificates:
			return AppStrings.Tooltip.ExportCertificates.description
		case let .custom(title, _):
			return title
		}
	}
	
	var info: TooltipInfo
	
	init(for info: TooltipInfo) {
		self.info = info
	}
	
	enum TooltipInfo {
		case exportCertificates
		case custom(title: String, description: String)
	}
}
