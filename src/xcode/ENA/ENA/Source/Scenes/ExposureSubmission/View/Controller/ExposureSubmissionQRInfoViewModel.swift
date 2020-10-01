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

import Foundation
import UIKit

struct ExposureSubmissionQRInfoViewModel {
	
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
						UIImage(named: "Illu_Submission_AndereWarnen"),
						accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250
					),
					cells: [
						.title2(
							text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle
						),
						.body(
							text: AppStrings.ExposureSubmissionWarnOthers.description,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description
						),
						.space(height: 16),
						.headline(
							text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
							accessibilityIdentifier: nil
						),
						.space(height: 12)
					]
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
							withIdentifier: ExposureSubmissionWarnOthersViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesText
									),
									textColor: .textContrast,
									bgColor: .riskNeutral
								)
							}
						),
						.custom(
							withIdentifier: ExposureSubmissionWarnOthersViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }

								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentDescription
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

}
