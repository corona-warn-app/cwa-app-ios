//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class BoosterDetailsViewModel {
	
	init (
		cclService: CCLService,
		boosterNotification: DCCBoosterNotification
	) {
		self.boosterNotification = boosterNotification
		self.cclService = cclService
	}

	// MARK: - Internal
	
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
					cell.contentView.layoutMargins.left += 5
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
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOn,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn
					),
					cells: cells
				)
			)
		}
	}
	
	// MARK: - Private
	
	private let cclService: CCLService
	private let boosterNotification: DCCBoosterNotification
}
