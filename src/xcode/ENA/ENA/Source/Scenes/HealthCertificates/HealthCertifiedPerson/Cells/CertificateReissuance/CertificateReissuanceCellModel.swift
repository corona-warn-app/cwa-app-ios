////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class CertificateReissuanceCellModel {

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
		healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.titleText?.localized(cclService: cclService)
	}

	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.subtitleText?.localized(cclService: cclService)
	}

	var isUnseenNewsIndicatorVisible: Bool {
		healthCertifiedPerson.isNewCertificateReissuance
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson
	let cclService: CCLServable

}
