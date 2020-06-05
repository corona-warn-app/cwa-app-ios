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
			text: "App_Information_About_Navigation".localized,
			action: .push(model: aboutModel, withTitle:  "App_Information_About_Navigation".localized)
		),
		.faq: (
			text: "App_Information_FAQ_Navigation".localized,
			action: .safari
		),
		.terms: (
			text: "App_Information_Terms_Navigation".localized,
			action: .push(model: termsModel, withTitle:  "App_Information_Terms_Navigation".localized)
		),
		.privacy: (
			text: "App_Information_Privacy_Navigation".localized,
			action: .push(model: privacyModel, withTitle:  "App_Information_Privacy_Navigation".localized)
		),
		.legal: (
			text: "App_Information_Legal_Navigation".localized,
			action: .push(model: legalModel, separators: true, withTitle:  "App_Information_Legal_Navigation".localized)
		),
		.contact: (
			text: "App_Information_Contact_Navigation".localized,
			action: .push(model: contactModel, withTitle:  "App_Information_Contact_Navigation".localized)
		),
		.imprint: (
			text: "App_Information_Imprint_Navigation".localized,
			action: .push(model: imprintModel, withTitle:  "App_Information_Imprint_Navigation".localized)
		)
	]
}

extension AppInformationViewController {
	private static let aboutModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_AppInfo_UeberApp"), height: 230),
			cells: [
				.title2(text: "App_Information_About_Title".localized),
				.headline(text: "App_Information_About_Description".localized),
				.subheadline(text: "App_Information_About_Text".localized)
			]
		)
	])

	private static let contactModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Kontakt"), height: 230),
			cells: [
				.title2(text: "App_Information_Contact_Title".localized),
				.body(text: "App_Information_Contact_Description".localized),
				.headline(text: "App_Information_Contact_Hotline_Title".localized),
				.phone(text: "App_Information_Contact_Hotline_Text".localized, number: "App_Information_Contact_Hotline_Number".localized),
				.footnote(text: "App_Information_Contact_Hotline_Description".localized),
				.footnote(text: "App_Information_Contact_Hotline_Terms".localized)
			]
		)
	])

	private static let imprintModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Impressum"), height: 230),
			cells: [
				.headline(text: "App_Information_Imprint_Section1_Title".localized),
				.body(text: "App_Information_Imprint_Section1_Text".localized),
				.headline(text: "App_Information_Imprint_Section2_Title".localized),
				.body(text: "App_Information_Imprint_Section2_Text".localized),
				// .headline(text: "App_Information_Legal_Section3_Title".localized),
				.body(text: "App_Information_Imprint_Section3_Text".localized),
				.headline(text: "App_Information_Imprint_Section4_Title".localized),
				.body(text: "App_Information_Imprint_Section4_Text".localized)
			]
		)
	])

	private static let privacyModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Datenschutz"), height: 230),
			footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)),
			cells: [
				.title2(text: "App_Information_Privacy_Title".localized),
				.body(text: "App_Information_Privacy_Description".localized)
			]
		),
		.section(
			cells: [
				.subheadline(text: "App_Information_Privacy_Text".localized)
			]
		)
	])

	private static let termsModel = DynamicTableViewModel([
		.section(
			header: .image(UIImage(named: "Illu_Appinfo_Nutzungsbedingungen"), height: 230),
			cells: [
				.title2(text: "App_Information_Terms_Title".localized),
				.body(text: "App_Information_Terms_Description".localized),
				.body(text: "App_Information_Terms_Text".localized)
			]
		)
	])
}
