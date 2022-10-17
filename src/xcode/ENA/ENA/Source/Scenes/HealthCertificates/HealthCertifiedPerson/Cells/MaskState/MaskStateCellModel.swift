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
		healthCertifiedPerson.dccWalletInfo?.maskState?.titleText?.localized(cclService: cclService)
	}
	
	var subtitle: String? {
		healthCertifiedPerson.dccWalletInfo?.maskState?.subtitleText?.localized(cclService: cclService)
	}
	
	var badgeImage: UIImage? {
		guard let maskStateIdentifier = healthCertifiedPerson.dccWalletInfo?.maskState?.identifier else { return nil }
		
		switch maskStateIdentifier {
		case .maskRequired:
			return UIImage(named: "Badge_mask")
		case .maskOptional:
			return UIImage(named: "Badge_nomask")
		case .other:
			return nil
		}
	}
	
	var description: String? {
		healthCertifiedPerson.dccWalletInfo?.maskState?.longText?.localized(cclService: cclService)
	}
	
	var faqLink: NSAttributedString? {
		guard let faqAnchor = healthCertifiedPerson.dccWalletInfo?.maskState?.faqAnchor else {
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
	
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let cclService: CCLServable
}
