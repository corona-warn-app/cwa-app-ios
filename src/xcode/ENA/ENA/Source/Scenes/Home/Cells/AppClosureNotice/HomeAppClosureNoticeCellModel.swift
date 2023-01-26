//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeAppClosureNoticeCellModel {

	// MARK: - Init

	init(cclService: CCLServable, statusTabNotice: StatusTabNotice?) {
		self.update(cclService: cclService, statusTabNotice: statusTabNotice)
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String?
	@OpenCombine.Published var subtitle: String?
	@OpenCombine.Published var icon: UIImage?
	@OpenCombine.Published var accessibilityIdentifier: String?

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private func update(cclService: CCLServable, statusTabNotice: StatusTabNotice?) {
		if let titleText = statusTabNotice?.titleText?.localized(cclService: cclService), !titleText.isEmpty {
			title = titleText
		}
		if let subtitleText = statusTabNotice?.subtitleText?.localized(cclService: cclService), !subtitleText.isEmpty {
			subtitle = subtitleText
		}

		icon = UIImage(named: "Icons_Attention_high")
		accessibilityIdentifier = AccessibilityIdentifiers.Home.AppClosureNoticeCell.container
	}

}
