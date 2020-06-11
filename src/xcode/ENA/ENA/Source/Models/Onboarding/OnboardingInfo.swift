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

struct OnboardingInfo {
	var title: String
	var imageName: String
	var imageDescription: String
	var boldText: String
	var text: String
	var actionText: String
	var ignoreText: String
	var titleAccessibilityIdentifier: String?
	var imageAccessibilityIdentifier: String?
	var actionTextAccessibilityIdentifier: String?
	var ignoreTextAccessibilityIdentifier: String?
}

extension OnboardingInfo {
	static func testData() -> [Self] {
		let info1 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title,
			imageName: "Illu_Onboarding_GemeinsamCoronabekaempfen",
			imageDescription: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_imageDescription,
			boldText: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_normalText,
			actionText: AppStrings.Onboarding.onboardingLetsGo,
			ignoreText: "",
			titleAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title",
			imageAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_imageDescription",
			actionTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingLetsGo",
			ignoreTextAccessibilityIdentifier: nil
		)

		let info2 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_privacyPage_title,
			imageName: "Illu_Onboarding_Datenschutz",
			imageDescription: AppStrings.Onboarding.onboardingInfo_privacyPage_imageDescription,
			boldText: AppStrings.Onboarding.onboardingInfo_privacyPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_privacyPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: "",
			titleAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_privacyPage_title",
			imageAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_privacyPage_imageDescription",
			actionTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingContinue",
			ignoreTextAccessibilityIdentifier: nil
		)

		let info3 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_title,
			imageName: "Illu_Onboarding_Risikoerekennung",
			imageDescription: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_imageDescription,
			boldText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_normalText,
			actionText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button,
			ignoreText: AppStrings.Onboarding.onboardingDoNotActivate,
			titleAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_privacyPage_title",
			imageAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_privacyPage_imageDescription",
			actionTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button",
			ignoreTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingDoNotActivate"
		)

		let info4 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title,
			imageName: "Illu_Onboarding_Getestet",
			imageDescription: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_imageDescription,
			boldText: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: "",
			titleAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title",
			imageAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_imageDescription",
			actionTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingContinue",
			ignoreTextAccessibilityIdentifier: nil
		)

		let info5 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title,
			imageName: "Illu_Onboarding_Mitteilungen",
			imageDescription: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_imageDescription,
			boldText: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: AppStrings.Onboarding.onboardingDoNotAllow,
			titleAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title",
			imageAccessibilityIdentifier: "AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_imageDescription",
			actionTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingContinue",
			ignoreTextAccessibilityIdentifier: "AppStrings.Onboarding.onboardingDoNotAllow"
		)


		return [info1, info2, info3, info4, info5]
	}
}
