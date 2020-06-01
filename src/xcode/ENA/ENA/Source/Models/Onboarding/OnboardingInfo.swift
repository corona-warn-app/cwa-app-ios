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
	var boldText: String
	var text: String
	var actionText: String
	var ignoreText: String
}

extension OnboardingInfo {
	static func testData() -> [Self] {
		let info1 = OnboardingInfo(
			title:
			AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title,
			imageName: "onboarding_1",
			boldText: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_normalText,
			actionText: AppStrings.Onboarding.onboardingLetsGo,
			ignoreText: ""
		)

		let info2 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_privacyPage_title,
			imageName: "onboarding_2",
			boldText: AppStrings.Onboarding.onboardingInfo_privacyPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_privacyPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: ""
		)

		let info3 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_title,
			imageName: "onboarding_3",
			boldText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: AppStrings.Onboarding.onboardingDoNotActivate
		)

		let info4 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title,
			imageName: "onboarding_4",
			boldText: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: ""
		)

		let info5 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title,
			imageName: "onboarding_5",
			boldText: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_normalText,
			actionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: AppStrings.Onboarding.onboardingDoNotAllow
		)

		return [info1, info2, info3, info4, info5]
	}
}
