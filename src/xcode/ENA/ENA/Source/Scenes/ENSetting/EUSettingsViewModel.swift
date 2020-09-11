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

class EUSettingsViewModel {

	// MARK: - Model.

	class CountryModel {
		let country: Country
		@Published var isOn: Bool = false

		init(_ country: Country) {
			self.country = country
		}
	}

	// MARK: - Attributes.

	private var subscriptions = Set<AnyCancellable>()
	@Published var allCountriesOn: Bool = false
	let countryModels: [CountryModel]
	let errorChanges = PassthroughSubject<[Country], Never>()

	// MARK: - Initializers.

	init(countries: [Country]) {
		self.countryModels = countries.map { CountryModel($0) }
		self.countryModels.forEach {
			$0.$isOn
				.receive(on: RunLoop.main)
				.sink { _ in self.allCountriesOn = self.countryModels.allSatisfy { $0.isOn } }
				.store(in: &subscriptions)
		}
	}

	// MARK: - DynamicTableViewModel.

	func countrySwitchSection() -> DynamicSection {
		DynamicSection.section(
			separators: true,
			cells: countryModels.map { model in
				DynamicCell.euSwitchCell(cellModel: model) { isOn in
					model.isOn = isOn
					// Send the current country.
					if !isOn { self.errorChanges.send([model.country]) }
				}
			}
		)
	}

	func euSettingsModel() -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(cells: [
				.title1(
					text: AppStrings.ExposureNotificationSetting.euTitle,
					accessibilityIdentifier: ""
				),
				.headline(
					text: AppStrings.ExposureNotificationSetting.euDescription,
					accessibilityIdentifier: ""
				)
			]),
			.section(
				separators: true,
				cells: [
					DynamicCell.switchCell(
						text: AppStrings.ExposureNotificationSetting.euAllCountries,
						isOn: allCountriesOn,
						onSwitch: self.$allCountriesOn,
						onToggle: { isOn in
							self.countryModels.forEach { $0.isOn = isOn }
							if !isOn {
								// This switch modifies all countries.
								self.errorChanges.send(self.countryModels.map { $0.country })
							}
					 })
				]
			),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euDataTrafficDescription,
					color: .enaColor(for: .textPrimary2),
					accessibilityIdentifier: ""
				),
				.space(height: 16)
			]),
			countrySwitchSection(),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euRegionDescription,
					color: .enaColor(for: .textPrimary2),
					accessibilityIdentifier: ""
				),
				.stepCell(
					title: AppStrings.ExposureNotificationSetting.euGermanRiskTitle,
					description: AppStrings.ExposureNotificationSetting.euGermanRiskDescription,
					icon: Country(countryCode: "de")?.flag,
					hairline: .none
				),
				.custom(withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.roundedCell,
						configure: { _, cell, _ in
							guard let privacyStatementCell = cell as? DynamicTableViewRoundedCell else { return }
							privacyStatementCell.configure(
								title: NSMutableAttributedString(
									string: AppStrings.ExposureNotificationSetting.euPrivacyTitle
								),
								body: NSMutableAttributedString(
									string: AppStrings.ExposureNotificationSetting.euPrivacyDescription
								),
								textStyle: .textPrimary1,
								backgroundStyle: .separator
							)
					})
			])
		])
	}
}
