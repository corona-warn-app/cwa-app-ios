////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class BoosterNotificationCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		cclService: CCLServable
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.cclService = cclService
	}

	// MARK: - Internal

	var title: String? {
		healthCertifiedPerson.dccWalletInfo?.boosterNotification.titleText?.localized(cclService: cclService)
	}

	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.boosterNotification.subtitleText?.localized(cclService: cclService)
	}

	var isUnseenNewsIndicatorVisible: Bool {
		healthCertifiedPerson.isNewBoosterRule
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson
	let cclService: CCLServable

}
