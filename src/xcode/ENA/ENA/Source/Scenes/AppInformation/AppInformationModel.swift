//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum AppInformationModel {
	
	static let aboutModel = DynamicTableViewModel([
		.section(
			header: .image(
				UIImage(named: "Illu_AppInfo_UeberApp"),
				accessibilityLabel: AppStrings.AppInformation.aboutImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutImageDescription,
				height: 230
			),
			cells: [
				.title2(
					text: AppStrings.AppInformation.aboutTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutTitle
				),
				.headline(
					text: AppStrings.AppInformation.aboutDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutDescription
				),
				.subheadline(
					text: AppStrings.AppInformation.aboutText,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutText
				),
				.link(placeholder: AppStrings.AppInformation.aboutLinkText, link: AppStrings.AppInformation.aboutLink, font: .subheadline, style: .subheadline, accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutLinkText)
			]
		)
	])

	static let contactModel = DynamicTableViewModel([
		.section(
			header: .image(
				UIImage(named: "Illu_Appinfo_Kontakt"),
				accessibilityLabel: AppStrings.AppInformation.contactImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactImageDescription,
				height: 230
			),
			cells: [
				.title2(
					text: AppStrings.AppInformation.contactTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactTitle
				),
				.body(
					text: [AppStrings.AppInformation.contactDescription, AppStrings.Common.tessRelayDescription].joined(separator: "\n\n"),
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactDescription
				),
				.headline(
					text: AppStrings.AppInformation.contactHotlineTitle,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineTitle
				),
				.phone(
					text: AppStrings.AppInformation.contactHotlineDomesticText,
					number: AppStrings.AppInformation.contactHotlineDomesticNumber,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineDomesticText
				),
				.footnote(
					text: AppStrings.AppInformation.contactHotlineDomesticDetails,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineDomesticDetails
				),
				.phone(
					text: AppStrings.AppInformation.contactHotlineForeignText,
					number: AppStrings.AppInformation.contactHotlineForeignNumber,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineForeignText,
					foreign: true
				),
				.footnote(
					text: AppStrings.AppInformation.contactHotlineForeignDetails,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineForeignDetails
				),
				.footnote(
					text: AppStrings.AppInformation.contactHotlineTerms,
					accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactHotlineTerms
				)
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
}
