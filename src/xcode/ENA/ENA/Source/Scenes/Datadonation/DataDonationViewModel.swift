////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DataDonationViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var country: String?
	var region: String?
	var age: String?
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_DataDonation"),
						accessibilityLabel: "AppStrings.DataDonation.Info.accImageDescription",
						accessibilityIdentifier: "AccessibilityIdentifiers.DataDonation.accImageDescription",
						height: 250
					),
					cells: [
						.title1(text: AppStrings.DataDonation.Info.title, accessibilityIdentifier: "AppStrings.DataDonation.Info.title"),
						.headline(text: AppStrings.DataDonation.Info.description)
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.headline(text: AppStrings.DataDonation.Info.subHeadState),
						.headline(text: AppStrings.DataDonation.Info.subHeadState)
					]
				)
			)
			
		}
	}

	// MARK: - Private
}
