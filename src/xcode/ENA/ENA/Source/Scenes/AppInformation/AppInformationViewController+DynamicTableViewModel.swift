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

import Foundation
import UIKit

extension AppInformationViewController {

	static let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: Bundle.main.preferredLocalizations.first ?? "de")

	static let model: [Category: (AppInformationCellModel)] = [
		.about: AppInformationCellModel(
			text: AppStrings.AppInformation.aboutNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutNavigation,
			action: .push(model: AppInformationModel.aboutModel, withTitle:  AppStrings.AppInformation.aboutNavigation)
		),
		.faq: AppInformationCellModel(
			text: AppStrings.AppInformation.faqNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.faqNavigation,
			action: .safari
		),
		.terms: AppInformationCellModel(
			text: AppStrings.AppInformation.termsTitle,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.termsNavigation,
			action: .push(model: AppInformationModel.termsModel, withTitle:  AppStrings.AppInformation.termsNavigation)
		),
		.privacy: AppInformationCellModel(
			text: AppStrings.AppInformation.privacyNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.privacyNavigation,
			action: .push(model: AppInformationModel.privacyModel, withTitle:  AppStrings.AppInformation.privacyNavigation)
		),
		.legal: AppInformationCellModel(
			text: AppStrings.AppInformation.legalNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.legalNavigation,
			action: .push(model: legalModel, separators: true, withTitle:  AppStrings.AppInformation.legalNavigation)
		),
		.contact: AppInformationCellModel(
			text: AppStrings.AppInformation.contactNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactNavigation,
			action: .push(model: AppInformationModel.contactModel, withTitle:  AppStrings.AppInformation.contactNavigation)
		),
		.imprint: AppInformationCellModel(
			text: AppStrings.AppInformation.imprintNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
			action: .push(model: imprintViewModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
		)
	]

}
