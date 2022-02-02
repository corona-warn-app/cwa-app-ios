//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class BoosterDetailsViewModel {
	
	init (
		boosterNotification: DCCBoosterNotification,
		cclService: CLLService
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
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn,
						height: 200
					),
					cells: [
						.title1(text: boosterNotification.titleText?.localized(cclService: cclService)),
						.subheadline(text: boosterNotification.subtitleText?.localized(cclService: cclService), color: .enaColor(for: .textPrimary2)) { _, cell, _ in
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
						.body(text: boosterNotification.longText?.localized(cclService: cclService)),
						.body(text: "Mehr Informationen finden Sie in den FAQ.")
					]
				)
			)
		}
	}
	
	// MARK: - Private
	
	private let cclService: CCLServable
	private let boosterNotification: DCCBoosterNotification
}
