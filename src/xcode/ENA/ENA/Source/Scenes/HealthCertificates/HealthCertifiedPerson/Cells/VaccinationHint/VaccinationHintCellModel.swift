////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class VaccinationHintCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		cclService: CCLService
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.cclService = cclService
	}

	// MARK: - Internal

	var title: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.titleText?.localized(cclService: cclService)
	}

	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.subtitleText?.localized(cclService: cclService)
	}

	var description: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.longText?.localized(cclService: cclService)
	}

	var faqLink: NSAttributedString? {
		let text = String(
			format: AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQ,
			AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQPlaceholder
		)

		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: ENAFont.body.textStyle)
				.scaledFont(
					size: ENAFont.body.fontSize,
					weight: ENAFont.body.fontWeight
				),
			.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]
		let attributedString = NSMutableAttributedString(
			string: text,
			attributes: textAttributes
		)

		attributedString.mark(
			AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQPlaceholder,
			with: AppStrings.Links.healthCertificateBoosterFAQ
		)

		return attributedString
	}

	var isUnseenNewsIndicatorVisible: Bool {
		healthCertifiedPerson.isNewBoosterRule
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson
	let cclService: CCLService
}
