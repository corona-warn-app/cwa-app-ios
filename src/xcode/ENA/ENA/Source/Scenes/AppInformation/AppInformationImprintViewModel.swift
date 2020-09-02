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

class AppInformationImprintViewModel {
	
	static let englishContactFormLink = "https://www.rki.de/SharedDocs/Kontaktformulare/en/Kontaktformulare/weitere/Corona-Warn-App/Corona-Warn-App_Integrator.html"
	static let germanContactFormLink = "https://www.rki.de/SharedDocs/Kontaktformulare/weitere/Corona-Warn-App/Corona-Warn-App_Integrator.html"
	
	
	static func contactForms() -> [DynamicCell] {
		let form: DynamicCell = .bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSectionContactFormLink, style: .linkTextView(AppStrings.AppInformation.imprintSectionContactFormTitle), accessibilityIdentifier: AppStrings.AppInformation.imprintSectionContactFormTitle)
		guard let localization = Bundle.main.preferredLocalizations.first else { return [form] }
		if localization == "en" || localization == "de" { return [form] }
		let englishTitle: String = AppStrings.AppInformation.imprintSectionContactFormTitle + " " + "(English)"
		let germanTitle: String = AppStrings.AppInformation.imprintSectionContactFormTitle + " " + "(German)"
		let englishForm: DynamicCell = .bodyWithoutTopInset(text: englishContactFormLink, style: .linkTextView(englishTitle), accessibilityIdentifier: englishTitle)
		let germanForm: DynamicCell = .bodyWithoutTopInset(text: germanContactFormLink, style: .linkTextView(germanTitle), accessibilityIdentifier: germanTitle)
		return [englishForm, germanForm]
	}
	
	
	static let dynamicTable: DynamicTableViewModel = {
		var cells: [DynamicCell] = [
			.headline(text: AppStrings.AppInformation.imprintSection1Title,
					  accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection1Title,
					  accessibilityTraits: .header),
			.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection1Text,
								 style: .textView([]),
								 accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection1Text),
			.imprintHeadlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection2Title,
										accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection2Title),
			.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection2Text,
								 style: .textView([]),
								 accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection2Text),
			.imprintHeadlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection3Title,
										accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection3Title),
			.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection3Text,
								 style: .textView(.all),
								 accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection3Text)]
		cells.append(contentsOf: AppInformationImprintViewModel.contactForms())
		cells.append(contentsOf: [
						.imprintHeadlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection4Title,
													accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection4Title),
						.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection4Text,
											 style: .textView([]),
											 accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintSection4Text)])
		let header: DynamicHeader = .image(UIImage(named: "Illu_Appinfo_Impressum"), accessibilityLabel: AppStrings.AppInformation.imprintImageDescription, accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintImageDescription, height: 230)
		return DynamicTableViewModel([.section(header: header, cells: cells)])
	}()
}
