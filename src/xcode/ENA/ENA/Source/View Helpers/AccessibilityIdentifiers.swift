//
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

enum AccessibilityIdentifiers {

	enum ExposureNotificationSetting {
		static let descriptionTitleInactive = "AppStrings.ExposureNotificationSetting.descriptionTitleInactive"
		static let descriptionTitle = "AppStrings.ExposureNotificationSetting.descriptionTitle"
		static let descriptionText1 = "AppStrings.ExposureNotificationSetting.descriptionText1"
		static let descriptionText2 = "AppStrings.ExposureNotificationSetting.descriptionText2"
		static let descriptionText3 = "AppStrings.ExposureNotificationSetting.descriptionText3"
		static let enableTracing = "AppStrings.ExposureNotificationSetting.enableTracing"
	}

	enum NotificationSettings {
		static let riskChanges = "AppStrings.NotificationSettings.riskChanges"
		static let testsStatus = "AppStrings.NotificationSettings.testsStatus"
		static let onTitle = "AppStrings.NotificationSettings.onTitle"
	}

	enum RiskCollectionViewCell {
		static let topContainer =  "RiskLevelCollectionViewCell.topContainer"
		static let bodyLabel = "RiskLevelCollectionViewCell.bodyLabel"
		static let detectionIntervalLabel =  "RiskLevelCollectionViewCell.detectionIntervalLabel"
		static let updateButton = "RiskLevelCollectionViewCell.updateButton"
	}

	enum Home {
		static let submitCardButton = "AppStrings.Home.submitCardButton"
		static let activateCardOnTitle = "AppStrings.Home.activateCardOnTitle"
		static let activateCardOffTitle = "AppStrings.Home.activateCardOffTitle"
		static let activateCardBluetoothOffTitle = "AppStrings.Home.activateCardBluetoothOffTitle"
		static let activateCardInternetOffTitle = "AppStrings.Home.activateCardInternetOffTitle"
		static let riskCardIntervalUpdateTitle = "AppStrings.Home.riskCardIntervalUpdateTitle"
		static let resultCardShowResultButton = "AppStrings.Home.resultCardShowResultButton"
		static let leftBarButtonDescription = "AppStrings.Home.leftBarButtonDescription"
		static let rightBarButtonDescription = "AppStrings.Home.rightBarButtonDescription"
		static let infoCardShareTitle = "AppStrings.Home.infoCardShareTitle"
		static let infoCardAboutTitle = "AppStrings.Home.infoCardAboutTitle"
		static let appInformationCardTitle = "AppStrings.Home.appInformationCardTitle"
		static let settingsCardTitle = "AppStrings.Home.settingsCardTitle"

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
		static let legend2UnknownColor = "AppStrings.RiskLegend.legend2UnknownColor"
		static let legend3Text = "AppStrings.RiskLegend.legend3Text"
		static let definitionsTitle = "AppStrings.RiskLegend.definitionsTitle"
		static let storeTitle = "AppStrings.RiskLegend.storeTitle"
		static let storeText =  "AppStrings.RiskLegend.storeText"
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
		static let resetLabel = "AppStrings.Settings.resetLabel"
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
		static let explanationTextLow = "AppStrings.ExposureDetection.explanationTextLow"
		static let explanationTextHigh = "AppStrings.ExposureDetection.explanationTextHigh"
	}

	enum ExposureSubmissionDispatch {
		static let description = "AppStrings.ExposureSubmissionDispatch.description"
		static let qrCodeButtonDescription = "AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"
		static let tanButtonDescription = "AppStrings.ExposureSubmissionDispatch.tanButtonDescription"
		static let hotlineButtonDescription = "AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"
	}

	enum ExposureSubmissionResult {
		static let procedure = "AppStrings.ExposureSubmissionResult.procedure"
		static let furtherInfos_Title = "AppStrings.ExposureSubmissionResult.furtherInfos_Title"
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
	}

	enum ExposureSubmissionIntroduction {
		static let subTitle = "AppStrings.ExposureSubmissionIntroduction.subTitle"
		static let usage01 = "AppStrings.ExposureSubmissionIntroduction.usage01"
		static let usage02 = "AppStrings.ExposureSubmissionIntroduction.usage02"
	}

	enum ExposureSubmissionWarnOthers {
		static let accImageDescription = "AppStrings.ExposureSubmissionWarnOthers.accImageDescription"
		static let sectionTitle = "AppStrings.ExposureSubmissionWarnOthers.sectionTitle"
		static let description = "AppStrings.ExposureSubmissionWarnOthers.description"
	}

	enum ExposureSubmission {
		static let continueText = "AppStrings.ExposureSubmission.continueText"
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
	}

}
