//
// 🦠 Corona-Warn-App
//

import UIKit

class TooltipViewModel {
	
	// MARK: - Init
	
	init(for info: TooltipInfo) {
		self.info = info
	}
	
	// MARK: - Internal

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
		case let .custom(_, description):
			return description
		}
	}
	
	// MARK: - Private
	
	private let info: TooltipInfo
}

extension TooltipViewModel {
	enum TooltipInfo {
		case exportCertificates
		case custom(title: String, description: String)
	}
}
