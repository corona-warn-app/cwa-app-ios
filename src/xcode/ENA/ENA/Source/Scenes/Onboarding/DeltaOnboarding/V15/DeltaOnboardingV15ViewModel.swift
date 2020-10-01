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
import UIKit

struct DeltaOnboardingV15ViewModel {
	
	// MARK: - Init

	init(
		supportedCountries: [Country]
	) {
		self.supportedCountries = supportedCountries.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_EUTracingOnboarding"),
						accessibilityLabel: AppStrings.DeltaOnboarding.accImageLabel,
						accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.accImageDescription,
						height: 250
					),
					cells: [
						.title2(
							text: AppStrings.DeltaOnboarding.title,
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.sectionTitle
						),
						.body(
							text: AppStrings.DeltaOnboarding.description,
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.description
						),
						.space(height: 16)
					]
				)
			)
			$0.add(
				.section(
					separators: .none,
					cells: buildCountryCells()
				)
			)
			$0.add(
				.section(
					separators: .inBetween,
					cells: supportedCountries.map {
						DynamicCell.icon($0.flag, text: $0.localizedName, iconWidth: 28) { _, cell, _ in
							cell.contentView.layoutMargins.left = 32
							cell.contentView.layoutMargins.right = 32
							cell.selectionStyle = .none
						}
					}
				)
			)
			$0.add(
				.section(
					cells: [
						.space(height: 20),
						
						.custom(
							withIdentifier: DeltaOnboardingV15ViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.DeltaOnboarding.legalDataProcessingInfoTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.DeltaOnboarding.legalDataProcessingInfoContent
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						)
					]
				)
			)
		}
	}

	// MARK: - Private

	private let supportedCountries: [Country]

	private func buildCountryCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		if supportedCountries.isEmpty {
			cells = [
				.headline(
					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailableTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailableTitle
				),
				.body(
					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailable,
						 accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailable
					 )
			]
		} else {
			cells.append(.headline(
				text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
						 accessibilityIdentifier: nil
					 ))
		}
		return cells
	}
}
