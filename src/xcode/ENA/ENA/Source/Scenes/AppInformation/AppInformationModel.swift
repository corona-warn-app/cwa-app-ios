//
// 🦠 Corona-Warn-App
//

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

	static let privacyModel = HtmlInfoModel(
		title: AppStrings.AppInformation.privacyTitle,
		titleAccessabliltyIdentfier: AccessibilityIdentifiers.AppInformation.privacyTitle,
		image: UIImage(named: "Illu_Appinfo_Datenschutz"),
		imageAccessabliltyIdentfier: AccessibilityIdentifiers.AppInformation.privacyImageDescription,
		imageAccessabliltyLabel: AppStrings.AppInformation.privacyImageDescription,
		urlResourceName: "privacy-policy"
	)

	static let termsModel = HtmlInfoModel(
		title: AppStrings.AppInformation.termsTitle,
		titleAccessabliltyIdentfier: AccessibilityIdentifiers.AppInformation.termsTitle,
		image: UIImage(named: "Illu_Appinfo_Nutzungsbedingungen"),
		imageAccessabliltyIdentfier: AccessibilityIdentifiers.AppInformation.termsImageDescription,
		imageAccessabliltyLabel: AppStrings.AppInformation.termsImageDescription,
		urlResourceName: "usage"
	)

	static let errorReportModel = DynamicTableViewModel([
		.section(cells: [
			.body(text: AppStrings.ErrorReport.description1),
			.link(text: AppStrings.ErrorReport.faq, url: URL(string: "https://example.com"), accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.faq),
			.headline(text: AppStrings.ErrorReport.description2)
		]),
		.section(
			separators: .all,
			cells: [
				.body(
					text: AppStrings.ErrorReport.privacyInformation,
					accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.privacyInformation,
					accessibilityTraits: .link,
					action: .none,
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
					})
			]),
		.section(cells: [
			.acknowledgement(
				title: NSAttributedString(string: "TODO LEGAL TITLE"),
				description: nil,
				bulletPoints: [
					NSMutableAttributedString(string: "TODO LEGAL BULLET 1"),
					NSMutableAttributedString(string: "TODO LEGAL BULLET 2"),
					NSMutableAttributedString(string: "TODO LEGAL BULLET 3"),
					NSMutableAttributedString(string: "TODO LEGAL BULLET 4"),
					NSMutableAttributedString(string: "TODO LEGAL BULLET 5")
				],
				accessibilityIdentifier: "TODO ACCESSABILITY IDENTIFIER")
		])
	])
}

private func isGerman() -> Bool {
	return Bundle.main.preferredLocalizations.first == "de"
}
