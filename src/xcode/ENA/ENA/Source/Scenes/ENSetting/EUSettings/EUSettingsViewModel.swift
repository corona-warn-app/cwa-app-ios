//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import Combine
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

	let countryModels: [CountryModel]

	// MARK: - Initializers.

	init(countries availableCountries: [Country]) {
		self.countryModels = availableCountries
			.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
			.map { CountryModel($0) }
	}

	// MARK: - DynamicTableViewModel.

	func countries() -> DynamicSection {
		let cells = countryModels.isEmpty
			// TODO: This cell needs to be adjusted.
			? [.body(text: "No countries could be accessed.", accessibilityIdentifier: "")]
			: countryModels.map { DynamicCell.euCell(cellModel: $0) }

		return DynamicSection.section(
			separators: !countryModels.isEmpty,
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
			countries()
		])
	}
}
