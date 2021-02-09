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
	
	// [KGA] add accessibilityLabel and identifier back to cell
//	accessibilityLabel: AppStrings.NewVersionFeatures.accImageLabel,
//	accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription,
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_DataDonation"),
						accessibilityLabel: "AppStrings.NewVersionFeatures.accImageLabel",
						accessibilityIdentifier: "AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription",
						height: 250
					),
					cells: [
						// [KGA] To be updated ;-)
//						.subheadline(text: AppStrings.NewVersionFeatures.generalDescription, color: UIColor.enaColor(for: .textPrimary2), accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesGeneralDescription)
						.subheadline(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent quis hendrerit leo. Vivamus suscipit arcu vitae enim gravida, ac sagittis arcu scelerisque. Sed pretium enim dui, in faucibus leo sagittis ac. Nam at ex eget nulla finibus condimentum at sed tortor. Quisque faucibus, dui sed maximus rhoncus, lacus augue tincidunt arcu, vitae ultricies eros erat non ipsum. Suspendisse varius lacus felis, a posuere nisi elementum eget. Etiam posuere purus vitae ligula euismod, quis viverra turpis condimentum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Duis ac risus ac urna volutpat pulvinar. Donec finibus, quam id congue varius, quam augue semper quam, quis finibus sapien mauris et diam. Proin augue tortor, faucibus at consequat vitae, ullamcorper vel neque. Donec scelerisque mauris pharetra dui sagittis, vel aliquam diam rutrum.", accessibilityIdentifier: "datanoation.wip")
					]
				)
			)
		}
	}

	// MARK: - Private
}
