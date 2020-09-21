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

	private var subscriptions = Set<AnyCancellable>()
	// @Published var euTracingSettings: EUTracingSettings
	let countryModels: [CountryModel]

	// MARK: - Initializers.

	init(countries availableCountries: [Country]/*, euTracingSettings: EUTracingSettings*/) {
		self.countryModels = availableCountries.map { CountryModel($0) }
		// self.euTracingSettings = euTracingSettings
	}

	// MARK: - DynamicTableViewModel.

	func countrySwitchSection() -> DynamicSection {
		DynamicSection.section(
			separators: true,
			cells: countryModels.map { model in
				DynamicCell.euCell(cellModel: model)
			}
		)
	}

	func euSettingsModel() -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(UIImage(named: "Illu_Submission_AndereWarnen"),
							   accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
							   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
							   height: 250),
				cells: [
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
			.section(
				separators: true,
				cells:
					countryModels.map { model in
						DynamicCell.euCell(cellModel: model)
					}
				)
		])
	}
}
