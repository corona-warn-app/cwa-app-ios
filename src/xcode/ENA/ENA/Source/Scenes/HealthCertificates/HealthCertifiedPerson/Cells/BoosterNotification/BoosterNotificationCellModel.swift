////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class BoosterNotificationCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal

	var title: String? {
		healthCertifiedPerson.dccWalletInfo?.boosterNotification.titleText?.localized()
	}

	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.boosterNotification.subtitleText?.localized()
	}

	var isUnseenNewsIndicatorVisible: Bool {
		healthCertifiedPerson.isNewBoosterRule
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson

}
