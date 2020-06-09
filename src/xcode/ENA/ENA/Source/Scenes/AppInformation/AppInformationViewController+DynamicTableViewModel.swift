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
	static func phone(text: String, number: String, accessibilityIdentifier: String?) -> Self {
		var cell: DynamicCell = .icon(UIImage(systemName: "phone"), text: text, tintColor: .enaColor(for: .textPrimary1), action: .call(number: number)) { _, cell, _ in
			cell.textLabel?.textColor = .enaColor(for: .textTint)
			(cell.textLabel as? ENALabel)?.style = .title2
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
		cell.tag = "phone"
		return cell
	}

	static func headlineWithoutBottomInset(text: String, accessibilityIdentifier: String?) -> Self {
		.headline(text: text, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.bottom = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	static func bodyWithoutTopInset(text: String, accessibilityIdentifier: String?) -> Self {
		.body(text: text, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.top = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	static func html(url: URL?) -> Self {
		.identifier(AppInformationDetailViewController.CellReuseIdentifier.html) { viewController, cell, _  in
			guard let cell = cell as? DynamicTableViewHtmlCell else { return }
			cell.textView.delegate = viewController as? UITextViewDelegate
			if let url = url {
				cell.textView.load(from: url)
			}
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
	static let model: [Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
		.about: (
			text: AppStrings.AppInformation.aboutNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.aboutNavigation",
			action: .push(model: aboutModel, withTitle:  AppStrings.AppInformation.aboutNavigation)
		),
		.faq: (
			text: AppStrings.AppInformation.faqNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.faqNavigation",
			action: .safari
		),
		.terms: (
			text: AppStrings.AppInformation.termsNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.termsNavigation",
			action: .push(model: termsModel, withTitle:  AppStrings.AppInformation.termsTitle)
		),
		.privacy: (
			text: AppStrings.AppInformation.privacyNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.privacyNavigation",
			action: .push(model: privacyModel, withTitle:  AppStrings.AppInformation.privacyNavigation)
		),
		.legal: (
			text: AppStrings.AppInformation.legalNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.legalNavigation",
			action: .push(model: legalModel, separators: true, withTitle:  AppStrings.AppInformation.legalNavigation)
		),
		.contact: (
			text: AppStrings.AppInformation.contactNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.contactNavigation",
			action: .push(model: contactModel, withTitle:  AppStrings.AppInformation.contactNavigation)
		),
		.imprint: (
			text: AppStrings.AppInformation.imprintNavigation,
			accessibilityIdentifier: "AppStrings.AppInformation.imprintNavigation",
			action: .push(model: imprintModel, withTitle:  AppStrings.AppInformation.imprintNavigation)
		)
	]
}

extension AppInformationViewController {
	private static let aboutModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_AppInfo_UeberApp"),
						   // TODO: get the accessibility content for this image
						   //accessibilityLabel: AppStrings.AppInformation.aboutImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.aboutTitle,
						accessibilityIdentifier: "AppStrings.AppInformation.aboutTitle"),
				.headline(text: AppStrings.AppInformation.aboutDescription,
						  accessibilityIdentifier: "AppStrings.AppInformation.aboutDescription"),
				.subheadline(text: AppStrings.AppInformation.aboutText,
							 accessibilityIdentifier: "AppStrings.AppInformation.aboutText")
			]
		)
	])

	private static let contactModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Kontakt"),
						   accessibilityLabel: AppStrings.AppInformation.contactImageDescription,
						   height: 230),
			cells: [
				.title2(text: AppStrings.AppInformation.contactTitle,
						accessibilityIdentifier: "AppStrings.AppInformation.contactTitle"),
				.body(text: AppStrings.AppInformation.contactDescription,
					  accessibilityIdentifier: "AppStrings.AppInformation.contactDescription"),
				.headline(text: AppStrings.AppInformation.contactHotlineTitle,
						  accessibilityIdentifier: "AppStrings.AppInformation.contactHotlineTitle"),
				.phone(text: AppStrings.AppInformation.contactHotlineText, number: AppStrings.AppInformation.contactHotlineNumber,
					   accessibilityIdentifier: "AppStrings.AppInformation.contactHotlineText"),
				.footnote(text: AppStrings.AppInformation.contactHotlineDescription,
						  accessibilityIdentifier: "AppStrings.AppInformation.contactHotlineDescription"),
				.footnote(text: AppStrings.AppInformation.contactHotlineTerms,
						  accessibilityIdentifier: "AppStrings.AppInformation.contactHotlineTerms")
			]
		)
	])

	private static let imprintModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Impressum"),
						   accessibilityLabel: AppStrings.AppInformation.imprintImageDescription,
						   height: 230),
			cells: [
				.headline(text: AppStrings.AppInformation.imprintSection1Title,
						  accessibilityIdentifier: "AppStrings.AppInformation.imprintSection1Title"),
				.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection1Text,
									 accessibilityIdentifier: "AppStrings.AppInformation.imprintSection1Text"),
				.headlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection2Title,
											accessibilityIdentifier: "AppStrings.AppInformation.imprintSection2Title"),
				.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection2Text,
									 accessibilityIdentifier: "AppStrings.AppInformation.imprintSection2Text"),
				.headlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection3Title,
											accessibilityIdentifier: "AppStrings.AppInformation.imprintSection3Title"),
				.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection3Text,
									 accessibilityIdentifier: "AppStrings.AppInformation.imprintSection3Text"),
				.headlineWithoutBottomInset(text: AppStrings.AppInformation.imprintSection4Title,
											accessibilityIdentifier: "AppStrings.AppInformation.imprintSection4Title"),
				.bodyWithoutTopInset(text: AppStrings.AppInformation.imprintSection4Text,
									 accessibilityIdentifier: "AppStrings.AppInformation.imprintSection4Text")
			]
		)
	])

	private static let privacyModel = DynamicTableViewModel([
		.section(
			header: .image(
				UIImage(named: "Illu_Appinfo_Datenschutz"),
				// TODO: get the accessibility content for this image
				//accessibilityLabel: AppStrings.AppInformation.privacyImageDescription,
				height: 230
			),
			cells: [
				.html(url: Bundle.main.url(forResource: "privacy-policy", withExtension: "html"))
			]
		)
	])

	private static let termsModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Nutzungsbedingungen"),
						   accessibilityLabel: AppStrings.AppInformation.termsImageDescription,
						   height: 230),
			cells: [
				.html(url: Bundle.main.url(forResource: "usage", withExtension: "html"))
			]
		)
	])
}
