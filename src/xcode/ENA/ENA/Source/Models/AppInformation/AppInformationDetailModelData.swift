//
//  AppInformationDetailModelData.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


extension AppInformationDetailModel {
	static let about = AppInformationDetailModel(
		headerImage: UIImage(named: "app-information-people"),
		content: [
			.headline(text: "App_Information_About_Title".localized),
			.body(text: "App_Information_About_Description".localized),
			.small(text: "App_Information_About_Text".localized)
		]
	)
	
	
	static let contact = AppInformationDetailModel(
		headerImage: UIImage(named: "app-information-notification"),
		content: [
			.headline(text: "App_Information_Contact_Title".localized),
			.body(text: "App_Information_Contact_Description".localized),
			.bold(text: "App_Information_Contact_Hotline_Title".localized),
			.phone(text: "App_Information_Contact_Hotline_Text".localized, number: "App_Information_Contact_Hotline_Number".localized),
			.small(text: "App_Information_Contact_Hotline_Description".localized),
			.tiny(text: "App_Information_Contact_Hotline_Terms".localized)
		]
	)
	
	
	static let legal = AppInformationDetailModel(
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.bold(text: "App_Information_Legal_Section1_Title".localized),
			.body(text: "App_Information_Legal_Section1_Text".localized),
			.bold(text: "App_Information_Legal_Section2_Title".localized),
			.body(text: "App_Information_Legal_Section2_Text".localized),
			//.bold(text: "App_Information_Legal_Section3_Title".localized),
			.body(text: "App_Information_Legal_Section3_Text".localized),
			.bold(text: "App_Information_Legal_Section4_Title".localized),
			.body(text: "App_Information_Legal_Section4_Text".localized)
		]
	)
	
	
	static let privacy = AppInformationDetailModel(
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.headline(text: "App_Information_Privacy_Title".localized),
			.body(text: "App_Information_Privacy_Description".localized),
			.seperator,
			.small(text: "App_Information_Privacy_Text".localized)
		]
	)
	
	
	static let terms = AppInformationDetailModel(
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.headline(text: "App_Information_Terms_Title".localized),
			.body(text: "App_Information_Terms_Description".localized),
			.body(text: "App_Information_Terms_Text".localized)
		]
	)
	
	
	static let helpTracing = AppInformationDetailModel(
		headerImage: nil,
		content: [
			.bold(text: "App_Information_Tracing_Title".localized),
			.body(text: "App_Information_Tracing_Text".localized)
		]
	)
}
