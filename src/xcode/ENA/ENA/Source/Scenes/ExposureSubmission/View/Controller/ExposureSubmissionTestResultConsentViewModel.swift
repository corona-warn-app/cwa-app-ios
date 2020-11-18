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

class ExposureSubmissionTestResultConsentViewModel {
	
	// MARK: - Properties
	
	private var exposureSubmissionService: ExposureSubmissionService
	
	// MARK: - Init
	
	init(exposureSubmissionService: ExposureSubmissionService) {
		self.exposureSubmissionService = exposureSubmissionService
	}
	
	@objc
	func stateChanged(switchState: UISwitch) {
		Log.info("Switch state was changed to: \(switchState.isOn)")
		exposureSubmissionService.isSubmissionConsentGiven = switchState.isOn
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					separators: .none,
					cells: [
						.headline(
							text: AppStrings.AutomaticSharingConsent.switchTitle,
							action: .push(model: AppInformationModel.termsModel, withTitle: AppStrings.AppInformation.termsNavigation),
							configure: { _, cell, _ in
								let consentSwitch = UISwitch()
								cell.accessoryView = consentSwitch
								consentSwitch.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
							}
						),
						.body(text: AppStrings.AutomaticSharingConsent.switchTitleDescription),
						.custom(
							withIdentifier: ExposureSubmissionTestResultConsentViewController.CustomCellReuseIdentifiers.consentCell,
							action: .none,
							accessoryAction: .none) { _, cell, _ in
								if let consentCell = cell as? DynamicTableViewConsentCell {
									consentCell.configure(
										subTitleLabel: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentSubTitle),
										descriptionPart1Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart1),
										descriptionPart2Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart2),
										flagIconsLabel: NSMutableAttributedString(string: "Display Country Flag Icons"),
										flagCountriesLabel: NSMutableAttributedString(string: "Display Country Flag Names"),
										descriptionPart3Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart3),
										descriptionPart4Label: NSMutableAttributedString(string: AppStrings.AutomaticSharingConsent.consentDescriptionPart4)
									)
								}
							}
					]
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: [
						.icon(
							nil,
							text: .string(AppStrings.AutomaticSharingConsent.dataProcessingDetailInfo),
							action: .push(model: AppInformationModel.termsModel, withTitle: AppStrings.AppInformation.termsNavigation),
							configure: { _, cell, _ in
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
							}
						)
					]
				)

			)
		}
	}
}
