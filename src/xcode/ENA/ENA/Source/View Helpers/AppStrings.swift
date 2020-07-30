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

import UIKit

// swiftlint:disable:next type_body_length
enum AppStrings {
	enum Common {
		static let alertTitleGeneral = NSLocalizedString("Alert_TitleGeneral", comment: "")
		static let alertActionOk = NSLocalizedString("Alert_ActionOk", comment: "")
		static let alertActionRetry = NSLocalizedString("Alert_ActionRetry", comment: "")
		static let alertActionCancel = NSLocalizedString("Alert_ActionCancel", comment: "")
		static let alertActionRemove = NSLocalizedString("Alert_ActionRemove", comment: "")

		static let alertTitleBluetoothOff = NSLocalizedString("Alert_BluetoothOff_Title", comment: "")
		static let alertDescriptionBluetoothOff = NSLocalizedString("Alert_BluetoothOff_Description", comment: "")
		static let alertActionLater = NSLocalizedString("Alert_CancelAction_Later", comment: "")
		static let alertActionOpenSettings = NSLocalizedString("Alert_DefaultAction_OpenSettings", comment: "")
		static let general_BackButtonTitle = NSLocalizedString("General_BackButtonTitle", comment: "")

		static let errorAlertActionMoreInfo = NSLocalizedString("Common_Alert_Action_moreInfo", comment: "")
		static let enError5Description = NSLocalizedString("Common_ENError5_Description", comment: "")
		static let enError11Description = NSLocalizedString("Common_ENError11_Description", comment: "")
		static let enError13Description = NSLocalizedString("Common_ENError13_Description", comment: "")
		static let backgroundFetch_AlertMessage = NSLocalizedString("Common_BackgroundFetch_AlertMessage", comment: "")
		static let backgroundFetch_OKTitle = NSLocalizedString("Common_BackgroundFetch_OKTitle", comment: "")
		static let backgroundFetch_SettingsTitle = NSLocalizedString("Common_BackgroundFetch_SettingsTitle", comment: "")
		static let backgroundFetch_AlertTitle = NSLocalizedString("Common_BackgroundFetch_AlertTitle", comment: "")
	}

	enum Links {
		static let appFaq = NSLocalizedString("General_moreInfo_URL", comment: "")
		static let appFaqENError5 = NSLocalizedString("General_moreInfo_URL_EN5", comment: "")
		static let appFaqENError11 = NSLocalizedString("General_moreInfo_URL_EN11", comment: "")
		static let appFaqENError13 = NSLocalizedString("General_moreInfo_URL_EN13", comment: "")
	}

	enum AccessibilityLabel {
		static let close = NSLocalizedString("AccessibilityLabel_Close", comment: "")
		static let phoneNumber = NSLocalizedString("AccessibilityLabel_PhoneNumber", comment: "")
	}
	
	enum ExposureSubmission {
		static let generalErrorTitle = NSLocalizedString("ExposureSubmission_GeneralErrorTitle", comment: "")
		static let dataPrivacyTitle = NSLocalizedString("ExposureSubmission_DataPrivacyTitle", comment: "")
		static let dataPrivacyDisclaimer = NSLocalizedString("ExposureSubmission_DataPrivacyDescription", comment: "")
		static let dataPrivacyAcceptTitle = NSLocalizedString("ExposureSubmissionDataPrivacy_AcceptTitle", comment: "")
		static let dataPrivacyDontAcceptTitle = NSLocalizedString("ExposureSubmissionDataPrivacy_DontAcceptTitle", comment: "")
		static let continueText = NSLocalizedString("ExposureSubmission_Continue_actionText", comment: "")

		static let hotlineNumber = NSLocalizedString("ExposureSubmission_Hotline_Number", comment: "")
	}
	
	enum ExposureSubmissionTanEntry {
		static let title = NSLocalizedString("ExposureSubmissionTanEntry_Title", comment: "")
		static let textField = NSLocalizedString("ExposureSubmissionTanEntry_EntryField", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionTanEntry_Description", comment: "")
		static let info = NSLocalizedString("ExposureSubmissionTanEntry_Info", comment: "")
		static let submit = NSLocalizedString("ExposureSubmissionTanEntry_Submit", comment: "")
		static let invalidCharacterError = NSLocalizedString("ExposureSubmissionTanEntry_InvalidCharacterError", comment: "")
		static let invalidError = NSLocalizedString("ExposureSubmissionTanEntry_InvalidError", comment: "")
	}

	enum ExposureSubmissionIntroduction {
		static let title = NSLocalizedString("ExposureSubmissionIntroduction_Title", comment: "")
		static let subTitle = NSLocalizedString("ExposureSubmissionIntroduction_SubTitle", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionIntroduction_AccImageDescription", comment: "")
		static let usage01 = NSLocalizedString("ExposureSubmissionIntroduction_Usage01", comment: "")
		static let usage02 = NSLocalizedString("ExposureSubmissionIntroduction_Usage02", comment: "")
		static let listItem1 = NSLocalizedString("ExposureSubmissionIntroduction_ListItem1", comment: "")
		static let listItem2 = NSLocalizedString("ExposureSubmissionIntroduction_ListItem2", comment: "")
		static let listItem3 = NSLocalizedString("ExposureSubmissionIntroduction_ListItem3", comment: "")
		static let listItem4 = NSLocalizedString("ExposureSubmissionIntroduction_ListItem4", comment: "")
	}

	enum ExposureSubmissionResult {
		static let title = NSLocalizedString("ExposureSubmissionResult_Title", comment: "")
		static let card_title = NSLocalizedString("ExposureSubmissionResult_CardTitle", comment: "")
		static let card_subtitle = NSLocalizedString("ExposureSubmissionResult_CardSubTitle", comment: "")
		static let card_positive = NSLocalizedString("ExposureSubmissionResult_CardPositive", comment: "")
		static let card_negative = NSLocalizedString("ExposureSubmissionResult_CardNegative", comment: "")
		static let card_invalid = NSLocalizedString("ExposureSubmissionResult_CardInvalid", comment: "")
		static let card_pending = NSLocalizedString("ExposureSubmissionResult_CardPending", comment: "")
		static let procedure = NSLocalizedString("ExposureSubmissionResult_Procedure", comment: "")
		static let testAdded = NSLocalizedString("ExposureSubmissionResult_testAdded", comment: "")
		static let warnOthers = NSLocalizedString("ExposureSubmissionResult_warnOthers", comment: "")
		static let testPositive = NSLocalizedString("ExposureSubmissionResult_testPositive", comment: "")
		static let testAddedDesc = NSLocalizedString("ExposureSubmissionResult_testAddedDesc", comment: "")
		static let testPositiveDesc = NSLocalizedString("ExposureSubmissionResult_testPositiveDesc", comment: "")
		static let testNegative = NSLocalizedString("ExposureSubmissionResult_testNegative", comment: "")
		static let testNegativeDesc = NSLocalizedString("ExposureSubmissionResult_testNegativeDesc", comment: "")
		static let testInvalid = NSLocalizedString("ExposureSubmissionResult_testInvalid", comment: "")
		static let testInvalidDesc = NSLocalizedString("ExposureSubmissionResult_testInvalidDesc", comment: "")
		static let testPending = NSLocalizedString("ExposureSubmissionResult_testPending", comment: "")
		static let testPendingDesc = NSLocalizedString("ExposureSubmissionResult_testPendingDesc", comment: "")
		static let testRemove = NSLocalizedString("ExposureSubmissionResult_testRemove", comment: "")
		static let testRemoveDesc = NSLocalizedString("ExposureSubmissionResult_testRemoveDesc", comment: "")
		static let warnOthersDesc = NSLocalizedString("ExposureSubmissionResult_warnOthersDesc", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionResult_continueButton", comment: "")
		static let deleteButton = NSLocalizedString("ExposureSubmissionResult_deleteButton", comment: "")
		static let refreshButton = NSLocalizedString("ExposureSubmissionResult_refreshButton", comment: "")
		static let furtherInfos_Title = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_title", comment: "")
		static let furtherInfos_ListItem1 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem1", comment: "")
		static let furtherInfos_ListItem2 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem2", comment: "")
		static let furtherInfos_ListItem3 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem3", comment: "")
		static let furtherInfos_TestAgain = NSLocalizedString("ExposureSubmissionResult_furtherInfos_hint_testAgain", comment: "")
		static let removeAlert_Title = NSLocalizedString("ExposureSubmissionResult_RemoveAlert_Title", comment: "")
		static let removeAlert_Text = NSLocalizedString("ExposureSubmissionResult_RemoveAlert_Text", comment: "")
		static let registrationDateUnknown = NSLocalizedString("ExposureSubmissionResult_RegistrationDateUnknown", comment: "")
		static let registrationDate = NSLocalizedString("ExposureSubmissionResult_RegistrationDate", comment: "")
	}

	enum ExposureSubmissionDispatch {
		static let title = NSLocalizedString("ExposureSubmission_DispatchTitle", comment: "")
		static let description = NSLocalizedString("ExposureSubmission_DispatchDescription", comment: "")
		static let qrCodeButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_QRCodeButtonTitle", comment: "")
		static let qrCodeButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_QRCodeButtonDescription", comment: "")
		static let tanButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_TANButtonTitle", comment: "")
		static let tanButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_TANButtonDescription", comment: "")
		static let hotlineButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_HotlineButtonTitle", comment: "")
		static let hotlineButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_HotlineButtonDescription", comment: "")
		static let positiveWord = NSLocalizedString("ExposureSubmissionDispatch_HotlineButtonPositiveWord", comment: "")
	}

	enum ExposureSubmissionQRScanner {
		static let title = NSLocalizedString("ExposureSubmissionQRScanner_title", comment: "")
		static let instruction = NSLocalizedString("ExposureSubmissionQRScanner_instruction", comment: "")
		static let alertCodeNotFoundTitle = NSLocalizedString("ExposureSubmissionQRScanner_notFoundAlertTitle", comment: "")
		static let alertCodeNotFoundText = NSLocalizedString("ExposureSubmissionQRScanner_notFoundAlertText", comment: "")
		static let otherError = NSLocalizedString("ExposureSubmissionQRScanner_otherError", comment: "")
		static let cameraPermissionDenied = NSLocalizedString("ExposureSubmissionQRScanner_cameraPermissionDenied", comment: "")
		static let flashButtonAccessibilityLabel = NSLocalizedString("ExposureSubmissionQRScanner_CameraFlash", comment: "")
		static let flashButtonAccessibilityOnValue = NSLocalizedString("ExposureSubmissionQRScanner_CameraFlash_On", comment: "")
		static let flashButtonAccessibilityOffValue = NSLocalizedString("ExposureSubmissionQRScanner_CameraFlash_Off", comment: "")
		static let flashButtonAccessibilityEnableAction = NSLocalizedString("ExposureSubmissionQRScanner_CameraFlash_Enable", comment: "")
		static let flashButtonAccessibilityDisableAction = NSLocalizedString("ExposureSubmissionQRScanner_CameraFlash_Disable", comment: "")
	}

	enum ExposureSubmissionHotline {
		static let title = NSLocalizedString("ExposureSubmissionHotline_Title", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionHotline_Description", comment: "")
		static let sectionTitle = NSLocalizedString("ExposureSubmissionHotline_SectionTitle", comment: "")
		static let sectionDescription1 = NSLocalizedString("ExposureSubmissionHotline_SectionDescription1", comment: "")
		static let iconAccessibilityLabel1 = NSLocalizedString("ExposureSubmissionHotline_iconAccessibilityLabel1", comment: "")
		static let iconAccessibilityLabel2 = NSLocalizedString("ExposureSubmissionHotline_iconAccessibilityLabel2", comment: "")
		static let sectionDescription2 = NSLocalizedString("ExposureSubmission_SectionDescription2", comment: "")
		static let callButtonTitle = NSLocalizedString("ExposureSubmission_CallButtonTitle", comment: "")
		static let tanInputButtonTitle = NSLocalizedString("ExposureSubmission_TANInputButtonTitle", comment: "")
		static let phoneNumber = NSLocalizedString("ExposureSubmission_PhoneNumber", comment: "")
		static let hotlineDetailDescription = NSLocalizedString("ExposureSubmission_PhoneDetailDescription", comment: "")
		static let imageDescription = NSLocalizedString("ExposureSubmissionHotline_imageDescription", comment: "")
	}

	enum ExposureSubmissionWarnOthers {
		static let title = NSLocalizedString("ExposureSubmissionWarnOthers_title", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionWarnOthers_AccImageDescription", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionWarnOthers_continueButton", comment: "")
		static let sectionTitle = NSLocalizedString("ExposureSubmissionWarnOthers_sectionTitle", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionWarnOthers_description", comment: "")
		static let dataPrivacyDescription = NSLocalizedString("ExposureSubmissionWarnOthers_dataPrivacyDescription", comment: "")
		static let dataPrivacyTitle = NSLocalizedString("ExposureSubmissionWarnOthers_dataPrivacyTitle", comment: "")
	}

	enum ExposureSubmissionSuccess {
		static let title = NSLocalizedString("ExposureSubmissionSuccess_Title", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionSuccess_AccImageDescription", comment: "")
		static let button = NSLocalizedString("ExposureSubmissionSuccess_Button", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionSuccess_Description", comment: "")
		static let listTitle = NSLocalizedString("ExposureSubmissionSuccess_listTitle", comment: "")
		static let listItem1 = NSLocalizedString("ExposureSubmissionSuccess_listItem1", comment: "")
		static let listItem2 = NSLocalizedString("ExposureSubmissionSuccess_listItem2", comment: "")
		static let subTitle = NSLocalizedString("ExposureSubmissionSuccess_subTitle", comment: "")
		static let listItem2_1 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_1", comment: "")
		static let listItem2_2 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_2", comment: "")
		static let listItem2_3 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_3", comment: "")
		static let listItem2_4 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_4", comment: "")
	}

	enum ExposureSubmissionError {
		static let noKeys = NSLocalizedString("ExposureSubmissionError_NoKeys", comment: "")
		static let invalidTan = NSLocalizedString("ExposureSubmissionError_InvalidTan", comment: "")
		static let enNotEnabled = NSLocalizedString("ExposureSubmissionError_EnNotEnabled", comment: "")
		static let noRegistrationToken = NSLocalizedString("ExposureSubmissionError_NoRegistrationToken", comment: "")
		static let invalidResponse = NSLocalizedString("ExposureSubmissionError_InvalidResponse", comment: "")
		static let noResponse = NSLocalizedString("ExposureSubmissionError_NoResponse", comment: "")
		static let teleTanAlreadyUsed = NSLocalizedString("ExposureSubmissionError_TeleTanAlreadyUsed", comment: "")
		static let qrAlreadyUsed = NSLocalizedString("ExposureSubmissionError_QRAlreadyUsed", comment: "")
		static let regTokenNotExist = NSLocalizedString("ExposureSubmissionError_RegTokenNotExist", comment: "")
		static let other = NSLocalizedString("ExposureSubmissionError_other", comment: "")
		static let otherend = NSLocalizedString("ExposureSubmissionError_otherend", comment: "")
		static let httpError = NSLocalizedString("ExposureSubmissionError_httpError", comment: "")
		static let notAuthorized = NSLocalizedString("ExposureSubmissionError_declined", comment: "")
		static let unknown = NSLocalizedString("ExposureSubmissionError_unknown", comment: "")
		static let defaultError = NSLocalizedString("ExposureSubmissionError_defaultError", comment: "")
		static let noConfiguration = NSLocalizedString("No Exposure Configuration available", comment: "")
	}

	enum ExposureDetection {
		static let off = NSLocalizedString("ExposureDetection_Off", comment: "")
		static let outdated = NSLocalizedString("ExposureDetection_Outdated", comment: "")
		static let unknown = NSLocalizedString("ExposureDetection_Unknown", comment: "")
		static let low = NSLocalizedString("ExposureDetection_Low", comment: "")
		static let high = NSLocalizedString("ExposureDetection_High", comment: "")

		static let numberOfContacts = NSLocalizedString("ExposureDetection_NumberOfContacts", comment: "")
		static let lastExposure = NSLocalizedString("ExposureDetection_LastExposure", comment: "")
		static let numberOfDaysStored = NSLocalizedString("ExposureDetection_NumberOfDaysStored", comment: "")
		static let refreshed = NSLocalizedString("ExposureDetection_Refreshed", comment: "")
		static let refreshedFormat = NSLocalizedString("ExposureDetection_Refreshed_Format", comment: "")
		static let refreshedNever = NSLocalizedString("ExposureDetection_Refreshed_Never", comment: "")
		static let refreshingIn = NSLocalizedString("ExposureDetection_RefreshingIn", comment: "")
		static let refreshIn = NSLocalizedString("ExposureDetection_RefreshIn", comment: "")
		static let refresh24h = NSLocalizedString("ExposureDetection_Refresh_24h", comment: "")
		static let lastRiskLevel = NSLocalizedString("ExposureDetection_LastRiskLevel", comment: "")
		static let offText = NSLocalizedString("ExposureDetection_OffText", comment: "")
		static let outdatedText = NSLocalizedString("ExposureDetection_OutdatedText", comment: "")
		static let unknownText = NSLocalizedString("ExposureDetection_UnknownText", comment: "")
		static let loadingText = NSLocalizedString("ExposureDetection_LoadingText", comment: "")

		static let behaviorTitle = NSLocalizedString("ExposureDetection_Behavior_Title", comment: "")
		static let behaviorSubtitle = NSLocalizedString("ExposureDetection_Behavior_Subtitle", comment: "")

		static let guideHands = NSLocalizedString("ExposureDetection_Guide_Hands", comment: "")
		static let guideMask = NSLocalizedString("ExposureDetection_Guide_Mask", comment: "")
		static let guideDistance = NSLocalizedString("ExposureDetection_Guide_Distance", comment: "")
		static let guideSneeze = NSLocalizedString("ExposureDetection_Guide_Sneeze", comment: "")
		static let guideHome = NSLocalizedString("ExposureDetection_Guide_Home", comment: "")
		static let guideHotline1 = NSLocalizedString("ExposureDetection_Guide_Hotline1", comment: "")
		static let guideHotline2 = NSLocalizedString("ExposureDetection_Guide_Hotline2", comment: "")
		static let guideHotline3 = NSLocalizedString("ExposureDetection_Guide_Hotline3", comment: "")
		static let guideHotline4 = NSLocalizedString("ExposureDetection_Guide_Hotline4", comment: "")

		static let explanationTitle = NSLocalizedString("ExposureDetection_Explanation_Title", comment: "")
		static let explanationSubtitleActive = NSLocalizedString("ExposureDetection_Explanation_Subtitle_Active", comment: "")
		static let explanationSubtitleInactive = NSLocalizedString("ExposureDetection_Explanation_Subtitle_Inactive", comment: "")
		static let explanationTextOff = NSLocalizedString("ExposureDetection_Explanation_Text_Off", comment: "")
		static let explanationTextOutdated = NSLocalizedString("ExposureDetection_Explanation_Text_Outdated", comment: "")
		static let explanationTextUnknown = NSLocalizedString("ExposureDetection_Explanation_Text_Unknown", comment: "")
		static let explanationTextLow = NSLocalizedString("ExposureDetection_Explanation_Text_Low", comment: "")
		static let explanationTextHigh = NSLocalizedString("ExposureDetection_Explanation_Text_High", comment: "")
		static let explanationTextHighDaysSinceLastExposure = NSLocalizedString("ExposureDetection_Explanation_Text_High_DaysSinceLastExposure", comment: "")

		static let buttonEnable = NSLocalizedString("ExposureDetection_Button_Enable", comment: "")
		static let buttonRefresh = NSLocalizedString("ExposureDetection_Button_Refresh", comment: "")
	}

	enum ExposureDetectionError {
		static let errorAlertTitle = NSLocalizedString("ExposureDetectionError_Alert_Title", comment: "")
		static let errorAlertMessage = NSLocalizedString("ExposureDetectionError_Alert_Message", comment: "")
		static let errorAlertActionDetails = NSLocalizedString("ExposureDetectionError_Alert_Action_Details", comment: "")
	}

	enum Settings {
		static let trackingStatusActive = NSLocalizedString("Settings_KontaktProtokollStatusActive", comment: "")
		static let trackingStatusInactive = NSLocalizedString("Settings_KontaktProtokollStatusInactive", comment: "")

		static let statusEnable = NSLocalizedString("Settings_StatusEnable", comment: "")
		static let statusDisable = NSLocalizedString("Settings_StatusDisable", comment: "")

		static let notificationStatusActive = NSLocalizedString("Settings_StatusActive", comment: "")
		static let notificationStatusInactive = NSLocalizedString("Settings_StatusInactive", comment: "")

		static let tracingLabel = NSLocalizedString("Settings_Tracing_Label", comment: "")
		static let notificationLabel = NSLocalizedString("Settings_Notification_Label", comment: "")
		static let resetLabel = NSLocalizedString("Settings_Reset_Label", comment: "")

		static let tracingDescription = NSLocalizedString("Settings_Tracing_Description", comment: "")
		static let notificationDescription = NSLocalizedString("Settings_Notification_Description", comment: "")
		static let resetDescription = NSLocalizedString("Settings_Reset_Description", comment: "")

		static let navigationBarTitle = NSLocalizedString("Settings_NavTitle", comment: "")

	}

	enum NotificationSettings {
		static let onTitle = NSLocalizedString("NotificationSettings_On_Title", comment: "")
		static let onSectionTitle = NSLocalizedString("NotificationSettings_On_SectionTitle", comment: "")
		static let riskChanges = NSLocalizedString("NotificationSettings_On_RiskChanges", comment: "")
		static let testsStatus = NSLocalizedString("NotificationSettings_On_TestsStatus", comment: "")

		static let offSectionTitle = NSLocalizedString("NotificationSettings_Off_SectionTitle", comment: "")
		static let enableNotifications = NSLocalizedString("NotificationSettings_Off_EnableNotifications", comment: "")
		static let statusInactive = NSLocalizedString("NotificationSettings_Off_StatusInactive", comment: "")
		static let infoTitle = NSLocalizedString("NotificationSettings_Off_InfoTitle", comment: "")
		static let infoDescription = NSLocalizedString("NotificationSettings_Off_InfoDescription", comment: "")
		static let openSettings = NSLocalizedString("NotificationSettings_Off_OpenSettings", comment: "")

		static let navigationBarTitle = NSLocalizedString("NotificationSettings_NavTitle", comment: "")

		static let onImageDescription = NSLocalizedString("NotificationSettings_onImageDescription", comment: "")
		static let offImageDescription = NSLocalizedString("NotificationSettings_offImageDescription", comment: "")
	}
	
	enum Onboarding {
		static let onboardingLetsGo = NSLocalizedString("Onboarding_LetsGo_actionText", comment: "")
		static let onboardingContinue = NSLocalizedString("Onboarding_Continue_actionText", comment: "")
		static let onboardingContinueDescription = NSLocalizedString("Onboarding_Continue_actionTextHint", comment: "")
		static let onboardingDoNotActivate = NSLocalizedString("Onboarding_DoNotActivate_actionText", comment: "")
		static let onboardingDoNotAllow = NSLocalizedString("Onboarding_doNotAllow_actionText", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_title = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_title", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_message = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_message", comment: "")

		static let onboardingInfo_togetherAgainstCoronaPage_imageDescription = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_imageDescription", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_title = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_title", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_boldText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_boldText", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_normalText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_normalText", comment: "")
		static let onboardingInfo_privacyPage_imageDescription = NSLocalizedString("OnboardingInfo_privacyPage_imageDescription", comment: "")
		static let onboardingInfo_privacyPage_title = NSLocalizedString("OnboardingInfo_privacyPage_title", comment: "")
		static let onboardingInfo_privacyPage_boldText = NSLocalizedString("OnboardingInfo_privacyPage_boldText", comment: "")
		static let onboardingInfo_privacyPage_normalText = NSLocalizedString("OnboardingInfo_privacyPage_normalText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_imageDescription = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_imageDescription", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_title = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_title", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_boldText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_boldText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_normalText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_normalText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_panelTitle = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_panelTitle", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_panelBody = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_panelBody", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_imageDescription = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_imageDescription", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_button = NSLocalizedString("Onboarding_EnableLogging_actionText", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_title = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_title", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_boldText = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_boldText", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_normalText = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_normalText", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_imageDescription = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_imageDescription", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_title = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_title", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_boldText = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_boldText", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_normalText = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_normalText", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_stateHeader = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_stateHeader", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_stateTitle = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_stateTitle", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_stateActivated = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_stateActive", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_stateDeactivated = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_stateStopped", comment: "")
	}

	enum ExposureNotificationSetting {
		static let title = NSLocalizedString("ExposureNotificationSetting_TracingSettingTitle", comment: "The title of the view")
		static let enableTracing = NSLocalizedString("ExposureNotificationSetting_EnableTracing", comment: "The enable tracing")
		static let limitedTracing = NSLocalizedString("ExposureNotificationSetting_Tracing_Limited", comment: "")
		static let deactivatedTracing = NSLocalizedString("ExposureNotificationSetting_Tracing_Deactivated", comment: "")
		static let descriptionTitle = NSLocalizedString("ExposureNotificationSetting_DescriptionTitle", comment: "The introduction label")
		static let descriptionTitleInactive = NSLocalizedString("ExposureNotificationSetting_DescriptionTitle_Inactive", comment: "The introduction label when tracing is not active")
		static let descriptionText1 = NSLocalizedString("ExposureNotificationSetting_DescriptionText1", comment: "")
		static let descriptionText2 = NSLocalizedString("ExposureNotificationSetting_DescriptionText2", comment: "")
		static let descriptionText3 = NSLocalizedString("ExposureNotificationSetting_DescriptionText3", comment: "")
		static let actionCellHeader = NSLocalizedString("ExposureNotificationSetting_ActionCell_Header", comment: "")
		static let activateBluetooth = NSLocalizedString("ExposureNotificationSetting_Activate_Bluetooth", comment: "")
		static let activateInternet = NSLocalizedString("ExposureNotificationSetting_Activate_Internet", comment: "")
		static let bluetoothDescription = NSLocalizedString("ExposureNotificationSetting_Bluetooth_Description", comment: "")
		static let internetDescription = NSLocalizedString("ExposureNotificationSetting_Internet_Description", comment: "")
		static let detailActionButtonTitle = NSLocalizedString("ExposureNotificationSetting_Detail_Action_Button", comment: "")
		static let tracingHistoryDescription = NSLocalizedString("ENSetting_Tracing_History", comment: "")
		static let activateOSENSetting = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting", comment: "")
		static let activateOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting_Description", comment: "")
		static let activateParentalControlENSetting = NSLocalizedString("ExposureNotificationSetting_ParentalControls_OSENSetting", comment: "")
		static let activateParentalControlENSettingDescription = NSLocalizedString("ExposureNotificationSetting_ParentalControls_OSENSetting_Description", comment: "")
		static let authorizationRequiredENSetting = NSLocalizedString("ExposureNotificationSetting_AuthorizationRequired_OSENSetting", comment: "")
		static let authorizationRequiredENSettingDescription = NSLocalizedString("ExposureNotificationSetting_AuthorizationRequired_OSENSetting_Description", comment: "")
		static let authorizationButtonTitle = NSLocalizedString("ExposureNotificationSetting_AuthorizationRequired_ActionTitle", comment: "")
		static let privacyConsentActivateAction = NSLocalizedString("ExposureNotificationSetting_Activate_Action", comment: "")
		static let privacyConsentDismissAction = NSLocalizedString("ExposureNotificationSetting_Dismiss_Action", comment: "")

		static let accLabelEnabled = NSLocalizedString("ExposureNotificationSetting_AccLabel_Enabled", comment: "")
		static let accLabelDisabled = NSLocalizedString("ExposureNotificationSetting_AccLabel_Disabled", comment: "")
		static let accLabelBluetoothOff = NSLocalizedString("ExposureNotificationSetting_AccLabel_BluetoothOff", comment: "")
		static let accLabelInternetOff = NSLocalizedString("ExposureNotificationSetting_AccLabel_InternetOff", comment: "")
	}

	enum ExposureNotificationError {

		static let generalErrorTitle = NSLocalizedString("ExposureNotificationSetting_GeneralError_Title", comment: "")

		static let learnMoreActionTitle = NSLocalizedString("ExposureNotificationSetting_GeneralError_LearnMore_Action", comment: "")

		static let learnMoreURL = NSLocalizedString("ExposureNotificationSetting_GeneralError_LearnMore_URL", comment: "")

		static let enAuthorizationError = NSLocalizedString("ExposureNotificationSetting_AuthenticationError", comment: "")

		static let enActivationRequiredError = NSLocalizedString("ExposureNotificationSetting_exposureNotification_Required", comment: "")

		static let enUnavailableError = NSLocalizedString("ExposureNotificationSetting_exposureNotification_unavailable", comment: "")

		static let enUnknownError = NSLocalizedString("ExposureNotificationSetting_unknownError", comment: "")

		static let apiMisuse = NSLocalizedString("ExposureNotificationSetting_apiMisuse", comment: "")
	}

	enum Home {
		// Home Navigation
		static let leftBarButtonDescription = NSLocalizedString("Home_LeftBarButton_description", comment: "")
		static let rightBarButtonDescription = NSLocalizedString("Home_RightBarButton_description", comment: "")

		// Activate Card
		static let activateCardOnTitle = NSLocalizedString("Home_Activate_Card_On_Title", comment: "")
		static let activateCardOffTitle = NSLocalizedString("Home_Activate_Card_Off_Title", comment: "")
		static let activateCardBluetoothOffTitle = NSLocalizedString("Home_Activate_Card_Bluetooth_Off_Title", comment: "")
		static let activateCardInternetOffTitle = NSLocalizedString("Home_Activate_Card_Internet_Off_Title", comment: "")

		// Inactive Card
		static let riskCardInactiveNoCalculationPossibleTitle = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Title", comment: "")
		static let riskCardInactiveOutdatedResultsTitle = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Title", comment: "")
		static let riskCardInactiveNoCalculationPossibleBody = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Body", comment: "")
		static let riskCardInactiveOutdatedResultsBody = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Body", comment: "")
		static let riskCardInactiveNoCalculationPossibleButton = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Button", comment: "")
		static let riskCardInactiveOutdatedResultsButton = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Button", comment: "")

		// Common
		static let riskCardDateItemTitle = NSLocalizedString("Home_Risk_Date_Item_Title", comment: "")
		static let riskCardNoDateTitle = NSLocalizedString("Home_Risk_No_Date_Title", comment: "")
		static let riskCardIntervalUpdateTitle = NSLocalizedString("Home_Risk_Period_Update_Title", comment: "")
		static let riskCardIntervalDisabledButtonTitle = NSLocalizedString("Home_Risk_Period_Disabled_Button_Title", comment: "")
		static let riskCardNumberContactsItemTitle = NSLocalizedString("Home_Risk_Number_Contacts_Item_Title", comment: "")
		static let riskCardLastContactItemTitle = NSLocalizedString("Home_Risk_Last_Contact_Item_Title", comment: "")
		static let riskCardUnknownTitle = NSLocalizedString("Home_Risk_Unknown_Title", comment: "")
		static let riskCardLastActiveItemTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Title", comment: "")
		static let riskCardLastActiveItemUnknownTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Unknown_Title", comment: "")
		static let riskCardLastActiveItemLowTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Low_Title", comment: "")
		static let riskCardLastActiveItemHighTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_High_Title", comment: "")
		static let riskCardUpdateButton = NSLocalizedString("Home_RiskCard_Update_Button", comment: "")

		// Unknown Card
		static let riskCardUnknownItemTitle = NSLocalizedString("Home_RiskCard_Unknown_Item_Title", comment: "")

		// Unknown Card 48h
		static let riskCardUnknown48hBody = NSLocalizedString("Home_RiskCard_Unknown48h_Body", comment: "")

		// Low Card
		static let riskCardLowTitle = NSLocalizedString("Home_Risk_Low_Title", comment: "")
		static let riskCardLowSaveDaysItemTitle = NSLocalizedString("Home_Risk_Low_SaveDays_Item_Title", comment: "")
		static let riskCardLowSaveDaysItemTitle_PermanentlyActive = NSLocalizedString("Home_Risk_Low_SaveDays_Item_Title__Permanently_Active", comment: "")

		static let riskCardLowButton = NSLocalizedString("Home_Risk_Low_Button", comment: "")

		// High Card
		static let riskCardHighTitle = NSLocalizedString("Home_Risk_High_Title", comment: "")

		static let riskCardStatusCheckTitle = NSLocalizedString("Home_Risk_Status_Check_Title", comment: "")
		static let riskCardStatusCheckBody = NSLocalizedString("Home_Risk_Status_Check_Body", comment: "")

		// Thank you card
		static let thankYouCardTitle = NSLocalizedString("Home_Thank_You_Card_Title", comment: "")
		static let thankYouCardBody = NSLocalizedString("Home_Thank_You_Card_Body", comment: "")
		static let thankYouCardNoteTitle = NSLocalizedString("Home_Thank_You_Card_Note_Title", comment: "")
		static let thankYouCardPhoneItemTitle = NSLocalizedString("Home_Thank_You_Card_Phone_Item_Title", comment: "")
		static let thankYouCardHomeItemTitle = NSLocalizedString("Home_Thank_You_Card_Home_Item_Title", comment: "")
		static let thankYouCardFurtherInfoItemTitle = NSLocalizedString("Home_Thank_You_Card_Further_Info_Item_Title", comment: "")
		static let thankYouCard14DaysItemTitle = NSLocalizedString("Home_Thank_You_Card_14Days_Item_Title", comment: "")
		static let thankYouCardContactsItemTitle = NSLocalizedString("Home_Thank_You_Card_Contacts_Item_Title", comment: "")
		static let thankYouCardAppItemTitle = NSLocalizedString("Home_Thank_You_Card_App_Item_Title", comment: "")
		static let thankYouCardNoSymptomsItemTitle = NSLocalizedString("Home_Thank_You_Card_NoSymptoms_Item_Title", comment: "")

		// Finding positive card
		static let findingPositiveCardTitle = NSLocalizedString("Home_Finding_Positive_Card_Title", comment: "")
		static let findingPositiveCardStatusTitle = NSLocalizedString("Home_Finding_Positive_Card_Status_Title", comment: "")
		static let findingPositiveCardStatusSubtitle = NSLocalizedString("Home_Finding_Positive_Card_Status_Subtitle", comment: "")
		static let findingPositiveCardNoteTitle = NSLocalizedString("Home_Finding_Positive_Card_Note_Title", comment: "")
		static let findingPositivePhoneItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Phone_Item_Title", comment: "")
		static let findingPositiveHomeItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Home_Item_Title", comment: "")
		static let findingPositiveShareItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Share_Item_Title", comment: "")
		static let findingPositiveCardButton = NSLocalizedString("Home_Finding_Positive_Card_Button", comment: "")

		// Submit Card
		static let submitCardTitle = NSLocalizedString("Home_SubmitCard_Title", comment: "")
		static let submitCardBody = NSLocalizedString("Home_SubmitCard_Body", comment: "")
		static let submitCardButton = NSLocalizedString("Home_SubmitCard_Button", comment: "")

		static let settingsCardTitle = NSLocalizedString("Home_SettingsCard_Title", comment: "")
		static let appInformationCardTitle = NSLocalizedString("Home_AppInformationCard_Title", comment: "")
		static let appInformationVersion = NSLocalizedString("Home_AppInformationCard_Version", comment: "")

		static let infoCardShareTitle = NSLocalizedString("Home_InfoCard_ShareTitle", comment: "")
		static let infoCardShareBody = NSLocalizedString("Home_InfoCard_ShareBody", comment: "")
		static let infoCardAboutTitle = NSLocalizedString("Home_InfoCard_AboutTitle", comment: "")
		static let infoCardAboutBody = NSLocalizedString("Home_InfoCard_AboutBody", comment: "")

		// Test Result States
		static let resultCardResultAvailableTitle = NSLocalizedString("Home_resultCard_ResultAvailableTitle", comment: "")
		static let resultCardResultUnvailableTitle = NSLocalizedString("Home_resultCard_ResultUnvailableTitle", comment: "")
		static let resultCardLoadingBody = NSLocalizedString("Home_resultCard_LoadingBody", comment: "")
		static let resultCardLoadingTitle = NSLocalizedString("Home_resultCard_LoadingTitle", comment: "")
		static let resultCardShowResultButton = NSLocalizedString("Home_resultCard_ShowResultButton", comment: "")
		static let resultCardNegativeTitle = NSLocalizedString("Home_resultCard_NegativeTitle", comment: "")
		static let resultCardNegativeDesc = NSLocalizedString("Home_resultCard_NegativeDesc", comment: "")
		static let resultCardPendingDesc = NSLocalizedString("Home_resultCard_PendingDesc", comment: "")
		static let resultCardInvalidTitle = NSLocalizedString("Home_resultCard_InvalidTitle", comment: "")
		static let resultCardInvalidDesc = NSLocalizedString("Home_resultCard_InvalidDesc", comment: "")
		static let resultCardLoadingErrorTitle = NSLocalizedString("Home_resultCard_LoadingErrorTitle", comment: "")
	}
	
	enum InviteFriends {
		static let title = NSLocalizedString("InviteFriends_Title", comment: "")
		static let description = NSLocalizedString("InviteFriends_Description", comment: "")
		static let submit = NSLocalizedString("InviteFriends_Button", comment: "")
		static let navigationBarTitle = NSLocalizedString("InviteFriends_NavTitle", comment: "")
		static let shareTitle = NSLocalizedString("InviteFriends_ShareTitle", comment: "")
		static let shareUrl = NSLocalizedString("InviteFriends_ShareUrl", comment: "")
		static let subtitle = NSLocalizedString("InviteFriends_Subtitle", comment: "")
		static let imageAccessLabel = NSLocalizedString("InviteFriends_Illustration_Label", comment: "")
	}

	enum Reset {
		static let navigationBarTitle = NSLocalizedString("Reset_NavTitle", comment: "")
		static let header1 = NSLocalizedString("Reset_Header1", comment: "")
		static let description1 = NSLocalizedString("Reset_Descrition1", comment: "")
		static let resetButton = NSLocalizedString("Reset_Button", comment: "")
		static let discardButton = NSLocalizedString("Reset_Discard", comment: "")
		static let infoTitle = NSLocalizedString("Reset_InfoTitle", comment: "")
		static let infoDescription = NSLocalizedString("Reset_InfoDescription", comment: "")
		static let subtitle = NSLocalizedString("Reset_Subtitle", comment: "")
		static let imageDescription = NSLocalizedString("Reset_ImageDescription", comment: "")

		static let confirmDialogTitle = NSLocalizedString("Reset_ConfirmDialog_Title", comment: "")
		static let confirmDialogDescription = NSLocalizedString("Reset_ConfirmDialog_Description", comment: "")
		static let confirmDialogCancel = NSLocalizedString("Reset_ConfirmDialog_Cancel", comment: "")
		static let confirmDialogConfirm = NSLocalizedString("Reset_ConfirmDialog_Confirm", comment: "")
	}

	enum SafariView {
		static let targetURL = NSLocalizedString("safari_corona_website", comment: "")
	}

	enum LocalNotifications {
		static let ignore = NSLocalizedString("local_notifications_ignore", comment: "")
		static let detectExposureTitle = NSLocalizedString("local_notifications_detectexposure_title", comment: "")
		static let detectExposureBody = NSLocalizedString("local_notifications_detectexposure_body", comment: "")
		static let testResultsTitle = NSLocalizedString("local_notifications_testresults_title", comment: "")
		static let testResultsBody = NSLocalizedString("local_notifications_testresults_body", comment: "")
	}

	enum RiskLegend {
		static let title = NSLocalizedString("RiskLegend_Title", comment: "")
		static let subtitle = NSLocalizedString("RiskLegend_Subtitle", comment: "")
		static let legend1Title = NSLocalizedString("RiskLegend_Legend1_Title", comment: "")
		static let legend1Text = NSLocalizedString("RiskLegend_Legend1_Text", comment: "")
		static let legend2Title = NSLocalizedString("RiskLegend_Legend2_Title", comment: "")
		static let legend2Text = NSLocalizedString("RiskLegend_Legend2_Text", comment: "")
		static let legend2RiskLevels = NSLocalizedString("RiskLegend_Legend2_RiskLevels", comment: "")
		static let legend2High = NSLocalizedString("RiskLegend_Legend2_High", comment: "")
		static let legend2HighColor = NSLocalizedString("RiskLegend_Legend2_High_Color", comment: "")
		static let legend2Low = NSLocalizedString("RiskLegend_Legend2_Low", comment: "")
		static let legend2LowColor = NSLocalizedString("RiskLegend_Legend2_Low_Color", comment: "")
		static let legend2Unknown = NSLocalizedString("RiskLegend_Legend2_Unknown", comment: "")
		static let legend2UnknownColor = NSLocalizedString("RiskLegend_Legend2_Unknown_Color", comment: "")
		static let legend3Title = NSLocalizedString("RiskLegend_Legend3_Title", comment: "")
		static let legend3Text = NSLocalizedString("RiskLegend_Legend3_Text", comment: "")
		static let definitionsTitle = NSLocalizedString("RiskLegend_Definitions_Title", comment: "")
		static let storeTitle = NSLocalizedString("RiskLegend_Store_Title", comment: "")
		static let storeText = NSLocalizedString("RiskLegend_Store_Text", comment: "")
		static let checkTitle = NSLocalizedString("RiskLegend_Check_Title", comment: "")
		static let checkText = NSLocalizedString("RiskLegend_Check_Text", comment: "")
		static let contactTitle = NSLocalizedString("RiskLegend_Contact_Title", comment: "")
		static let contactText = NSLocalizedString("RiskLegend_Contact_Text", comment: "")
		static let notificationTitle = NSLocalizedString("RiskLegend_Notification_Title", comment: "")
		static let notificationText = NSLocalizedString("RiskLegend_Notification_Text", comment: "")
		static let randomTitle = NSLocalizedString("RiskLegend_Random_Title", comment: "")
		static let randomText = NSLocalizedString("RiskLegend_Random_Text", comment: "")
		static let titleImageAccLabel = NSLocalizedString("RiskLegend_Image1_AccLabel", comment: "")
	}

	enum UpdateMessage {
		static let title = NSLocalizedString("Update_Message_Title", comment: "")
		static let text = NSLocalizedString("Update_Message_Text", comment: "")
		static let textForce = NSLocalizedString("Update_Message_Text_Force", comment: "")
		static let actionUpdate = NSLocalizedString("Update_Message_Action_Update", comment: "")
		static let actionLater = NSLocalizedString("Update_Message_Action_Later", comment: "")
	}
	enum AppInformation {
		static let aboutNavigation = NSLocalizedString("App_Information_About_Navigation", comment: "")
		static let aboutImageDescription = NSLocalizedString("App_Information_About_ImageDescription", comment: "")
		static let aboutTitle = NSLocalizedString("App_Information_About_Title", comment: "")
		static let aboutDescription = NSLocalizedString("App_Information_About_Description", comment: "")
		static let aboutText = NSLocalizedString("App_Information_About_Text", comment: "")

		static let faqNavigation = NSLocalizedString("App_Information_FAQ_Navigation", comment: "")

		static let contactNavigation = NSLocalizedString("App_Information_Contact_Navigation", comment: "")
		static let contactImageDescription = NSLocalizedString("App_Information_Contact_ImageDescription", comment: "")
		static let contactTitle = NSLocalizedString("App_Information_Contact_Title", comment: "")
		static let contactDescription = NSLocalizedString("App_Information_Contact_Description", comment: "")
		static let contactHotlineTitle = NSLocalizedString("App_Information_Contact_Hotline_Title", comment: "")
		static let contactHotlineText = NSLocalizedString("App_Information_Contact_Hotline_Text", comment: "")
		static let contactHotlineNumber = NSLocalizedString("App_Information_Contact_Hotline_Number", comment: "")
		static let contactHotlineDescription = NSLocalizedString("App_Information_Contact_Hotline_Description", comment: "")
		static let contactHotlineTerms = NSLocalizedString("App_Information_Contact_Hotline_Terms", comment: "")

		static let imprintNavigation = NSLocalizedString("App_Information_Imprint_Navigation", comment: "")
		static let imprintImageDescription = NSLocalizedString("App_Information_Imprint_ImageDescription", comment: "")
		static let imprintSection1Title = NSLocalizedString("App_Information_Imprint_Section1_Title", comment: "")
		static let imprintSection1Text = NSLocalizedString("App_Information_Imprint_Section1_Text", comment: "")
		static let imprintSection2Title = NSLocalizedString("App_Information_Imprint_Section2_Title", comment: "")
		static let imprintSection2Text = NSLocalizedString("App_Information_Imprint_Section2_Text", comment: "")
		static let imprintSection3Title = NSLocalizedString("App_Information_Imprint_Section3_Title", comment: "")
		static let imprintSection3Text = NSLocalizedString("App_Information_Imprint_Section3_Text", comment: "")
		static let imprintSection4Title = NSLocalizedString("App_Information_Imprint_Section4_Title", comment: "")
		static let imprintSection4Text = NSLocalizedString("App_Information_Imprint_Section4_Text", comment: "")

		static let legalNavigation = NSLocalizedString("App_Information_Legal_Navigation", comment: "")
		static let legalImageDescription = NSLocalizedString("App_Information_Legal_ImageDescription", comment: "")

		static let privacyNavigation = NSLocalizedString("App_Information_Privacy_Navigation", comment: "")
		static let privacyImageDescription = NSLocalizedString("App_Information_Privacy_ImageDescription", comment: "")
		static let privacyTitle = NSLocalizedString("App_Information_Privacy_Title", comment: "")

		static let termsNavigation = NSLocalizedString("App_Information_Terms_Navigation", comment: "")
		static let termsImageDescription = NSLocalizedString("App_Information_Terms_ImageDescription", comment: "")
		static let termsTitle = NSLocalizedString("App_Information_Terms_Title", comment: "")
	}

	enum ENATanInput {
		static let empty = NSLocalizedString("ENATanInput_Empty", comment: "")
		static let invalidCharacter = NSLocalizedString("ENATanInput_InvalidCharacter", comment: "")
		static let characterIndex = NSLocalizedString("ENATanInput_CharacterIndex", comment: "")
	}
}
