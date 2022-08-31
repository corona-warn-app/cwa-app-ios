//
// 🦠 Corona-Warn-App
//

import UIKit.UIFont

class MaskStateCellModel {
	
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
		healthCertifiedPerson.dccWalletInfo?.maskState.titleText?.localized(cclService: cclService)
	}
	
	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.maskState.subtitleText?.localized(cclService: cclService)
	}
	
	var badgeImage: UIImage? {
		switch healthCertifiedPerson.dccWalletInfo?.maskState.identifier {
		case .maskRequired:
			return UIImage(named: "badge_mask")
		default:
			return UIImage(named: "badge_nomask")
		}
	}
	
	var description: String? {
		healthCertifiedPerson.dccWalletInfo?.maskState.longText?.localized(cclService: cclService)
	}
	
	var faqLink: NSAttributedString? {
		guard let faqAnchor = healthCertifiedPerson.dccWalletInfo?.maskState.faqAnchor else {
			return nil
		}

		let linkText = AppStrings.HealthCertificate.Person.faqMaskState

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
	let cclService: CCLServable
}
