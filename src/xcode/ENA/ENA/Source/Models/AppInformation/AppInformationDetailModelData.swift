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

extension AppInformationDetailModel {
	static let about = AppInformationDetailModel(
		title: "App_Information_About_Navigation".localized,
		headerImage: UIImage(named: "app-information-people"),
		content: [
			.headline(text: "App_Information_About_Title".localized),
			.body(text: "App_Information_About_Description".localized),
			.small(text: "App_Information_About_Text".localized)
		]
	)
	
	static let contact = AppInformationDetailModel(
		title: "App_Information_Contact_Navigation".localized,
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
		title: "App_Information_Legal_Navigation".localized,
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.bold(text: "App_Information_Legal_Section1_Title".localized),
			.body(text: "App_Information_Legal_Section1_Text".localized),
			.bold(text: "App_Information_Legal_Section2_Title".localized),
			.body(text: "App_Information_Legal_Section2_Text".localized),
			// .bold(text: "App_Information_Legal_Section3_Title".localized),
			.body(text: "App_Information_Legal_Section3_Text".localized),
			.bold(text: "App_Information_Legal_Section4_Title".localized),
			.body(text: "App_Information_Legal_Section4_Text".localized)
		]
	)
	
	static let privacy = AppInformationDetailModel(
		title: "App_Information_Privacy_Navigation".localized,
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.headline(text: "App_Information_Privacy_Title".localized),
			.body(text: "App_Information_Privacy_Description".localized),
			.seperator,
			.small(text: "App_Information_Privacy_Text".localized)
		]
	)
	
	static let terms = AppInformationDetailModel(
		title: "App_Information_Terms_Navigation".localized,
		headerImage: UIImage(named: "app-information-security"),
		content: [
			.headline(text: "App_Information_Terms_Title".localized),
			.body(text: "App_Information_Terms_Description".localized),
			.body(text: "App_Information_Terms_Text".localized)
		]
	)
	
	static let helpTracing = AppInformationDetailModel(
		title: "App_Information_Tracing_Navigation".localized,
		headerImage: nil,
		content: [
			.bold(text: "App_Information_Tracing_Title".localized),
			.body(text: "App_Information_Tracing_Text".localized)
		]
	)
}
