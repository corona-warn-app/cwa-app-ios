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

enum AppInformationModel {
	
	static let aboutModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_AppInfo_UeberApp"),
						   accessibilityLabel: AppStrings.AppInformation.aboutImageDescription,
						   accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.aboutTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutTitle),
				.headline(text: AppStrings.AppInformation.aboutDescription,
						  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutDescription),
				.subheadline(text: AppStrings.AppInformation.aboutText,
							 accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutText),
				.link(placeholder: isGerman() ? AppStrings.AppInformation.aboutLinkText : "", link: AppStrings.AppInformation.aboutLink, font: .subheadline, style: .subheadline, accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutLinkText)
			]
		)
	])

	static let contactModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Kontakt"),
						   accessibilityLabel: AppStrings.AppInformation.contactImageDescription,
						   accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.contactTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactTitle),
				.body(text: [AppStrings.AppInformation.contactDescription, AppStrings.Common.tessRelayDescription].joined(separator: "\n\n"),
					  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactDescription),
				.headline(text: AppStrings.AppInformation.contactHotlineTitle,
						  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineTitle),
				.phone(text: AppStrings.AppInformation.contactHotlineText, number: AppStrings.AppInformation.contactHotlineNumber,
					   accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineText),
				.footnote(text: AppStrings.AppInformation.contactHotlineDescription,
						  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineDescription),
				.footnote(text: AppStrings.AppInformation.contactHotlineTerms,
						  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineTerms)
			]
		)
	])

	static let privacyModel = DynamicTableViewModel([
		.section(
			header: .image(
				UIImage(named: "Illu_Appinfo_Datenschutz"),
				accessibilityLabel: AppStrings.AppInformation.privacyImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.privacyImageDescription,
				height: 230
			),
			cells: [
				.title2(
					text: AppStrings.AppInformation.privacyTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.privacyTitle),
				.html(url: Bundle.main.url(forResource: "privacy-policy", withExtension: "html"))
			]
		)
	])

	static let termsModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Nutzungsbedingungen"),
						   accessibilityLabel: AppStrings.AppInformation.termsImageDescription,
						   accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.termsImageDescription,
						   height: 230),
			cells: [
				.title2(
					text: AppStrings.AppInformation.termsTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.termsTitle),
				.html(url: Bundle.main.url(forResource: "usage", withExtension: "html"))
			]
		)
	])

}

private func isGerman() -> Bool {
	return Bundle.main.preferredLocalizations.first == "de"
}
