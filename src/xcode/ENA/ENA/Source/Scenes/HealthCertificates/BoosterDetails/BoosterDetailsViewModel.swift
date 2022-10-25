//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class BoosterDetailsViewModel {
	
	init (
		cclService: CCLServable,
		healthCertifiedPerson: HealthCertifiedPerson,
		boosterNotification: DCCBoosterNotification
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		self.boosterNotification = boosterNotification
		self.cclService = cclService
	}

	// MARK: - Internal
	
	func markBoosterRuleAsSeen() {
		healthCertifiedPerson.isNewBoosterRule = false
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = []
		
		if let titleText = boosterNotification.titleText?.localized(cclService: cclService), !titleText.isEmpty {
			cells.append(
				.title1(text: titleText)
			)
		}
		
		if let subtitleText = boosterNotification.subtitleText?.localized(cclService: cclService), !subtitleText.isEmpty {
			cells.append(
				.subheadline(text: subtitleText, color: .enaColor(for: .textPrimary2)) { _, cell, _ in
					cell.contentView.preservesSuperviewLayoutMargins = false
					
					if #available(iOS 15, *) {
						cell.contentView.layoutMargins.left += 5
					} else {
						cell.contentView.layoutMargins.left += 0
					}
					
					cell.contentView.layoutMargins.top = 0
				}
			)
		}

		if let longText = boosterNotification.longText?.localized(cclService: cclService), !longText.isEmpty {
			cells.append(
				.body(text: longText)
			)
		}
		
		if let faqAnchor = boosterNotification.faqAnchor, !faqAnchor.isEmpty {
			cells.append(
				.link(
					text: AppStrings.HealthCertificate.Person.faq,
					url: URL(string: LinkHelper.urlString(suffix: faqAnchor, type: .faq))
				)
			)
		}
		
		return DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illustration_booster_details"),
						accessibilityIdentifier: AccessibilityIdentifiers.BoosterNotification.Details.image
					),
					cells: cells
				)
			)
		}
	}
	
	// MARK: - Private
	
	private let cclService: CCLServable
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let boosterNotification: DCCBoosterNotification
}
