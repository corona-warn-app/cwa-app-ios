////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DataDonationViewModel {

	// MARK: - Init

	init() {
		self.country = nil
		self.region = nil
		self.age = nil

		guard let jsonFileUrl = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			Log.debug("Failed to find url to json file", log: .ppac)
			self.allDistricts = []
			return
		}

		do {
			let jsonData = try Data(contentsOf: jsonFileUrl)
			self.allDistricts = try JSONDecoder().decode([DistrictElement].self, from: jsonData)
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			self.allDistricts = []
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var country: String?
	var region: String?
	var age: String?

	var allCountries: [String] {
		FederalStateName.allCases.map { $0.rawValue }
	}

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
						.subheadline(text: AppStrings.DataDonation.Info.description, accessibilityIdentifier: "")
					]
				)
			)
		}
	}

	// MARK: - Private

	private let allDistricts: [DistrictElement]

}
