//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

class EUSettingsViewModel {

	// MARK: - Model.

	class CountryModel {
		let country: Country

		init(_ country: Country) {
			self.country = country
		}
	}

	// MARK: - Attributes.

	let countryModels: [CountryModel]?

	// MARK: - Initializers.

	init() {
		self.countryModels = nil
	}

	init(countries availableCountries: [Country]) {
		self.countryModels = availableCountries.sortedByLocalizedName
			.map { CountryModel($0) }
	}

	// MARK: - DynamicTableViewModel.

	func countries() -> DynamicSection {

		guard let countryModels = countryModels else {
			return DynamicSection.section(cells: [])
		}

		let cells = countryModels.isEmpty
			? [.emptyCell()]
			: countryModels.map { DynamicCell.euCell(cellModel: $0) }

		return DynamicSection.section(
			separators: countryModels.isEmpty ? .none : .inBetween,
			cells: cells
		)
	}

	func euSettingsModel() -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(UIImage(named: "Illu_EU_Interop"),
							   accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
							   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
							   height: 250),
				cells: [
					.space(height: 8),
					.title1(
						text: AppStrings.ExposureNotificationSetting.euTitle,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription1,
						  accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription2,
						  accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.ExposureNotificationSetting.euDescription3,
						accessibilityIdentifier: ""
					),
					.space(height: 16)

			]),
			countries(),
			.section(
				cells: [
					.space(height: 8),
					.body(text: AppStrings.ExposureNotificationSetting.euDescription4,
						  accessibilityIdentifier: ""
					),
					.space(height: 16)
			])
		])
	}
}
