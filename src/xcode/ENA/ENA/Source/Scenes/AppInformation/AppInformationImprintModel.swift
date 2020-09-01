//
//  AppInformationImprintModel.swift
//  ENA
//
//  Created by Vogel, Andreas on 01.09.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

class appInformationImprintModel {
	
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
		cells.append(contentsOf: appInformationImprintModel.contactForms())
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
