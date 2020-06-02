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
		static let alertMessageGeneral = NSLocalizedString("Alert_MessageGeneral", comment: "")
		static let alertActionOk = NSLocalizedString("Alert_ActionOk", comment: "")
		static let alertActionNo = NSLocalizedString("Alert_ActionNo", comment: "")
		static let alertTitleKeySubmit = NSLocalizedString("Alert_TitleKeySubmit", comment: "")
		static let alertDescriptionKeySubmit = NSLocalizedString("Alert_DescriptionKeySubmit", comment: "")

		static let alertTitleBluetoothOff = NSLocalizedString("Alert_BluetoothOff_Title", comment: "")
		static let alertDescriptionBluetoothOff = NSLocalizedString("Alert_BluetoothOff_Description", comment: "")
		static let alertActionLater = NSLocalizedString("Alert_CancelAction_Later", comment: "")
		static let alertActionOpenSettings = NSLocalizedString("Alert_DefaultAction_OpenSettings", comment: "")
	}

	enum ExposureSubmission {
		static let generalErrorTitle = NSLocalizedString("ExposureSubmission_GeneralErrorTitle", comment: "")
		static let dataPrivacyTitle = NSLocalizedString("ExposureSubmission_DataPrivacyTitle", comment: "")
		static let dataPrivacyDisclaimer = NSLocalizedString("ExposureSubmission_DataPrivacyDescription", comment: "")
		static let dataPrivacyAcceptTitle = NSLocalizedString("ExposureSubmissionDataPrivacy_AcceptTitle", comment: "")
		static let dataPrivacyDontAcceptTitle = NSLocalizedString("ExposureSubmissionDataPrivacy_DontAcceptTitle", comment: "")
	}

	enum ExposureSubmissionTanEntry {
		static let title = NSLocalizedString("ExposureSubmissionTanEntry_Title", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionTanEntry_Description", comment: "")
		static let info = NSLocalizedString("ExposureSubmissionTanEntry_Info", comment: "")
		static let submit = NSLocalizedString("ExposureSubmissionTanEntry_Submit", comment: "")
	}

	enum ExposureSubmissionConfirmation {
		static let submit = NSLocalizedString("ExposureSubmissionConfirmation_Submit", comment: "")
	}

	enum ExposureSubmissionIntroduction {
		static let title = NSLocalizedString("ExposureSubmissionIntroduction_Title", comment: "")
		static let usage01 = NSLocalizedString("ExposureSubmissionIntroduction_Usage01", comment: "")
		static let usage02 = NSLocalizedString("ExposureSubmissionIntroduction_Usage02", comment: "")
		static let usage03 = NSLocalizedString("ExposureSubmissionIntroduction_Usage03", comment: "")
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
		static let warnOthersDesc = NSLocalizedString("ExposureSubmissionResult_warnOthersDesc", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionResult_continueButton", comment: "")
		static let deleteButton = NSLocalizedString("ExposureSubmissionResult_deleteButton", comment: "")
		static let refreshButton = NSLocalizedString("ExposureSubmissionResult_refreshButton", comment: "")
		static let furtherInfos_Title = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_title", comment: "")
		static let furtherInfos_ListItem1 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem1", comment: "")
		static let furtherInfos_ListItem2 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem2", comment: "")
		static let furtherInfos_ListItem3 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem3", comment: "")
		static let furtherInfos_Hint = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_hint", comment: "")
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
	}

	enum ExposureSubmissionHotline {
		static let title = NSLocalizedString("ExposureSubmissionHotline_Title", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionHotline_Description", comment: "")
		static let sectionTitle = NSLocalizedString("ExposureSubmissionHotline_SectionTitle", comment: "")
		static let sectionDescription1 = NSLocalizedString("ExposureSubmissionHotline_SectionDescription1", comment: "")
		static let sectionDescription2 = NSLocalizedString("ExposureSubmission_SectionDescription2", comment: "")
		static let callButtonTitle = NSLocalizedString("ExposureSubmission_CallButtonTitle", comment: "")
		static let tanInputButtonTitle = NSLocalizedString("ExposureSubmission_TANInputButtonTitle", comment: "")
	}

	enum ExposureSubmissionWarnOthers {
		static let title = NSLocalizedString("ExposureSubmissionWarnOthers_title", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionWarnOthers_continueButton", comment: "")
		static let sectionTitle = NSLocalizedString("ExposureSubmissionWarnOthers_sectionTitle", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionWarnOthers_description", comment: "")
		static let dataPrivacyDescription = NSLocalizedString("ExposureSubmissionWarnOthers_dataPrivacyDescription", comment: "")
	}

	enum ExposureSubmissionSuccess {
		static let title = NSLocalizedString("ExposureSubmissionSuccess_Title", comment: "")
		static let button = NSLocalizedString("ExposureSubmissionSuccess_Button", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionSuccess_Description", comment: "")
		static let subTitle = NSLocalizedString("ExposureSubmissionSuccess_subTitle", comment: "")
		static let listTitle = NSLocalizedString("ExposureSubmissionSuccess_listTitle", comment: "")
		static let listItem1 = NSLocalizedString("ExposureSubmissionSuccess_listItem1", comment: "")
		static let listItem2 = NSLocalizedString("ExposureSubmissionSuccess_listItem2", comment: "")
	}

	enum ExposureDetection {
		static let off = NSLocalizedString("ExposureDetection_Off", comment: "")
		static let unknown = NSLocalizedString("ExposureDetection_Unknown", comment: "")
		static let inactive = NSLocalizedString("ExposureDetection_Inactive", comment: "")
		static let low = NSLocalizedString("ExposureDetection_Low", comment: "")
		static let high = NSLocalizedString("ExposureDetection_High", comment: "")
		static let loading = NSLocalizedString("ExposureDetection_Loading", comment: "")

		static let numberOfContacts = NSLocalizedString("ExposureDetection_NumberOfContacts", comment: "")
		static let lastExposure = NSLocalizedString("ExposureDetection_LastExposure", comment: "")
		static let numberOfDaysStored = NSLocalizedString("ExposureDetection_NumberOfDaysStored", comment: "")
		static let refreshed = NSLocalizedString("ExposureDetection_Refreshed", comment: "")
		static let refreshedFormat = NSLocalizedString("ExposureDetection_Refreshed_Format", comment: "")
		static let refreshedNever = NSLocalizedString("ExposureDetection_Refreshed_Never", comment: "")
		static let refreshingIn = NSLocalizedString("ExposureDetection_RefreshingIn", comment: "")
		static let lastRiskLevel = NSLocalizedString("ExposureDetection_LastRiskLevel", comment: "")
		static let unknownText = NSLocalizedString("ExposureDetection_UnknownText", comment: "")
		static let inactiveText = NSLocalizedString("ExposureDetection_InactiveText", comment: "")
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
		static let explanationSubtitle = NSLocalizedString("ExposureDetection_Explanation_Subtitle", comment: "")
		static let explanationTextOff = NSLocalizedString("ExposureDetection_Explanation_Text_Off", comment: "")
		static let explanationTextUnknown = NSLocalizedString("ExposureDetection_Explanation_Text_Unknown", comment: "")
		static let explanationTextInactive = NSLocalizedString("ExposureDetection_Explanation_Text_Inactive", comment: "")
		static let explanationTextLow = NSLocalizedString("ExposureDetection_Explanation_Text_Low", comment: "")
		static let explanationTextHigh = NSLocalizedString("ExposureDetection_Explanation_Text_High", comment: "")

		static let moreInformation = NSLocalizedString("ExposureDetection_MoreInformation", comment: "")
		static let moreInformationUrl = NSLocalizedString("ExposureDetection_MoreInformation_URL", comment: "")

		static let hotlineNumber = NSLocalizedString("ExposureDetection_Hotline_Number", comment: "")

		static let buttonEnable = NSLocalizedString("ExposureDetection_Button_Enable", comment: "")
		static let buttonRefresh = NSLocalizedString("ExposureDetection_Button_Refresh", comment: "")
		static let buttonRefreshingIn = NSLocalizedString("ExposureDetection_Button_RefreshingIn", comment: "")
	}

	enum Settings {
		static let trackingStatusActive = NSLocalizedString("Settings_KontaktProtokollStatusActive", comment: "")
		static let trackingStatusInactive = NSLocalizedString("Settings_KontaktProtokollStatusInactive", comment: "")
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
		static let onDescription = NSLocalizedString("NotificationSettings_On_Description", comment: "")
		static let onSectionTitle = NSLocalizedString("NotificationSettings_On_SectionTitle", comment: "")
		static let riskChanges = NSLocalizedString("NotificationSettings_On_RiskChanges", comment: "")
		static let testsStatus = NSLocalizedString("NotificationSettings_On_TestsStatus", comment: "")

		static let offTitle = NSLocalizedString("NotificationSettings_Off_Title", comment: "")
		static let offDescription = NSLocalizedString("NotificationSettings_Off_Description", comment: "")
		static let navigateSettings = NSLocalizedString("NotificationSettings_Off_NavigateSettings", comment: "")
		static let pickNotifications = NSLocalizedString("NotificationSettings_Off_PickNotifications", comment: "")
		static let enableNotifications = NSLocalizedString("NotificationSettings_Off_EnableNotifications", comment: "")
		static let openSettings = NSLocalizedString("NotificationSettings_Off_OpenSettings", comment: "")

		static let navigationBarTitle = NSLocalizedString("NotificationSettings_NavTitle", comment: "")
	}

	enum Onboarding {
		static let onboardingFinish = NSLocalizedString("Onboarding_Finish", comment: "")
		static let onboardingNext = NSLocalizedString("Onboarding_Next", comment: "")

		static let onboardingLetsGo = NSLocalizedString("Onboarding_LetsGo_actionText", comment: "")
		static let onboardingContinue = NSLocalizedString("Onboarding_Continue_actionText", comment: "")
		static let onboardingDoNotActivate = NSLocalizedString("Onboarding_DoNotActivate_actionText", comment: "")
		static let onboardingDoNotAllow = NSLocalizedString("Onboarding_doNotAllow_actionText", comment: "")
		static let onboardingBack = NSLocalizedString("Onboarding_Back_actionText", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_title = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_title", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_message = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_message", comment: "")

		static let onboardingInfo_togetherAgainstCoronaPage_title = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_title", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_boldText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_boldText", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_normalText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_normalText", comment: "")
		static let onboardingInfo_privacyPage_title = NSLocalizedString("OnboardingInfo_privacyPage_title", comment: "")
		static let onboardingInfo_privacyPage_boldText = NSLocalizedString("OnboardingInfo_privacyPage_boldText", comment: "")
		static let onboardingInfo_privacyPage_normalText = NSLocalizedString("OnboardingInfo_privacyPage_normalText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_title = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_title", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_boldText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_boldText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_normalText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_normalText", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_title = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_title", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_boldText = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_boldText", comment: "")
		static let onboardingInfo_howDoesDataExchangeWorkPage_normalText = NSLocalizedString("OnboardingInfo_howDoesDataExchangeWorkPage_normalText", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_title = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_title", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_boldText = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_boldText", comment: "")
		static let onboardingInfo_alwaysStayInformedPage_normalText = NSLocalizedString("OnboardingInfo_alwaysStayInformedPage_normalText", comment: "")
	}

	enum ExposureNotificationSetting {
		static let title = NSLocalizedString("ExposureNotificationSetting_TracingSettingTitle", comment: "The title of the view")
		static let enableTracing = NSLocalizedString("ExposureNotificationSetting_EnableTracing", comment: "The enable tracing")
		static let limitedTracing = NSLocalizedString("ExposureNotificationSetting_Tracing_Limited", comment: "")
		static let deactivatedTracing = NSLocalizedString("ExposureNotificationSetting_Tracing_Deactivated", comment: "")
		static let descriptionTitle = NSLocalizedString("ExposureNotificationSetting_DescriptionTitle", comment: "The introduction label")
		static let descriptionText1 = NSLocalizedString("ExposureNotificationSetting_DescriptionText1", comment: "")
		static let descriptionText2 = NSLocalizedString("ExposureNotificationSetting_DescriptionText2", comment: "")
		static let actionCellHeader = NSLocalizedString("ExposureNotificationSetting_ActionCell_Header", comment: "")
		static let activateBluetooth = NSLocalizedString("ExposureNotificationSetting_Activate_Bluetooth", comment: "")
		static let activateInternet = NSLocalizedString("ExposureNotificationSetting_Activate_Internet", comment: "")
		static let bluetoothDescription = NSLocalizedString("ExposureNotificationSetting_Bluetooth_Description", comment: "")
		static let internetDescription = NSLocalizedString("ExposureNotificationSetting_Internet_Description", comment: "")
		static let detailActionButtonTitle = NSLocalizedString("ExposureNotificationSetting_Detail_Action_Button", comment: "")
		static let tracingHistoryDescription = NSLocalizedString("ENSetting_Tracing_History", comment: "")
		static let activateOSENSetting = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting", comment: "")
		static let activateOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting_Description", comment: "")
	}

	enum Home {
		// Activate Card
		static let activateCardOnTitle = NSLocalizedString("Home_Activate_Card_On_Title", comment: "")
		static let activateCardOffTitle = NSLocalizedString("Home_Activate_Card_Off_Title", comment: "")
		static let activateCardBluetoothOffTitle = NSLocalizedString("Home_Activate_Card_Bluetooth_Off_Title", comment: "")
		static let activateCardInternetOffTitle = NSLocalizedString("Home_Activate_Card_Internet_Off_Title", comment: "")

		// Risk Card
		static let riskCardUnknownTitle = NSLocalizedString("Home_Risk_Unknown_Title", comment: "")
		static let riskCardUnknownItemTitle = NSLocalizedString("Home_RiskCard_Unknown_Item_Title", comment: "")
		static let riskCardUnknownButton = NSLocalizedString("Home_RiskCard_Unknown_Button", comment: "")

		static let riskCardInactiveTitle = NSLocalizedString("Home_Risk_Inactive_Title", comment: "")
		static let riskCardInactiveBody = NSLocalizedString("Home_Risk_Inactive_Body", comment: "")
		static let riskCardInactiveActivateItemTitle = NSLocalizedString("Home_Risk_Inactive_Activate_Item_Title", comment: "")
		static let riskCardInactiveDateItemTitle = NSLocalizedString("Home_Risk_Inactive_Date_Item_Title", comment: "")
		static let riskCardInactiveButton = NSLocalizedString("Home_Risk_Inactive_Button", comment: "")

		static let riskCardLowTitle = NSLocalizedString("Home_Risk_Low_Title", comment: "")
		static let riskCardLowNoContactItemTitle = NSLocalizedString("Home_Risk_Low_NoContact_Item_Title", comment: "")
		static let riskCardLowSaveDaysItemTitle = NSLocalizedString("Home_Risk_Low_SaveDays_Item_Title", comment: "")
		static let riskCardLowDateItemTitle = NSLocalizedString("Home_Risk_Low_Date_Item_Title", comment: "")
		static let riskCardLowButton = NSLocalizedString("Home_Risk_Low_Button", comment: "")

		static let riskCardHighTitle = NSLocalizedString("Home_Risk_High_Title", comment: "")
		static let riskCardHighNumberContactsItemTitle = NSLocalizedString("Home_Risk_High_Number_Contacts_Item_Title", comment: "")
		static let riskCardHighLastContactItemTitle = NSLocalizedString("Home_Risk_High_Last_Contact_Item_Title", comment: "")
		static let riskCardHighDateItemTitle = NSLocalizedString("Home_Risk_High_Date_Item_Title", comment: "")
		static let riskCardHighButton = NSLocalizedString("Home_Risk_High_Button", comment: "")

		static let riskCardStatusCheckTitle = NSLocalizedString("Home_Risk_Status_Check_Title", comment: "")
		static let riskCardStatusCheckBody = NSLocalizedString("Home_Risk_Status_Check_Body", comment: "")
		static let riskCardStatusCheckButton = NSLocalizedString("Home_Risk_Status_Check_Button", comment: "")
		static let riskCardStatusCheckCounterLabel = NSLocalizedString("Home_Risk_Status_Counter_Label", comment: "")

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
		static let resultCardShowResultButton = NSLocalizedString("Home_resultCard_ShowResultButton", comment: "")
		static let resultCardNegativeTitle = NSLocalizedString("Home_resultCard_NegativeTitle", comment: "")
		static let resultCardNegativeDesc = NSLocalizedString("Home_resultCard_NegativeDesc", comment: "")
		static let resultCardPositiveTitle = NSLocalizedString("Home_resultCard_PositiveTitle", comment: "")
		static let resultCardPositiveDesc = NSLocalizedString("Home_resultCard_PositiveDesc", comment: "")
		static let resultCardPendingTitle = NSLocalizedString("Home_resultCard_PendingTitle", comment: "")
		static let resultCardPendingDesc = NSLocalizedString("Home_resultCard_PendingDesc", comment: "")
		static let resultCardInvalidTitle = NSLocalizedString("Home_resultCard_InvalidTitle", comment: "")
		static let resultCardInvalidDesc = NSLocalizedString("Home_resultCard_InvalidDesc", comment: "")
	}

	enum RiskView {
		static let unknownRisk = NSLocalizedString("unknown_risk", comment: "")
		static let inactiveRisk = NSLocalizedString("inactive_risk", comment: "")
		static let lowRisk = NSLocalizedString("low_risk", comment: "")
		static let highRisk = NSLocalizedString("high_risk", comment: "")

		static let unknownRiskDetail = NSLocalizedString("unknown_risk_detail", comment: "")
		static let inactiveRiskDetail = NSLocalizedString("inactive_risk_detail", comment: "")
		static let lowRiskDetail = NSLocalizedString("low_risk_detail", comment: "")
		static let highRiskDetail = NSLocalizedString("high_risk_detail", comment: "")

		static let unknownRiskDetailHelp = NSLocalizedString("unknown_risk_detail_help", comment: "")
		static let inactiveRiskDetailHelp = NSLocalizedString("inactive_risk_detail_help", comment: "")
		static let lowRiskDetailHelp = NSLocalizedString("low_risk_detail_help", comment: "")
		static let highRiskDetailHelp = NSLocalizedString("high_risk_detail_help", comment: "")
	}

	enum InviteFriends {
		static let title = NSLocalizedString("InviteFriends_Title", comment: "")
		static let description = NSLocalizedString("InviteFriends_Description", comment: "")
		static let submit = NSLocalizedString("InviteFriends_Button", comment: "")
		static let navigationBarTitle = NSLocalizedString("InviteFriends_NavTitle", comment: "")
		static let shareTitle = NSLocalizedString("InviteFriends_ShareTitle", comment: "")
		static let shareUrl = NSLocalizedString("InviteFriends_ShareUrl", comment: "")
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
	}

	enum SafariView {
		static let targetURL = NSLocalizedString("safari_corona_website", comment: "")
	}

	enum LocalNotifications {
		static let viewResults = NSLocalizedString("local_notifications_viewResults", comment: "")
		static let ignore = NSLocalizedString("local_notifications_ignore", comment: "")
		static let detectExposureTitle = NSLocalizedString("local_notifications_detectexposure_title", comment: "")
		static let detectExposureBody = NSLocalizedString("local_notifications_detectexposure_body", comment: "")
		static let testResultsTitle = NSLocalizedString("local_notifications_testresults_title", comment: "")
		static let testResultsBody = NSLocalizedString("local_notifications_testresults_body", comment: "")
	}
}
