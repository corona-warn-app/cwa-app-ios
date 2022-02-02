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
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illustration_booster_details"),
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOn,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn
					),
					cells: [
						.title1(text: boosterNotification.titleText?.localized(cclService: cclService) ?? ""),
						.subheadline(text: boosterNotification.subtitleText?.localized(cclService: cclService) ?? "", color: .enaColor(for: .textPrimary2)) { _, cell, _ in
							cell.contentView.preservesSuperviewLayoutMargins = false
							cell.contentView.layoutMargins.left += 5
							cell.contentView.layoutMargins.top = 0
						}
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.body(text: boosterNotification.longText?.localized(cclService: cclService) ?? ""),
						.link(
							text: AppStrings.HealthCertificate.Person.faq,
							url: URL(string: LinkHelper.urlString(suffix: boosterNotification.faqAnchor ?? "", type: .faq))
						)
					]
				)
			)
		}
	}
	
	// MARK: - Private
	
	private let cclService: CCLService
	private let boosterNotification: DCCBoosterNotification
}
