//
// 🦠 Corona-Warn-App
//

import Foundation

struct OnboardingInfo {
	var title: String
	var imageName: String
	var alternativeImageName: String?
	var imageDescription: String
	let showState: Bool
	var stateHeader: String?
	var stateTitle: String?
	var stateActivated: String?
	var stateDeactivated: String?
	var boldText: String
	var text: String
	var link: String
	var linkDisplayText: String
	var actionText: String
	var alternativeActionText: String
	var ignoreText: String
	var titleAccessibilityIdentifier: String?
	var imageAccessibilityIdentifier: String?
	var actionTextAccessibilityIdentifier: String?
	var ignoreTextAccessibilityIdentifier: String?
}

extension OnboardingInfo {
	static func testData(appConfigProvider: AppConfigurationProviding) -> [Self] {
		let info1 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title,
			imageName: "Illu_Onboarding_GemeinsamCoronabekaempfen",
			imageDescription: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_imageDescription,
			showState: false,
			boldText: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_boldText,
			text: String(
				format: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_normalText,
				appConfigProvider.currentAppConfig.value.riskCalculationParameters.defaultedMaxEncounterAgeInDays
			),
			link: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_link,
			linkDisplayText: AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_linkText,
			actionText: AppStrings.Onboarding.onboardingLetsGo,
			alternativeActionText: "",
			ignoreText: "",
			titleAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title,
			imageAccessibilityIdentifier:
			AccessibilityIdentifiers.Onboarding.onboardingInfo_togetherAgainstCoronaPage_imageDescription,
			actionTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingLetsGo,
			ignoreTextAccessibilityIdentifier: nil
		)

		let info2 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_privacyPage_title,
			imageName: "Illu_Onboarding_Datenschutz",
			imageDescription: AppStrings.Onboarding.onboardingInfo_privacyPage_imageDescription,
			showState: false,
			boldText: AppStrings.Onboarding.onboardingInfo_privacyPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_privacyPage_normalText,
			link: "",
			linkDisplayText: "",
			actionText: AppStrings.Onboarding.onboardingContinue,
			alternativeActionText: "",
			ignoreText: "",
			titleAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_privacyPage_title,
			imageAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_privacyPage_imageDescription,
			actionTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingContinue,
			ignoreTextAccessibilityIdentifier: nil
		)

		let info3 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_title,
			imageName: "Illu_Onboarding_Risikoerekennung",
			alternativeImageName: "Illu_Onboarding_Risikoerekennung_Off",
			imageDescription: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_imageDescription,
			showState: true,
			stateHeader: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_stateHeader,
			stateTitle: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_stateTitle,
			stateActivated: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_stateActivated,
			stateDeactivated: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_stateDeactivated,
			boldText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_normalText,
			link: "",
			linkDisplayText: "",
			actionText: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button,
			alternativeActionText: AppStrings.Onboarding.onboardingContinue,
			ignoreText: AppStrings.Onboarding.onboardingDoNotActivate,
			titleAccessibilityIdentifier:
			AccessibilityIdentifiers.Onboarding.onboardingInfo_privacyPage_title,
			imageAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_privacyPage_imageDescription,
			actionTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button,
			ignoreTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingDoNotActivate
		)

		let info4 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title,
			imageName: "Illu_Onboarding_Getestet",
			imageDescription: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_imageDescription,
			showState: false,
			boldText: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_normalText,
			link: "",
			linkDisplayText: "",
			actionText: AppStrings.Onboarding.onboardingContinue,
			alternativeActionText: "",
			ignoreText: "",
			titleAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title,
			imageAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_imageDescription,
			actionTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingContinue,
			ignoreTextAccessibilityIdentifier: nil
		)

		let info5 = OnboardingInfo(
			title: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title,
			imageName: "Illu_Onboarding_Mitteilungen",
			imageDescription: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_imageDescription,
			showState: false,
			boldText: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_boldText,
			text: AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_normalText,
			link: "",
			linkDisplayText: "",
			actionText: AppStrings.Onboarding.onboardingContinue,
			alternativeActionText: "",
			ignoreText: "",
			titleAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_alwaysStayInformedPage_title,
			imageAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingInfo_alwaysStayInformedPage_imageDescription,
			actionTextAccessibilityIdentifier: AccessibilityIdentifiers.Onboarding.onboardingContinue,
			ignoreTextAccessibilityIdentifier: nil
		)

		return [info1, info2, info3, info4, info5]
	}
}
