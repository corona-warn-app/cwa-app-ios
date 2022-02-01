////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class VaccinationStateCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal

	var title: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.titleText?.localized()
	}

	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.subtitleText?.localized()
	}

	var description: String? {
		healthCertifiedPerson.dccWalletInfo?.vaccinationState.longText?.localized()
	}

	var faqLink: NSAttributedString? {
		guard let faqAnchor = healthCertifiedPerson.dccWalletInfo?.vaccinationState.faqAnchor else {
			return nil
		}

		let linkText = AppStrings.HealthCertificate.Person.faq

		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: ENAFont.body.textStyle)
				.scaledFont(
					size: ENAFont.body.fontSize,
					weight: ENAFont.body.fontWeight
				),
			.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]
		let attributedString = NSMutableAttributedString(
			string: linkText,
			attributes: textAttributes
		)

		attributedString.mark(
			linkText,
			with: LinkHelper.urlString(suffix: faqAnchor, type: .faq)
		)

		return attributedString
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson

}
