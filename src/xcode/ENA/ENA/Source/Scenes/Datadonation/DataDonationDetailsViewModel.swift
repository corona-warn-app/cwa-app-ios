////
// 🦠 Corona-Warn-App
//

import UIKit

final class DataDonationDetailsViewModel {
	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
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
						// [KGA] To be updated ;-)
//						.subheadline(text: AppStrings.NewVersionFeatures.generalDescription, color: UIColor.enaColor(for: .textPrimary2), accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesGeneralDescription)
						.subheadline(text: AppStrings.DataDonation.Info.description, accessibilityIdentifier: "")
					]
				)
			)
		}
	}
	
	// MARK: - Private
}
