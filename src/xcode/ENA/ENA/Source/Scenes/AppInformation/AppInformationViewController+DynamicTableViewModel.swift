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

private extension DynamicCell {
	static func phone(text: String, number: String) -> Self {
		.icon(UIImage(systemName: "phone"), text: text, tintColor: .enaColor(for: .textPrimary1), action: .call(number: number)) { _, cell, _ in
			cell.textLabel?.textColor = .enaColor(for: .textTint)
			(cell.textLabel as? ENALabel)?.style = .title2
		}
	}
}

private extension DynamicAction {
	static var safari: Self {
		.execute { viewController in
			WebPageHelper.showWebPage(from: viewController)
		}
	}

	static func push(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String) -> Self {
		.execute { viewController in
			let detailViewController = AppInformationDetailViewController()
			detailViewController.title = title
			detailViewController.dynamicTableViewModel = model
			detailViewController.separatorStyle = separators ? .singleLine : .none
			viewController.navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
}

extension AppInformationViewController {
	static let model: [Category: (text: String, action: DynamicAction)] = [
		.about: (
			text: AppStrings.AppInformation.aboutNavigation,
			action: .push(model: aboutModel, withTitle:  AppStrings.AppInformation.aboutNavigation)
		),
		.faq: (
			text: AppStrings.AppInformation.faqNavigation,
			action: .safari
		),
		.terms: (
			text: AppStrings.AppInformation.termsNavigation,
			action: .push(model: termsModel, withTitle:  AppStrings.AppInformation.termsNavigation)
		),
		.privacy: (
			text: AppStrings.AppInformation.privacyNavigation,
			action: .push(model: privacyModel, withTitle:  AppStrings.AppInformation.privacyNavigation)
		),
		.legal: (
			text: AppStrings.AppInformation.legalNavigation,
			action: .push(model: legalModel, separators: true, withTitle:  AppStrings.AppInformation.legalNavigation)
		),
		.contact: (
			text: AppStrings.AppInformation.contactNavigation,
			action: .push(model: contactModel, withTitle:  AppStrings.AppInformation.contactNavigation)
		),
		.imprint: (
			text: AppStrings.AppInformation.imprintNavigation,
			action: .push(model: imprintModel, withTitle:  AppStrings.AppInformation.imprintNavigation)
		)
	]
}

extension AppInformationViewController {
	private static let aboutModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_AppInfo_UeberApp"),
						   //accessibilityLabel: AppStrings.AppInformation.aboutImageDescription,
						   height: 230),
			cells: [
				.title2(text:  AppStrings.AppInformation.aboutTitle),
				.headline(text: AppStrings.AppInformation.aboutDescription),
				.subheadline(text: AppStrings.AppInformation.aboutText)
			]
		)
	])

	private static let contactModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Kontakt"),
						   accessibilityLabel: AppStrings.AppInformation.contactImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.contactTitle),
				.body(text: AppStrings.AppInformation.contactDescription),
				.headline(text: AppStrings.AppInformation.contactHotlineTitle),
				.phone(text: AppStrings.AppInformation.contactHotlineText, number: AppStrings.AppInformation.contactHotlineNumber),
				.footnote(text: AppStrings.AppInformation.contactHotlineDescription),
				.footnote(text: AppStrings.AppInformation.contactHotlineTerms)
			]
		)
	])

	private static let imprintModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Impressum"),
						   accessibilityLabel: AppStrings.AppInformation.imprintImageDescription,
						   height: 230),
			cells: [
				.headline(text: AppStrings.AppInformation.imprintSection1Title),
				.body(text: AppStrings.AppInformation.imprintSection1Text),
				.headline(text: AppStrings.AppInformation.imprintSection2Title),
				.body(text: AppStrings.AppInformation.imprintSection2Text),
				// .headline(text: AppStrings.AppInformation.legalSection3Title),
				.body(text: AppStrings.AppInformation.imprintSection3Text),
				.headline(text: AppStrings.AppInformation.imprintSection4Title),
				.body(text: AppStrings.AppInformation.imprintSection4Text)
			]
		)
	])

	private static let privacyModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Datenschutz"),
						   //accessibilityLabel: AppStrings.AppInformation.privacyImageDescription,
						   height: 230),
			footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)),
			cells: [
				.title2(text: AppStrings.AppInformation.privacyTitle),
				.body(text: AppStrings.AppInformation.privacyDescription)
			]
		),
		.section(
			cells: [
				.subheadline(text: AppStrings.AppInformation.privacyText)
			]
		)
	])

	private static let termsModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Nutzungsbedingungen"),
						   accessibilityLabel: AppStrings.AppInformation.termsImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.termsTitle),
				.body(text: AppStrings.AppInformation.termsDescription),
				.body(text: AppStrings.AppInformation.termsText)
			]
		)
	])
}
