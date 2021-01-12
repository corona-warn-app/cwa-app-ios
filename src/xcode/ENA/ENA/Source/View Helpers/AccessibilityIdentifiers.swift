//
// 🦠 Corona-Warn-App
//

enum AccessibilityIdentifiers {

	enum ExposureNotificationSetting {
		static let descriptionTitleInactive = "AppStrings.ExposureNotificationSetting.descriptionTitleInactive"
		static let descriptionTitle = "AppStrings.ExposureNotificationSetting.descriptionTitle"
		static let descriptionText1 = "AppStrings.ExposureNotificationSetting.descriptionText1"
		static let descriptionText2 = "AppStrings.ExposureNotificationSetting.descriptionText2"
		static let descriptionText3 = "AppStrings.ExposureNotificationSetting.descriptionText3"
		static let descriptionText4 = "AppStrings.ExposureNotificationSetting.descriptionText4"
		static let enableTracing = "AppStrings.ExposureNotificationSetting.enableTracing"
	}

	enum NotificationSettings {
		static let riskChanges = "AppStrings.NotificationSettings.riskChanges"
		static let testsStatus = "AppStrings.NotificationSettings.testsStatus"
		static let onTitle = "AppStrings.NotificationSettings.onTitle"
	}

	enum Home {
		static let submitCardButton = "AppStrings.Home.submitCardButton"
		static let diaryCardButton = "AppStrings.Home.diaryCardButton"
		static let activateCardOnTitle = "AppStrings.Home.activateCardOnTitle"
		static let activateCardOffTitle = "AppStrings.Home.activateCardOffTitle"
		static let activateCardBluetoothOffTitle = "AppStrings.Home.activateCardBluetoothOffTitle"
		static let riskCardIntervalUpdateTitle = "AppStrings.Home.riskCardIntervalUpdateTitle"
		static let resultCardShowResultButton = "AppStrings.Home.resultCardShowResultButton"
		static let leftBarButtonDescription = "AppStrings.Home.leftBarButtonDescription"
		static let rightBarButtonDescription = "AppStrings.Home.rightBarButtonDescription"
		static let infoCardShareTitle = "AppStrings.Home.infoCardShareTitle"
		static let infoCardAboutTitle = "AppStrings.Home.infoCardAboutTitle"
		static let appInformationCardTitle = "AppStrings.Home.appInformationCardTitle"
		static let settingsCardTitle = "AppStrings.Home.settingsCardTitle"
		static let thankYouCard = "AppStrings.Home.thankYouCard"

		enum RiskTableViewCell {
			static let topContainer = "[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer]"
			static let bodyLabel = "HomeRiskTableViewCell.bodyLabel"
			static let updateButton = "HomeRiskTableViewCell.updateButton"
		}
	}

	enum ContactDiaryInformation {
		static let imageDescription = "AppStrings.ContactDiaryInformation.imageDescription"
		static let descriptionTitle = "AppStrings.ContactDiaryInformation.descriptionTitle"
		static let descriptionSubHeadline = "AppStrings.ContactDiaryInformation.descriptionSubHeadline"
		static let dataPrivacyTitle = "AppStrings.ContactDiaryInformation.dataPrivacyTitle"
		static let legal_1 = "AppStrings.ContactDiaryInformation.legalHeadline_1"
	}

	enum Onboarding {
		static let onboardingInfo_togetherAgainstCoronaPage_title = "AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"
		static let onboardingInfo_togetherAgainstCoronaPage_imageDescription = "AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_imageDescription"
		static let onboardingLetsGo = "AppStrings.Onboarding.onboardingLetsGo"
		static let onboardingInfo_privacyPage_title = "AppStrings.Onboarding.onboardingInfo_privacyPage_title"
		static let onboardingInfo_privacyPage_imageDescription = "AppStrings.Onboarding.onboardingInfo_privacyPage_imageDescription"
		static let onboardingContinue = "AppStrings.Onboarding.onboardingContinue"
		static let onboardingInfo_enableLoggingOfContactsPage_button = "AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"
		static let onboardingDoNotActivate = "AppStrings.Onboarding.onboardingDoNotActivate"
		static let onboardingInfo_howDoesDataExchangeWorkPage_title = "AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_title"
		static let onboardingInfo_howDoesDataExchangeWorkPage_imageDescription = "AppStrings.Onboarding.onboardingInfo_howDoesDataExchangeWorkPage_imageDescription"
		static let onboardingInfo_alwaysStayInformedPage_title = "AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_title"
		static let onboardingInfo_alwaysStayInformedPage_imageDescription = "AppStrings.Onboarding.onboardingInfo_alwaysStayInformedPage_imageDescription"
		static let onboardingDoNotAllow = "AppStrings.Onboarding.onboardingDoNotAllow"
	}

	enum RiskLegend {
		static let subtitle = "AppStrings.RiskLegend.subtitle"
		static let titleImageAccLabel = "AppStrings.RiskLegend.titleImageAccLabel"
		static let legend1Text = "AppStrings.RiskLegend.legend1Text"
		static let legend2Text = "AppStrings.RiskLegend.legend2Text"
		static let legend2RiskLevels = "AppStrings.RiskLegend.legend2RiskLevels"
		static let legend2High = "AppStrings.RiskLegend.legend2High"
		static let legend2LowColor = "AppStrings.RiskLegend.legend2LowColor"
		static let legend3Text = "AppStrings.RiskLegend.legend3Text"
		static let definitionsTitle = "AppStrings.RiskLegend.definitionsTitle"
		static let storeTitle = "AppStrings.RiskLegend.storeTitle"
		static let storeText = "AppStrings.RiskLegend.storeText"
		static let checkTitle = "AppStrings.RiskLegend.checkTitle"
		static let checkText = "AppStrings.RiskLegend.checkText"
		static let contactTitle = "AppStrings.RiskLegend.contactTitle"
		static let contactText = "AppStrings.RiskLegend.contactText"
		static let notificationTitle = "AppStrings.RiskLegend.notificationTitle"
		static let notificationText = "AppStrings.RiskLegend.notificationText"
		static let randomTitle = "AppStrings.RiskLegend.randomTitle"
		static let randomText = "AppStrings.RiskLegend.randomText"
	}

	enum Settings {
		static let tracingLabel = "AppStrings.Settings.tracingLabel"
		static let notificationLabel = "AppStrings.Settings.notificationLabel"
		static let backgroundAppRefreshLabel = "AppStrings.Settings.backgroundAppRefreshLabel"
		static let resetLabel = "AppStrings.Settings.resetLabel"
		static let backgroundAppRefreshImageDescription = "AppStrings.Settings.backgroundAppRefreshImageDescription"
	}

	enum AppInformation {
		static let aboutNavigation = "AppStrings.AppInformation.aboutNavigation"
		static let faqNavigation = "AppStrings.AppInformation.faqNavigation"
		static let termsNavigation = "AppStrings.AppInformation.termsNavigation"
		static let privacyNavigation = "AppStrings.AppInformation.privacyNavigation"
		static let legalNavigation = "AppStrings.AppInformation.legalNavigation"
		static let contactNavigation = "AppStrings.AppInformation.contactNavigation"
		static let imprintNavigation = "AppStrings.AppInformation.imprintNavigation"
		static let aboutImageDescription = "AppStrings.AppInformation.aboutImageDescription"
		static let aboutTitle = "AppStrings.AppInformation.aboutTitle"
		static let aboutDescription = "AppStrings.AppInformation.aboutDescription"
		static let aboutText = "AppStrings.AppInformation.aboutText"
		static let aboutLink = "AppStrings.AppInformation.aboutLink"
		static let aboutLinkText = "AppStrings.AppInformation.aboutLinkText"
		static let contactImageDescription = "AppStrings.AppInformation.contactImageDescription"
		static let contactTitle = "AppStrings.AppInformation.contactTitle"
		static let contactDescription = "AppStrings.AppInformation.contactDescription"
		static let contactHotlineTitle = "AppStrings.AppInformation.contactHotlineTitle"
		static let contactHotlineText = "AppStrings.AppInformation.contactHotlineText"
		static let contactHotlineDescription = "AppStrings.AppInformation.contactHotlineDescription"
		static let contactHotlineTerms = "AppStrings.AppInformation.contactHotlineTerms"
		static let imprintImageDescription = "AppStrings.AppInformation.imprintImageDescription"
		static let imprintSection1Title = "AppStrings.AppInformation.imprintSection1Title"
		static let imprintSection1Text = "AppStrings.AppInformation.imprintSection1Text"
		static let imprintSection2Text = "AppStrings.AppInformation.imprintSection2Text"
		static let imprintSection3Title = "AppStrings.AppInformation.imprintSection3Title"
		static let imprintSection3Text = "AppStrings.AppInformation.imprintSection3Text"
		static let imprintSection4Title = "AppStrings.AppInformation.imprintSection4Title"
		static let imprintSection4Text = "AppStrings.AppInformation.imprintSection4Text"
		static let privacyImageDescription = "AppStrings.AppInformation.privacyImageDescription"
		static let privacyTitle = "AppStrings.AppInformation.privacyTitle"
		static let termsImageDescription = "AppStrings.AppInformation.termsImageDescription"
		static let termsTitle = "AppStrings.AppInformation.termsTitle"
		static let imprintSection2Title = "AppStrings.AppInformation.imprintSection2Title"
		static let legalImageDescription = "AppStrings.AppInformation.legalImageDescription"
	}

	enum ExposureDetection {
		static let explanationTextOff = "AppStrings.ExposureDetection.explanationTextOff"
		static let explanationTextOutdated = "AppStrings.ExposureDetection.explanationTextOutdated"
		static let explanationTextUnknown = "AppStrings.ExposureDetection.explanationTextUnknown"
		static let explanationTextLowNoEncounter = "AppStrings.ExposureDetection.explanationTextLowNoEncounter"
		static let explanationTextLowWithEncounter = "AppStrings.ExposureDetection.explanationTextLowWithEncounter"
		static let explanationTextHigh = "AppStrings.ExposureDetection.explanationTextHigh"

		static let activeTracingSectionText = "AppStrings.ExposureDetection.activeTracingSectionText"
		static let activeTracingSection = "AppStrings.ExposureDetection.activeTracingSection"
		static let lowRiskExposureSection = "AppStrings.ExposureDetection.lowRiskExposureSection"
		static let infectionRiskExplanationSection = "AppStrings.ExposureDetection.infectionRiskExplanationSection"
	}

	enum ExposureSubmissionQRScanner {
		static let flash = "AppStrings.ExposureSubmissionQRScanner.flash"
	}

	enum ExposureSubmissionQRInfo {
		static let headerSection1 = "AppStrings.ExposureSubmissionQRInfo.headerSection1"
		static let headerSection2 = "AppStrings.ExposureSubmissionQRInfo.headerSection2"
		static let acknowledgementTitle = "ExposureSubmissionQRInfo_acknowledgement_title"
		static let countryList = "ExposureSubmissionQRInfo_countryList"
		static let dataProcessingDetailInfo = "AppStrings.AutomaticSharingConsent.dataProcessingDetailInfo"
	}

	enum ExposureSubmissionDispatch {
		static let description = "AppStrings.ExposureSubmissionDispatch.description"
		static let sectionHeadline = "AppStrings.ExposureSubmission_DispatchSectionHeadline"
		static let sectionHeadline2 = "AppStrings.ExposureSubmission_DispatchSectionHeadline2"
		static let qrCodeButtonDescription = "AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"
		static let tanButtonDescription = "AppStrings.ExposureSubmissionDispatch.tanButtonDescription"
		static let hotlineButtonDescription = "AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"
	}

	enum ExposureSubmissionResult {
		static let procedure = "AppStrings.ExposureSubmissionResult.procedure"
		static let furtherInfos_Title = "AppStrings.ExposureSubmissionResult.furtherInfos_Title"
		static let warnOthersConsentGivenCell = "AppStrings.ExposureSubmissionResult.warnOthersConsentGiven"
		static let warnOthersConsentNotGivenCell = "AppStrings.ExposureSubmissionResult.warnOthersConsentNotGiven"
	}
	
	enum ExposureSubmissionPositiveTestResult {
		static let noConsentTitle = "TestResultPositive_NoConsent_Title"
		static let noConsentInfo1 = "TestResultPositive_NoConsent_Info1"
		static let noConsentInfo2 = "TestResultPositive_NoConsent_Info2"
		static let noConsentInfo3 = "TestResultPositive_NoConsent_Info3"
		static let noConsentPrimaryButtonTitle = "TestResultPositive_NoConsent_PrimaryButton"
		static let noConsentSecondaryButtonTitle = "TestResultPositive_NoConsent_SecondaryButton"
		static let noConsentAlertTitle = "TestResultPositive_NoConsent_AlertNotWarnOthers_Title"
		static let noConsentAlertDescription = "TestResultPositive_NoConsent_AlertNotWarnOthers_Description"
		static let noConsentAlertButton1 = "TestResultPositive_NoConsent_AlertNotWarnOthers_ButtonOne"
		static let noConsentAlertButton2 = "TestResultPositive_NoConsent_AlertNotWarnOthers_ButtonTwo"
		static let withConsentTitle = "TestResultPositive_WithConsent_Title"
		static let withConsentInfo1 = "TestResultPositive_WithConsent_Info1"
		static let withConsentInfo2 = "TestResultPositive_WithConsent_Info2"
		static let withConsentPrimaryButtonTitle = "TestResultPositive_WithConsent_PrimaryButton"
		static let withConsentSecondaryButtonTitle = "TestResultPositive_WithConsent_SecondaryButton"
	}

	enum ExposureSubmissionSuccess {
		static let accImageDescription = "AppStrings.ExposureSubmissionSuccess.accImageDescription"
		static let description = "AppStrings.ExposureSubmissionSuccess.description"
		static let listTitle = "AppStrings.ExposureSubmissionSuccess.listTitle"
		static let subTitle = "AppStrings.ExposureSubmissionSuccess.subTitle"
	}

	enum ExposureSubmissionHotline {
		static let imageDescription = "AppStrings.ExposureSubmissionHotline.imageDescription"
		static let description = "AppStrings.ExposureSubmissionHotline.description"
		static let sectionTitle = "AppStrings.ExposureSubmissionHotline.sectionTitle"
		static let primaryButton = "AppStrings.ExposureSubmissionHotline.callButtonTitle"
		static let secondaryButton = "AppStrings.ExposureSubmissionHotline.tanInputButtonTitle"

	}

	enum ExposureSubmissionIntroduction {
		static let subTitle = "AppStrings.ExposureSubmissionIntroduction.subTitle"
		static let usage01 = "AppStrings.ExposureSubmissionIntroduction.usage01"
		static let usage02 = "AppStrings.ExposureSubmissionIntroduction.usage02"
	}
	
	enum ExposureSubmissionSymptoms {
		static let description = "AppStrings.ExposureSubmissionSymptoms.description"
		static let introduction = "AppStrings.ExposureSubmissionSymptoms.introduction"
		static let answerOptionYes = "AppStrings.ExposureSubmissionSymptoms.answerOptionYes"
		static let answerOptionNo = "AppStrings.ExposureSubmissionSymptoms.answerOptionNo"
		static let answerOptionPreferNotToSay = "AppStrings.ExposureSubmissionSymptoms.answerOptionPreferNotToSay"
	}

	enum ExposureSubmissionSymptomsOnset {
		static let description = "AppStrings.ExposureSubmissionSymptomsOnset.description"
		static let answerOptionExactDate = "AppStrings.ExposureSubmissionSymptomsOnset.answerOptionExactDate"
		static let answerOptionLastSevenDays = "AppStrings.ExposureSubmissionSymptomsOnset.answerOptionLastSevenDays"
		static let answerOptionOneToTwoWeeksAgo = "AppStrings.ExposureSubmissionSymptomsOnset.answerOptionOneToTwoWeeksAgo"
		static let answerOptionMoreThanTwoWeeksAgo = "AppStrings.ExposureSubmissionSymptomsOnset.answerOptionMoreThanTwoWeeksAgo"
		static let answerOptionPreferNotToSay = "AppStrings.ExposureSubmissionSymptomsOnset.answerOptionPreferNotToSay"
	}

	enum ExposureSubmissionWarnOthers {
		static let accImageDescription = "AppStrings.ExposureSubmissionWarnOthers.accImageDescription"
		static let sectionTitle = "AppStrings.ExposureSubmissionWarnOthers.sectionTitle"
		static let description = "AppStrings.ExposureSubmissionWarnOthers.description"
	}
	
	enum DeltaOnboarding {
		static let accImageDescription = "AppStrings.DeltaOnboarding.accImageLabel"
		static let sectionTitle = "AppStrings.DeltaOnboarding.title"
		static let description = "AppStrings.DeltaOnboarding.description"
		static let downloadInfo = "AppStrings.DeltaOnboarding.downloadInfo"
		static let participatingCountriesListUnavailable = "AppStrings.DeltaOnboarding.participatingCountriesListUnavailable"
		static let participatingCountriesListUnavailableTitle = "AppStrings.DeltaOnboarding.participatingCountriesListUnavailableTitle"
		static let primaryButton = "AppStrings.DeltaOnboarding.primaryButton"
	}

	enum ExposureSubmissionWarnEuropeConsent {
		static let imageDescription = "AppStrings.ExposureSubmissionWarnEuropeConsent.imageDescription"
		static let sectionTitle = "AppStrings.ExposureSubmissionWarnEuropeConsent.sectionTitle"
		static let consentSwitch = "AppStrings.ExposureSubmissionWarnEuropeConsent.consentSwitch"
	}

	enum ExposureSubmissionWarnEuropeTravelConfirmation {
		static let description1 = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description1"
		static let description2 = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description2"
		static let optionYes = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionYes"
		static let optionNo = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionNo"
		static let optionNone = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.optionNone"
	}

	enum ExposureSubmissionWarnEuropeCountrySelection {
		static let description1 = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description1"
		static let description2 = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description2"
		static let answerOptionCountry = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionCountry"
		static let answerOptionOtherCountries = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionOtherCountries"
		static let answerOptionNone = "AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionNone"
	}

	enum ExposureSubmission {
		static let primaryButton = "AppStrings.ExposureSubmission.primaryButton"
		static let secondaryButton = "AppStrings.ExposureSubmission.secondaryButton"
	}

	enum Reset {
		static let imageDescription = "AppString.Reset.imageDescription"
	}

	enum AccessibilityLabel {
		static let close = "AppStrings.AccessibilityLabel.close"
	}

	enum InviteFriends {
		static let imageAccessLabel = "AppStrings.InviteFriends.imageAccessLabel"
	}

	enum General {
		static let exposureSubmissionNavigationControllerTitle = "ExposureSubmissionNavigationController"
		static let image = "ExposureSubmissionIntroViewController.image"

		static let primaryFooterButton = "General.primaryFooterButton"
		static let secondaryFooterButton = "General.secondaryFooterButton"
		static let cancelButton = "General.cancelButton"
		static let defaultButton = "General.defaultButton"
	}

	enum DatePickerOption {
		static let day = "AppStrings.DatePickerOption.day"
	}
	
	enum ThankYouScreen {
		static let accImageDescription = "AppStrings.ThankYouScreen.accImageDescription"
	}

}
