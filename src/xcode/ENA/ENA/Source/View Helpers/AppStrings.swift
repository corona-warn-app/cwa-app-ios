//
// 🦠 Corona-Warn-App
//

import UIKit

// swiftlint:disable:next type_body_length
enum AppStrings {
	enum Common {
		static let alertTitleGeneral = NSLocalizedString("Alert_TitleGeneral", comment: "")
		static let alertActionOk = NSLocalizedString("Alert_ActionOk", comment: "")
		static let alertActionYes = NSLocalizedString("Alert_ActionYes", comment: "")
		static let alertActionNo = NSLocalizedString("Alert_ActionNo", comment: "")
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
		static let deadmanAlertTitle = NSLocalizedString("Common_Deadman_AlertTitle", comment: "")
		static let deadmanAlertBody = NSLocalizedString("Common_Deadman_AlertBody", comment: "")
		static let tessRelayDescription = NSLocalizedString("Common_Tess_Relay_Description", comment: "")
		static let noNetworkConnection = NSLocalizedString("Common_No_Network", comment: "")
	}

	enum Links {
		static let appFaq = NSLocalizedString("General_moreInfo_URL", tableName: "Localizable.links", comment: "")
		static let appFaqENError5 = NSLocalizedString("General_moreInfo_URL_EN5", tableName: "Localizable.links", comment: "")
		static let appFaqENError11 = NSLocalizedString("General_moreInfo_URL_EN11", tableName: "Localizable.links", comment: "")
		static let appFaqENError13 = NSLocalizedString("General_moreInfo_URL_EN13", tableName: "Localizable.links", comment: "")
		static let exposureDetectionFAQ = NSLocalizedString("ExposureDetection_high_faq_URL", tableName: "Localizable.links", comment: "")
		static let healthCertificateErrorFAQ = NSLocalizedString("HealthCertificate_Error_FAQ_Link", tableName: "Localizable.links", comment: "")
		static let testCertificateErrorFAQ = NSLocalizedString("TestCertificate_Error_FAQ_Link", tableName: "Localizable.links", comment: "")
		static let findTestCentersFAQ = NSLocalizedString("Test_Centers_FAQ_Link", tableName: "Localizable.links", comment: "")
		static let healthCertificateValidationFAQ = NSLocalizedString("HealthCertificate_Info_validation_FAQLink", tableName: "Localizable.links", comment: "")
		static let healthCertificateValidationEU = NSLocalizedString("HealthCertificate_Info_validation_EULink", tableName: "Localizable.links", comment: "")
		static let invalidSignatureFAQ = NSLocalizedString("HealthCertificate_InvalidSignature_FAQLink", tableName: "Localizable.links", comment: "")
		static let statisticsInfoBlog = NSLocalizedString("Statistics_Info_Blog_Link", tableName: "Localizable.links", comment: "")
		static let healthCertificatePrintFAQ = NSLocalizedString("HealthCertificate_Print_FAQ_Link", tableName: "Localizable.links", comment: "")
		static let healthCertificateBoosterFAQ = NSLocalizedString("HealthCertificate_Booster_FAQLink", tableName: "Localizable.links", comment: "")
		static let notificationSettingsFAQ = NSLocalizedString("NotificationSettings_FAQLink", tableName: "Localizable.links", comment: "")
		static let ticketValidationNoValidDCCFAQ = NSLocalizedString("TicketValidation_NoValidDCC_FAQLink", tableName: "Localizable.links", comment: "")
		static let ticketValidationServiceResultFAQ = NSLocalizedString("TicketValidation_ServiceResult_FAQLink", tableName: "Localizable.links", comment: "")
		static let selfQuarantineFAQ = NSLocalizedString("Risk_Voluntary_Self_Quarantine_FAQ_URL", tableName: "Localizable.links", comment: "")
		static let quarantineMeasuresFAQ = NSLocalizedString("Risk_Quarantine_Measures_FAQ_URL", tableName: "Localizable.links", comment: "")
	}

	enum QuickActions {
		static let contactDiaryNewEntry = NSLocalizedString("QuickAction_newContactDiaryEntry", comment: "")
		static let eventCheckin = NSLocalizedString("QuickAction_eventCheckin", comment: "")
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
		static let continueText = NSLocalizedString("ExposureSubmission_Continue_actionText", comment: "")
		static let primaryButton = NSLocalizedString("ExposureSubmission_Continue_actionText", comment: "")
		static let confirmDismissPopUpTitle = NSLocalizedString("ExposureSubmission_ConfirmDismissPopUpTitle", comment: "")
		static let confirmDismissPopUpText = NSLocalizedString("ExposureSubmission_ConfirmDismissPopUpText", comment: "")
		static let hotlineNumber = NSLocalizedString("ExposureSubmission_Hotline_Number", comment: "")
		static let hotlineNumberForeign = NSLocalizedString("ExposureSubmission_Hotline_Number_Foreign", comment: "")
		static let qrCodeExpiredTitle = NSLocalizedString("ExposureSubmissionQRInfo_QRCodeExpired_Alert_Title", comment: "")
		static let qrCodeExpiredAlertText = NSLocalizedString("ExposureSubmissionQRInfo_QRCodeExpired_Alert_Text", comment: "")

		static let ratQRCodeInvalidAlertTitle = NSLocalizedString("ExposureSubmission_RAT_QR_Invalid_Alert_Title", comment: "")
		static let ratQRCodeInvalidAlertText = NSLocalizedString("ExposureSubmission_RAT_QR_Invalid_Alert_Text", comment: "")
		static let ratQRCodeInvalidAlertButton = NSLocalizedString("ExposureSubmission_RAT_QR_Invalid_Alert_Button", comment: "")

		enum OverwriteNotice {
			static let title = NSLocalizedString("ExposureSubmission_OverwriteNotice_Title", comment: "")
			static let primaryButton = NSLocalizedString("ExposureSubmission_OverwriteNotice_PrimaryButton", comment: "")
			static let imageDescription = NSLocalizedString("ExposureSubmission_OverwriteNotice_Image_Description", comment: "")

			enum Pcr {
				static let headline = NSLocalizedString("ExposureSubmission_OverwriteNotice_Pcr_Headline", comment: "")
				static let text = NSLocalizedString("ExposureSubmission_OverwriteNotice_Pcr_Text", comment: "")
			}

			enum Antigen {
				static let headline = NSLocalizedString("ExposureSubmission_OverwriteNotice_Antigen_Headline", comment: "")
				static let text = NSLocalizedString("ExposureSubmission_OverwriteNotice_Antigen_Text", comment: "")
			}
		}

		enum AntigenTest {

			enum Information {
				static let title = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_Title", comment: "")
				static let imageDescription = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_Image_Description", comment: "")
				static let descriptionTitle = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_Description_Title", comment: "")
				static let descriptionSubHeadline = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_DescriptionSubHeadline", comment: "")
				static let primaryButton = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_PrimaryButton", comment: "")

				enum legal {
					static let title = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Headline", tableName: "Localizable.legal", comment: "")
					static let text01 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text01", tableName: "Localizable.legal", comment: "")
					static let text02 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text02", tableName: "Localizable.legal", comment: "")
					static let text03 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text03", tableName: "Localizable.legal", comment: "")
					static let text04 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text04", tableName: "Localizable.legal", comment: "")
					static let text05 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text05", tableName: "Localizable.legal", comment: "")
					static let text06 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text06", tableName: "Localizable.legal", comment: "")
					static let text07 = NSLocalizedString("ExposureSubmission_Antigen_Profile_Legal_Text07", tableName: "Localizable.legal", comment: "")
				}
				static let dataPrivacyTitle = NSLocalizedString("ExposureSubmission_Antigen_Profile_Information_Dataprivacy_Title", comment: "")
			}

			enum Profile {
				static let headerText = NSLocalizedString("ExposureSubmission_Antigen_Profile_Header_Text", comment: "")
				static let QRCodeImageDescription = NSLocalizedString("ExposureSubmission_Antigen_Profile_QRCode_Image_Description", comment: "")
				static let noticeText = NSLocalizedString("ExposureSubmission_Antigen_Profile_Noice_Text", comment: "")
				static let dateOfBirthFormatText = NSLocalizedString("ExposureSubmission_Antigen_Profile_DateOfBirth_Format", comment: "")
				static let primaryButton = NSLocalizedString("ExposureSubmission_Antigen_Profile_Primary_Button", comment: "")
				static let secondaryButton = NSLocalizedString("ExposureSubmission_Antigen_Profile_Secondary_Button", comment: "")

				static let createProfileTile_Title = NSLocalizedString("ExposureSubmission_Profile_CreateProfileTile_Title", comment: "")
				static let createProfileTile_Description = NSLocalizedString("ExposureSubmission_Profile_CreateProfileTile_Description", comment: "")
				static let profileTile_Title = NSLocalizedString("ExposureSubmission_Profile_ProfileTile_Title", comment: "")
				static let profileTile_Description = NSLocalizedString("ExposureSubmission_Profile_ProfileTile_Description", comment: "")
			}
		}

		enum TestCertificate {
			enum Info {
				static let title = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Title", comment: "")
				static let primaryButton = NSLocalizedString("ExposureSubmission_TestCertificate_Information_PrimaryButton", comment: "")
				static let secondaryButton = NSLocalizedString("ExposureSubmission_TestCertificate_Information_SecondaryButton", comment: "")
				static let imageDescription = NSLocalizedString("ExposureSubmission_TestCertificate_Information_ImageDescription", comment: "")
				static let body = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Subheadline", comment: "")
				static let birthdayPlaceholder = NSLocalizedString("ExposureSubmission_TestCertificate_Information_BirthdayPlaceholder", comment: "")
				static let birthdayText = NSLocalizedString("ExposureSubmission_TestCertificate_Information_BirthdayText", comment: "")
				static let section_1 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Section01", comment: "")
				static let section_2 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Section02", comment: "")

				static let legalHeadline_1 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Headline", tableName: "Localizable.legal", comment: "")
				static let legalText_1 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_1", tableName: "Localizable.legal", comment: "")
				static let legalText_2 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_2", tableName: "Localizable.legal", comment: "")
				static let legalText_2a_PCR = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_2a_PCR", tableName: "Localizable.legal", comment: "")
				static let legalText_3 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_3", tableName: "Localizable.legal", comment: "")
				static let legalText_4 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_4", tableName: "Localizable.legal", comment: "")
				static let legalText_5 = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Legal_Text_5", tableName: "Localizable.legal", comment: "")
				static let dataPrivacyTitle = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Dataprivacy_Title", comment: "")

				enum Alert {
					static let title = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Alert_Title", comment: "")
					static let message = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Alert_Message", comment: "")
					static let continueRegistration = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Alert_ContinueRegistration", comment: "")
					static let cancelRegistration = NSLocalizedString("ExposureSubmission_TestCertificate_Information_Alert_CancelRegistration", comment: "")
				}

			}
		}
	}

	enum ExposureSubmissionTanEntry {
		static let title = NSLocalizedString("ExposureSubmissionTanEntry_Title", comment: "")
		static let textField = NSLocalizedString("ExposureSubmissionTanEntry_EntryField", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionTanEntry_Description", comment: "")
		static let submit = NSLocalizedString("ExposureSubmissionTanEntry_Submit", comment: "")
		static let invalidCharacterError = NSLocalizedString("ExposureSubmissionTanEntry_InvalidCharacterError", comment: "")
		static let invalidError = NSLocalizedString("ExposureSubmissionTanEntry_InvalidError", comment: "")
	}
	
	enum ExposureSubmissionCheckins {
		static let title = NSLocalizedString("Submission_Checkins_Title", comment: "")
		static let description = NSLocalizedString("Submission_Checkins_Description", comment: "")
		static let selectAll = NSLocalizedString("Submission_Checkins_SelectAll", comment: "")
		static let continueButton = NSLocalizedString("Submission_Checkins_Continue", comment: "")
		static let skipButton = NSLocalizedString("Submission_Checkins_Skip", comment: "")
		static let alertTitle = NSLocalizedString("Submission_Checkins_Alert_Title", comment: "")
		static let alertMessage = NSLocalizedString("Submission_Checkins_Alert_Message", comment: "")
		static let alertShare = NSLocalizedString("Submission_Checkins_Alert_Share", comment: "")
		static let alertDontShare = NSLocalizedString("Submission_Checkins_Alert_DontShare", comment: "")
	}

	enum ExposureSubmissionTestResultAvailable {
		static let title = NSLocalizedString("ExposureSubmissionTestresultAvailable_Title", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionTestresultAvailable_AccImageDescription", comment: "")
		static let consentGranted = NSLocalizedString("ExposureSubmissionTestresultAvailable_Consent_granted", comment: "")
		static let consentNotGranted = NSLocalizedString("ExposureSubmissionTestresultAvailable_Consent_not_given", comment: "")
		static let listItem1WithConsent = NSLocalizedString("ExposureSubmissionTestresultAvailable_ListItem1WithConsent", comment: "")
		static let listItem2WithConsent = NSLocalizedString("ExposureSubmissionTestresultAvailable_ListItem2WithConsent", comment: "")
		static let listItem1WithoutConsent = NSLocalizedString("ExposureSubmissionTestresultAvailable_ListItem1WithoutConsent", comment: "")
		static let listItem2WithoutConsent = NSLocalizedString("ExposureSubmissionTestresultAvailable_ListItem2WithoutConsent", comment: "")
		static let primaryButtonTitle = NSLocalizedString("ExposureSubmissionTestresultAvailable_primaryButtonTitle", comment: "")
		static let closeAlertTitle = NSLocalizedString("ExposureSubmissionTestresultAvailable_CloseAlertTitle", comment: "")
		static let closeAlertButtonClose = NSLocalizedString("ExposureSubmissionTestresultAvailable_CloseAlertButtonCancel", comment: "")
		static let closeAlertButtonContinue = NSLocalizedString("ExposureSubmissionTestresultAvailable_CloseAlertButtonContinue", comment: "")
	}

	enum ExposureSubmissionResult {

		enum PCR {
			static let title = NSLocalizedString("ExposureSubmissionResult_Title", comment: "")
			static let card_positive = NSLocalizedString("ExposureSubmissionResult_CardPositive", comment: "")
			static let card_negative = NSLocalizedString("ExposureSubmissionResult_CardNegative", comment: "")
			static let card_subtitle = NSLocalizedString("ExposureSubmissionResult_CardSubTitle", comment: "")
			static let testPending = NSLocalizedString("ExposureSubmissionResult_testPending", comment: "")
			static let testPendingDesc = NSLocalizedString("ExposureSubmissionResult_testPendingDesc", comment: "")
			static let testAdded = NSLocalizedString("ExposureSubmissionResult_testAdded", comment: "")
			static let registrationDate = NSLocalizedString("ExposureSubmissionResult_RegistrationDate", comment: "")
			static let testPendingContactJournal = NSLocalizedString("ExposureSubmissionResult_pcrTestPendingContactJournal", comment: "")
			static let testPendingContactJournalDesc = NSLocalizedString("ExposureSubmissionResult_pcrTestPendingContactJournalDesc", comment: "")

		}
		
		enum Antigen {
			static let title = NSLocalizedString("ExposureSubmissionResult_Title_Antigen", comment: "")
			static let card_positive = NSLocalizedString("ExposureSubmissionResult_CardPositive_Antigen", comment: "")
			static let card_negative = NSLocalizedString("ExposureSubmissionResult_CardNegative_Antigen", comment: "")
			static let card_subtitle = NSLocalizedString("ExposureSubmissionResult_CardSubTitle_Antigen", comment: "")
			static let testPending = NSLocalizedString("ExposureSubmissionResult_antigenTestPending", comment: "")
			static let testPendingDesc = NSLocalizedString("ExposureSubmissionResult_antigenTestPendingDesc", comment: "")
			static let testPendingContactJournal = NSLocalizedString("ExposureSubmissionResult_antigenTestPendingContactJournal", comment: "")
			static let testPendingContactJournalDesc = NSLocalizedString("ExposureSubmissionResult_antigenTestPendingContactJournalDesc", comment: "")
			static let testNegativeDesc = NSLocalizedString("ExposureSubmissionResult_antigenTestNegativDesc", comment: "")
			static let testAdded = NSLocalizedString("ExposureSubmissionResult_antigenTestAdded", comment: "")
			static let testAddedDesc = NSLocalizedString("ExposureSubmissionResult_antigenTestAddedDesc", comment: "")
			static let personBirthdayPrefix = NSLocalizedString("ExposureSubmissionResult_Person_Birthday_Prefix", comment: "")
			static let registrationDate = NSLocalizedString("ExposureSubmissionResult_RegistrationDate_Antigen", comment: "")
			static let registrationDateSuffix = NSLocalizedString("ExposureSubmissionResult_RegistrationDate_Suffix_Antigen", comment: "")
			static let hoursAbbreviation = NSLocalizedString("ExposureSubmissionResult_Abbreviation_Hours", comment: "")
			static let minutesAbbreviation = NSLocalizedString("ExposureSubmissionResult_Abbreviation_Minutes", comment: "")
			static let secondsAbbreviation = NSLocalizedString("ExposureSubmissionResult_Abbreviation_Seconds", comment: "")
			static let timerTitle = NSLocalizedString("ExposureSubmissionResult_Timer_Title", comment: "")
			static let proofTitle = NSLocalizedString("ExposureSubmissionResult_Negative_Antigen_Proof_Title", comment: "")
			static let proofDesc = NSLocalizedString("ExposureSubmissionResult_Negative_Antigen_Proof_Desc", comment: "")
			static let noProofTitle = NSLocalizedString("ExposureSubmissionResult_Negative_Antigen_NoProof_Title", comment: "")
			static let noProofDesc = NSLocalizedString("ExposureSubmissionResult_Negative_Antigen_NoProof_Desc", comment: "")
			static let testCenterNotSupportedTitle = NSLocalizedString("ExposureSubmissionResult_testCertificate_testCenterNotSupported", comment: "")
		}
		static let testCertificatePending = NSLocalizedString("ExposureSubmissionResult_testCertificate_Pending", comment: "")
		static let testCertificateNotRequested = NSLocalizedString("ExposureSubmissionResult_testCertificate_NotRequested", comment: "")
		static let testCertificateAvailableInTheTab = NSLocalizedString("ExposureSubmissionResult_testCertificate_AvailableInTab", comment: "")

		static let testCertificateTitle = NSLocalizedString("ExposureSubmissionResult_testCertificate_title", comment: "")

		static let card_title = NSLocalizedString("ExposureSubmissionResult_CardTitle", comment: "")
		static let card_invalid = NSLocalizedString("ExposureSubmissionResult_CardInvalid", comment: "")
		static let card_pending = NSLocalizedString("ExposureSubmissionResult_CardPending", comment: "")
		static let procedure = NSLocalizedString("ExposureSubmissionResult_Procedure", comment: "")
		static let warnOthers = NSLocalizedString("ExposureSubmissionResult_warnOthers", comment: "")
		static let testNegative = NSLocalizedString("ExposureSubmissionResult_testNegative", comment: "")
		static let testNegativeDesc = NSLocalizedString("ExposureSubmissionResult_testNegativeDesc", comment: "")
		static let testInvalid = NSLocalizedString("ExposureSubmissionResult_testInvalid", comment: "")
		static let testInvalidDesc = NSLocalizedString("ExposureSubmissionResult_testInvalidDesc", comment: "")
		static let testExpired = NSLocalizedString("ExposureSubmissionResult_testExpired", comment: "")
		static let testExpiredDesc = NSLocalizedString("ExposureSubmissionResult_testExpiredDesc", comment: "")
		static let warnOthersConsentGiven = NSLocalizedString("ExposureSubmissionResult_WarnOthersConsentGiven", comment: "")
		static let warnOthersConsentNotGiven = NSLocalizedString("ExposureSubmissionResult_WarnOthersConsentNotGiven", comment: "")
		static let testRemove = NSLocalizedString("ExposureSubmissionResult_testRemove", comment: "")
		static let testRemoveDesc = NSLocalizedString("ExposureSubmissionResult_testRemoveDesc", comment: "")
		static let warnOthersDesc = NSLocalizedString("ExposureSubmissionResult_warnOthersDesc", comment: "")
		static let primaryButtonTitle = NSLocalizedString("ExposureSubmissionResult_primaryButtonTitle", comment: "")
		static let secondaryButtonTitle = NSLocalizedString("ExposureSubmissionResult_secondaryButtonTitle", comment: "")
		static let deleteButton = NSLocalizedString("ExposureSubmissionResult_deleteButton", comment: "")
		static let refreshButton = NSLocalizedString("ExposureSubmissionResult_refreshButton", comment: "")
		static let furtherInfos_Title = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_title", comment: "")
		static let furtherInfos_ListItem1 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem1", comment: "")
		static let furtherInfos_ListItem2 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem2", comment: "")
		static let furtherInfos_ListItem3 = NSLocalizedString("ExposureSubmissionResult_testNegative_furtherInfos_listItem3", comment: "")
		static let furtherInfos_TestAgain = NSLocalizedString("ExposureSubmissionResult_furtherInfos_hint_testAgain", comment: "")
		static let removeAlert_Title = NSLocalizedString("ExposureSubmissionResult_RemoveAlert_Title", comment: "")
		static let removeAlert_Text = NSLocalizedString("ExposureSubmissionResult_RemoveAlert_Text", comment: "")
		static let removeAlert_ConfirmButtonTitle = NSLocalizedString("ExposureSubmissionResult_RemoveAlert_ConfirmButtonTitle", comment: "")
		static let registrationDateUnknown = NSLocalizedString("ExposureSubmissionResult_RegistrationDateUnknown", comment: "")
	}

	enum ExposureSubmissionDispatch {
		static let title = NSLocalizedString("ExposureSubmission_DispatchTitle", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionIntroduction_AccImageDescription", comment: "")
		static let description = NSLocalizedString("ExposureSubmission_DispatchDescription", comment: "")
		static let sectionHeadline = NSLocalizedString("ExposureSubmission_DispatchSectionHeadline", comment: "")
		static let sectionHeadline2 = NSLocalizedString("ExposureSubmission_DispatchSectionHeadline2", comment: "")
		static let qrCodeButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_QRCodeButtonTitle", comment: "")
		static let qrCodeButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_QRCodeButtonDescription", comment: "")
		static let tanButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_TANButtonTitle", comment: "")
		static let tanButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_TANButtonDescription", comment: "")
		static let hotlineButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_HotlineButtonTitle", comment: "")
		static let hotlineButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_HotlineButtonDescription", comment: "")
		static let findTestCentersButtonTitle = NSLocalizedString("ExposureSubmissionDispatch_FindTestCentersTitle", comment: "")
		static let findTestCentersButtonDescription = NSLocalizedString("ExposureSubmissionDispatch_FindTestCentersDescription", comment: "")
	}

	enum ExposureSubmissionQRInfo {
		static let title = NSLocalizedString("ExposureSubmissionQRInfo_title", comment: "")
		static let imageDescription = NSLocalizedString("ExposureSubmissionQRInfo_imageDescription", comment: "")
		static let titleDescription = NSLocalizedString("ExposureSubmissionQRInfo_title_description", comment: "")
		static let headerSection1 = NSLocalizedString("ExposureSubmissionQRInfo_header_section_1", comment: "")
		static let instruction1 = NSLocalizedString("ExposureSubmissionQRInfo_instruction1", comment: "")
		static let instruction2 = NSLocalizedString("ExposureSubmissionQRInfo_instruction2", comment: "")
		static let instruction2a = NSLocalizedString("ExposureSubmissionQRInfo_instruction2a", comment: "")
		static let instruction3 = NSLocalizedString("ExposureSubmissionQRInfo_instruction3", comment: "")
		static let instruction3HighlightedPhrase = NSLocalizedString("ExposureSubmissionQRInfo_instruction3_highlightedPhrase", comment: "")
		static let headerSection2 = NSLocalizedString("ExposureSubmissionQRInfo_header_section_2", comment: "")
		static let bodySection2 = NSLocalizedString("ExposureSubmissionQRInfo_body_section_2", comment: "")
		static let bodySection3 = NSLocalizedString("ExposureSubmissionQRInfo_body_section_3", comment: "")
		static let acknowledgementTitle = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_title", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBody = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_body", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBullet1_1 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_Bullet1_1", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBullet1_2 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_Bullet1_2", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBullet2 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_Bullet2", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBullet3 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_Bullet3", tableName: "Localizable.legal", comment: "")
		static let acknowledgementWithdrawConsent = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_legal_WithdrawConsent", tableName: "Localizable.legal", comment: "")
		
		
		static let acknowledgement3 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_3", comment: "")
		static let acknowledgement4 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_4", comment: "")
		static let acknowledgement5 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_5", comment: "")
		static let acknowledgement6 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_6", comment: "")
		static let acknowledgement7 = NSLocalizedString("ExposureSubmissionQRInfo_acknowledgement_7", comment: "")
		static let primaryButtonTitle = NSLocalizedString("ExposureSubmissionQRInfo_primaryButtonTitle", comment: "")
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
		static let phoneNumberDomestic = NSLocalizedString("ExposureSubmission_PhoneNumberDomestic", comment: "")
		static let phoneDetailsDomestic = NSLocalizedString("ExposureSubmission_PhoneDetailsDomestic", comment: "")
		static let phoneNumberForeign = NSLocalizedString("ExposureSubmission_PhoneNumberForeign", comment: "")
		static let phoneDetailsForeign = NSLocalizedString("ExposureSubmission_PhoneDetailsForeign", comment: "")
		static let hotlineDetailDescription = NSLocalizedString("ExposureSubmission_PhoneDetailDescription", comment: "")
		static let imageDescription = NSLocalizedString("ExposureSubmissionHotline_imageDescription", comment: "")
	}
	
	enum ExposureSubmissionPositiveTestResult {
		static let noConsentTitle = NSLocalizedString("TestResultPositive_NoConsent_Title", comment: "")
		static let noConsentInfo1 = NSLocalizedString("TestResultPositive_NoConsent_Info1", comment: "")
		static let noConsentInfo2 = NSLocalizedString("TestResultPositive_NoConsent_Info2", comment: "")
		static let noConsentInfo3 = NSLocalizedString("TestResultPositive_NoConsent_Info3", comment: "")
		static let noConsentPrimaryButtonTitle = NSLocalizedString("TestResultPositive_NoConsent_PrimaryButton", comment: "")
		static let noConsentSecondaryButtonTitle = NSLocalizedString("TestResultPositive_NoConsent_SecondaryButton", comment: "")

		static let noConsentAlertTitle = NSLocalizedString("TestResultPositive_NoConsent_AlertNotWarnOthers_Title", comment: "")
		static let noConsentAlertDescription = NSLocalizedString("TestResultPositive_NoConsent_AlertNotWarnOthers_Description", comment: "")
		static let noConsentAlertButtonDontWarn = NSLocalizedString("TestResultPositive_NoConsent_AlertNotWarnOthers_ButtonOne", comment: "")
		static let noConsentAlertButtonWarn = NSLocalizedString("TestResultPositive_NoConsent_AlertNotWarnOthers_ButtonTwo", comment: "")

		static let withConsentTitle = NSLocalizedString("TestResultPositive_WithConsent_Title", comment: "")
		static let withConsentInfo1 = NSLocalizedString("TestResultPositive_WithConsent_Info1", comment: "")
		static let withConsentInfo2 = NSLocalizedString("TestResultPositive_WithConsent_Info2", comment: "")
		static let withConsentPrimaryButtonTitle = NSLocalizedString("TestResultPositive_WithConsent_PrimaryButton", comment: "")
		static let withConsentSecondaryButtonTitle = NSLocalizedString("TestResultPositive_WithConsent_SecondaryButton", comment: "")

		static let keysSubmittedDescription = NSLocalizedString("TestResultPositive_KeysSubmitted_Description", comment: "")
		static let keysSubmittedTitle1 = NSLocalizedString("TestResultPositive_KeysSubmitted_Title1", comment: "")
		static let keysSubmittedInfo1 = NSLocalizedString("TestResultPositive_KeysSubmitted_Info1", comment: "")
		static let keysSubmittedInfo2 = NSLocalizedString("TestResultPositive_KeysSubmitted_Info2", comment: "")
		static let keysSubmittedInfo3 = NSLocalizedString("TestResultPositive_KeysSubmitted_Info3", comment: "")
		static let keysSubmittedTitle2 = NSLocalizedString("TestResultPositive_KeysSubmitted_Title2", comment: "")
		static let keysSubmittedFurtherInfo1 = NSLocalizedString("TestResultPositive_KeysSubmitted_FurtherInfo1", comment: "")
		static let keysSubmittedFurtherInfo2 = NSLocalizedString("TestResultPositive_KeysSubmitted_FurtherInfo2", comment: "")
		static let keysSubmittedFurtherInfo3 = NSLocalizedString("TestResultPositive_KeysSubmitted_FurtherInfo3", comment: "")
		static let keysSubmittedFurtherInfo4 = NSLocalizedString("TestResultPositive_KeysSubmitted_FurtherInfo4", comment: "")
		static let keysSubmittedPrimaryButtonTitle = NSLocalizedString("TestResultPositive_KeysSubmitted_PrimaryButton", comment: "")
	}

	enum ExposureSubmissionSymptoms {
		static let title = NSLocalizedString("ExposureSubmissionSymptoms_Title", comment: "")
		static let introduction = NSLocalizedString("ExposureSubmissionSymptoms_Introduction", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionSymptoms_Description", comment: "")
		static let symptoms = [
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom0", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom1", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom2", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom3", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom4", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom5", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom6", comment: ""),
			NSLocalizedString("ExposureSubmissionSymptoms_Symptom7", comment: "")
		]
		static let answerOptionYes = NSLocalizedString("ExposureSubmissionSymptoms_AnswerOptionYes", comment: "")
		static let answerOptionNo = NSLocalizedString("ExposureSubmissionSymptoms_AnswerOptionNo", comment: "")
		static let answerOptionPreferNotToSay = NSLocalizedString("ExposureSubmissionSymptoms_AnswerOptionPreferNotToSay", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionSymptoms_ContinueButton", comment: "")
		static let doneButton = NSLocalizedString("ExposureSubmissionSymptoms_DoneButton", comment: "")

	}
	
	enum ExposureSubmissionSymptomsOnset {
		static let title = NSLocalizedString("ExposureSubmissionSymptomsOnset_Title", comment: "")
		static let subtitle = NSLocalizedString("ExposureSubmissionSymptomsOnset_Subtitle", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionSymptomsOnset_Description", comment: "")
		static let datePickerTitle = NSLocalizedString("ExposureSubmissionSymptomsOnset_DatePickerTitle", comment: "")
		static let answerOptionLastSevenDays = NSLocalizedString("ExposureSubmissionSymptomsOnset_AnswerOptionLastSevenDays", comment: "")
		static let answerOptionOneToTwoWeeksAgo = NSLocalizedString("ExposureSubmissionSymptomsOnset_AnswerOptionOneToTwoWeeksAgo", comment: "")
		static let answerOptionMoreThanTwoWeeksAgo = NSLocalizedString("ExposureSubmissionSymptomsOnset_AnswerOptionMoreThanTwoWeeksAgo", comment: "")
		static let answerOptionPreferNotToSay = NSLocalizedString("ExposureSubmissionSymptomsOnset_AnswerOptionPreferNotToSay", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionSymptomsOnset_ContinueButton", comment: "")
	}
	
	enum ExposureSubmissionSymptomsCancelAlert {
		static let title = NSLocalizedString("ExposureSubmissionSymptoms_CancelAlertTitle", comment: "")
		static let message = NSLocalizedString("ExposureSubmissionSymptoms_CancelAlertMessage", comment: "")
		static let cancelButton = NSLocalizedString("ExposureSubmissionSymptoms_CancelAlertButtonCancel", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionSymptoms_CancelAlertButtonContinue", comment: "")
	}
	
	enum ExposureSubmissionWarnOthers {
		static let title = NSLocalizedString("ExposureSubmissionWarnOthers_title", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionWarnOthers_AccImageDescription", comment: "")
		static let continueButton = NSLocalizedString("ExposureSubmissionWarnOthers_continueButton", comment: "")
		static let sectionTitle = NSLocalizedString("ExposureSubmissionWarnOthers_sectionTitle", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionWarnOthers_description", comment: "")
		static let supportedCountriesTitle = NSLocalizedString("ExposureSubmissionWarnOthers_supportedCountriesTitle", comment: "")
		
		static let acknowledgementTitle = NSLocalizedString("ExposureSubmissionWarnOthers_acknowledgementTitle", tableName: "Localizable.legal", comment: "")
		static let acknowledgementBody = NSLocalizedString("ExposureSubmissionWarnOthers_acknowledgementBody", tableName: "Localizable.legal", comment: "")
		static let acknowledgement_1_1 = NSLocalizedString("ExposureSubmissionWarnOthers_acknowledgement_1_1", tableName: "Localizable.legal", comment: "")
		static let acknowledgement_1_2 = NSLocalizedString("ExposureSubmissionWarnOthers_acknowledgement_1_2", tableName: "Localizable.legal", comment: "")
		static let acknowledgement_footer = NSLocalizedString("ExposureSubmissionWarnOthers_acknowledgement_footer", tableName: "Localizable.legal", comment: "")
		
		static let consent_bullet1 = NSLocalizedString("ExposureSubmissionWarnOthers_consent_bullet1", comment: "")
		static let consent_bullet2 = NSLocalizedString("ExposureSubmissionWarnOthers_consent_bullet2", comment: "")
		static let consent_bullet3 = NSLocalizedString("ExposureSubmissionWarnOthers_consent_bullet3", comment: "")
		static let consent_bullet4 = NSLocalizedString("ExposureSubmissionWarnOthers_consent_bullet4", comment: "")
		static let consent_bullet5 = NSLocalizedString("ExposureSubmissionWarnOthers_consent_bullet5", comment: "")
	}

	enum ExposureSubmissionSuccess {
		static let title = NSLocalizedString("ExposureSubmissionSuccess_Title", comment: "")
		static let accImageDescription = NSLocalizedString("ExposureSubmissionSuccess_AccImageDescription", comment: "")
		static let button = NSLocalizedString("ExposureSubmissionSuccess_Button", comment: "")
		static let description = NSLocalizedString("ExposureSubmissionSuccess_Description", comment: "")
		static let listTitle = NSLocalizedString("ExposureSubmissionSuccess_listTitle", comment: "")
		static let listItem0 = NSLocalizedString("ExposureSubmissionSuccess_listItem0", comment: "")
		static let listItem1 = NSLocalizedString("ExposureSubmissionSuccess_listItem1", comment: "")
		static let listItem2 = NSLocalizedString("ExposureSubmissionSuccess_listItem2", comment: "")
		static let subTitle = NSLocalizedString("ExposureSubmissionSuccess_subTitle", comment: "")
		static let listItem2_1 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_1", comment: "")
		static let listItem2_2 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_2", comment: "")
		static let listItem2_3 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_3", comment: "")
		static let listItem2_4 = NSLocalizedString("ExposureSubmissionSuccess_listItem2_4", comment: "")
	}

	enum ExposureSubmissionError {
		static let noKeysCollected = NSLocalizedString("ExposureSubmissionError_NoKeys", comment: "")
		static let invalidTan = NSLocalizedString("ExposureSubmissionError_InvalidTan", comment: "")
		static let enNotEnabled = NSLocalizedString("ExposureSubmissionError_EnNotEnabled", comment: "")
		static let noRegistrationToken = NSLocalizedString("ExposureSubmissionError_NoRegistrationToken", comment: "")
		static let invalidResponse = NSLocalizedString("ExposureSubmissionError_InvalidResponse", comment: "")
		static let noResponse = NSLocalizedString("ExposureSubmissionError_NoResponse", comment: "")
		static let noNetworkConnection = NSLocalizedString("ExposureNotificationSetting_EU_Empty_Error_Desc", comment: "")
		static let teleTanAlreadyUsed = NSLocalizedString("ExposureSubmissionError_TeleTanAlreadyUsed", comment: "")
		static let qrAlreadyUsed = NSLocalizedString("ExposureSubmissionError_QRAlreadyUsed", comment: "")
		static let qrAlreadyUsedTitle = NSLocalizedString("ExposureSubmissionError_QRAlreadyUsed_Title", comment: "")
		static let qrNotExist = NSLocalizedString("ExposureSubmissionError_QRNotExist", comment: "")
		static let qrNotExistTitle = NSLocalizedString("ExposureSubmissionError_QRNotExist_Title", comment: "")
		static let regTokenNotExist = NSLocalizedString("ExposureSubmissionError_RegTokenNotExist", comment: "")
		static let other = NSLocalizedString("ExposureSubmissionError_other", comment: "")
		static let otherend = NSLocalizedString("ExposureSubmissionError_otherend", comment: "")
		static let httpError = NSLocalizedString("ExposureSubmissionError_httpError", comment: "")
		static let notAuthorized = NSLocalizedString("ExposureSubmissionError_declined", comment: "")
		static let unknown = NSLocalizedString("ExposureSubmissionError_unknown", comment: "")
		static let defaultError = NSLocalizedString("ExposureSubmissionError_defaultError", comment: "")
		static let noAppConfiguration = NSLocalizedString("ExposureSubmissionError_noAppConfiguration", comment: "")
		static let errorPrefix = NSLocalizedString("ExposureSubmissionError_ErrorPrefix", comment: "")
	}

	enum ExposureDetection {
		static let off = NSLocalizedString("ExposureDetection_Off", comment: "")
		static let unknown = NSLocalizedString("ExposureDetection_Unknown", comment: "")
		static let low = NSLocalizedString("ExposureDetection_Low", comment: "")
		static let lowColorName = NSLocalizedString("ExposureDetection_Low_Green_Color", comment: "")
		static let high = NSLocalizedString("ExposureDetection_High", comment: "")
		static let highColorName = NSLocalizedString("ExposureDetection_High_Red_Color", comment: "")
		static let daysSinceInstallation = NSLocalizedString("Home_Risk_Days_Since_Installation_Title", comment: "")
		
		static let lastExposure = NSLocalizedString("ExposureDetection_LastExposure", comment: "")
		static let lastExposureOneRiskDay = NSLocalizedString("ExposureDetection_LastExposure_One_Risk_Day", comment: "")
		static let refreshed = NSLocalizedString("ExposureDetection_Refreshed", comment: "")
		static let refreshedNever = NSLocalizedString("ExposureDetection_Refreshed_Never", comment: "")
		static let refreshingIn = NSLocalizedString("ExposureDetection_RefreshingIn", comment: "")
		static let refreshIn = NSLocalizedString("ExposureDetection_RefreshIn", comment: "")
		static let lastRiskLevel = NSLocalizedString("ExposureDetection_LastRiskLevel", comment: "")
		static let offText = NSLocalizedString("ExposureDetection_OffText", comment: "")
		static let outdatedText = NSLocalizedString("ExposureDetection_OutdatedText", comment: "")
		static let unknownText = NSLocalizedString("ExposureDetection_UnknownText", comment: "")
		static let loadingText = NSLocalizedString("ExposureDetection_LoadingText", comment: "")
		
		static let contactJournalText = NSLocalizedString("ExposureDetection_Contact_Journal_Text", comment: "")
		static let contactJournalTextP2 = NSLocalizedString("ExposureDetection_Contact_Journal_Text_P2", comment: "")

		static let behaviorTitle = NSLocalizedString("ExposureDetection_Behavior_Title", comment: "")
		static let behaviorSubtitle = NSLocalizedString("ExposureDetection_Behavior_Subtitle", comment: "")
		static let lowRiskBehaviorSubtitle = NSLocalizedString("ExposureDetection_LowRisk_Behavior_Subtitle", comment: "")

		static let guideVaccination = NSLocalizedString("ExposureDetection_Guide_Vaccination", comment: "")
		static let guideHands = NSLocalizedString("ExposureDetection_Guide_Hands", comment: "")
		static let guideMask = NSLocalizedString("ExposureDetection_Guide_Mask", comment: "")
		static let guideDistance = NSLocalizedString("ExposureDetection_Guide_Distance", comment: "")
		static let guideSneeze = NSLocalizedString("ExposureDetection_Guide_Sneeze", comment: "")
		static let guideVentilation = NSLocalizedString("ExposureDetection_Guide_Ventilation", comment: "")
		static let guideSymptoms = NSLocalizedString("ExposureDetection_Guide_Symptoms", comment: "")
		static let guideHygiene = NSLocalizedString("ExposureDetection_Guide_Hygiene", comment: "")
		static let guideHome = NSLocalizedString("ExposureDetection_Guide_Home", comment: "")
		static let guideHotline = NSLocalizedString("ExposureDetection_Guide_Hotline", comment: "")
		static let guideVaccinationHighRisk = NSLocalizedString("ExposureDetection_Guide_Vaccination_HighRisk", comment: "")
		static let guideTitle = NSLocalizedString("ExposureDetection_Guide_Title", comment: "Placeholder points to `ExposureDetection_Title`")
		static let guidePoint1 = NSLocalizedString("ExposureDetection_Guide_Point1", comment: "Placeholder points to `ExposureDetection_Point1`")
		static let guidePoint1LinkText = NSLocalizedString("ExposureDetection_Guide_Point1_LinkText", comment: "Placeholder points to `ExposureDetection_LinkText1`")
		static let guidePoint2 = NSLocalizedString("ExposureDetection_Guide_Point2", comment: "Placeholder points to `ExposureDetection_Point2`")
		static let guidePoint2LinkText = NSLocalizedString("ExposureDetection_Guide_Point2_LinkText", comment: "Placeholder points to `ExposureDetection_LinkText2`")
		static let tracingTitle = NSLocalizedString("ExposureDetection_ActiveTracingSection_Title", comment: "")
		static let tracingSubTitle = NSLocalizedString("ExposureDetection_ActiveTracingSection_Subtitle", comment: "")
		static let tracingParagraph0 = NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph0", comment: "")
		static let tracingParagraph1a = NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph1a", comment: "")
		static let tracingParagraph1b = NSLocalizedString("ExposureDetection_ActiveTracingSection_Text_Paragraph1b", comment: "")
		
		static let explanationTitle = NSLocalizedString("ExposureDetection_Explanation_Title", comment: "")
		static let explanationSubtitle = NSLocalizedString("ExposureDetection_Explanation_Subtitle", comment: "")
		static let explanationTextOff = NSLocalizedString("ExposureDetection_Explanation_Text_Off", comment: "")
		static let explanationTextOutdated = NSLocalizedString("ExposureDetection_Explanation_Text_Outdated", comment: "")
		static let explanationTextUnknown = NSLocalizedString("ExposureDetection_Explanation_Text_Unknown", comment: "")
		static let explanationTextLowNoEncounter = NSLocalizedString("ExposureDetection_Explanation_Text_Low_No_Encounter", comment: "")
		static let explanationTextLowWithEncounter = NSLocalizedString("ExposureDetection_Explanation_Text_Low_With_Encounter", comment: "")
		static let explanationTextLowWithEncounterFAQ = NSLocalizedString("ExposureDetection_Explanation_Text_Low_With_Encounter_FAQ", comment: "")
		static let explanationTextHigh = NSLocalizedString("ExposureDetection_Explanation_Text_High", comment: "")
		static let explanationTextHighDateOfLastExposure = NSLocalizedString("ExposureDetection_Explanation_Text_High_DateOfLastExposure", comment: "")
		static let lowRiskExposureTitle = NSLocalizedString("ExposureDetection_LowRiskExposure_Title", comment: "")
		static let lowRiskExposureSubtitle = NSLocalizedString("ExposureDetection_LowRiskExposure_Subtitle", comment: "")
		static let lowRiskExposureBody = NSLocalizedString("ExposureDetection_LowRiskExposure_Body", comment: "")

		static let buttonEnable = NSLocalizedString("ExposureDetection_Button_Enable", comment: "")
		static let buttonRefresh = NSLocalizedString("ExposureDetection_Button_Refresh", comment: "")
		static let buttonTitleRestart = NSLocalizedString("ExposureDetection_Button_Title_Restart", comment: "")

		static let riskCardStatusDownloadingTitle = NSLocalizedString("ExposureDetection_Risk_Status_Downloading_Title", comment: "")
		static let riskCardStatusDownloadingBody = NSLocalizedString("ExposureDetection_Risk_Status_Downloading_Body", comment: "")
		static let riskCardStatusDetectingTitle = NSLocalizedString("ExposureDetection_Risk_Status_Detecting_Title", comment: "")
		static let riskCardStatusDetectingBody = NSLocalizedString("ExposureDetection_Risk_Status_Detecting_Body", comment: "")

		static let riskCardFailedCalculationTitle = NSLocalizedString("ExposureDetection_Risk_Failed_Title", comment: "")
		static let riskCardFailedCalculationBody = NSLocalizedString("ExposureDetection_Risk_Failed_Body", comment: "")
		static let riskCardFailedCalculationRestartButtonTitle = NSLocalizedString("ExposureDetection_Risk_Restart_Button_Title", comment: "")

		static let surveyCardTitle = NSLocalizedString("ExposureDetection_Survey_Card_Title", comment: "")
		static let surveyCardBody = NSLocalizedString("ExposureDetection_Survey_Card_Body", comment: "")
		static let surveyCardButton = NSLocalizedString("ExposureDetection_Survey_Card_Button", comment: "")
		
		static let hygieneRulesTitle = NSLocalizedString("ExposureDetection_Info_HygieneRules_Title", comment: "")
		static let hygieneRulesPoint1 = NSLocalizedString("ExposureDetection_Info_HygieneRules_Point1", comment: "")
		static let hygieneRulesPoint2 = NSLocalizedString("ExposureDetection_Info_HygieneRules_Point2", comment: "")
		static let hygieneRulesPoint3 = NSLocalizedString("ExposureDetection_Info_HygieneRules_Point3", comment: "")
		static let hygieneRulesPoint4 = NSLocalizedString("ExposureDetection_Info_HygieneRules_Point4", comment: "")
		static let hygieneRulesPoint5 = NSLocalizedString("ExposureDetection_Info_HygieneRules_Point5", comment: "")
		static let hygieneRulesTitleImageDescription = NSLocalizedString("ExposureDetection_Info_HygieneRules_TitleImage_Description", comment: "")
		
		static let contagionTitle = NSLocalizedString("ExposureDetection_Info_Contagion_Title", comment: "")
		static let contagionImageTitle = NSLocalizedString("ExposureDetection_Info_Contagion_Image_Title", comment: "")
		static let contagionTitleImageDescription = NSLocalizedString("ExposureDetection_Info_Contagion_TitleImage_Description", comment: "")
		static let contagionPoint1 = NSLocalizedString("ExposureDetection_Info_Contagion_Point1", comment: "")
		static let contagionPoint2 = NSLocalizedString("ExposureDetection_Info_Contagion_Point2", comment: "")
		static let contagionPoint3 = NSLocalizedString("ExposureDetection_Info_Contagion_Point3", comment: "")
		static let contagionPoint4 = NSLocalizedString("ExposureDetection_Info_Contagion_Point4", comment: "")
		static let contagionPoint5 = NSLocalizedString("ExposureDetection_Info_Contagion_Point5", comment: "")
		static let contagionPoint6 = NSLocalizedString("ExposureDetection_Info_Contagion_Point6", comment: "")
		static let contagionPoint6LinkText = NSLocalizedString("ExposureDetection_Info_Contagion_Point6_LinkText", comment: "")
		static let contagionFooter = NSLocalizedString("ExposureDetection_Info_Contagion_Footer", comment: "")
		static let contagionFooterLinkText = NSLocalizedString("ExposureDetection_Info_Contagion_Footer_LinkText", comment: "")
	}

	enum SurveyConsent {
		static let imageDescription = NSLocalizedString("SurveyConsent_Image_Description", comment: "")
		static let title = NSLocalizedString("SurveyConsent_Title", comment: "")
		static let body1 = NSLocalizedString("SurveyConsent_Body1", comment: "")
		static let body2 = NSLocalizedString("SurveyConsent_Body2", comment: "")
		static let body3 = NSLocalizedString("SurveyConsent_Body3", comment: "")
		static let legalTitle = NSLocalizedString("SurveyConsent_LegalTitle_BoldText", tableName: "Localizable.legal", comment: "")
		static let legalBody1 = NSLocalizedString("SurveyConsent_LegalBody1", tableName: "Localizable.legal", comment: "")
		static let legalBody2 = NSLocalizedString("SurveyConsent_LegalBody2", tableName: "Localizable.legal", comment: "")
		static let legalBullet1 = NSLocalizedString("SurveyConsent_Legal_Bullet1", tableName: "Localizable.legal", comment: "")
		static let legalBullet2 = NSLocalizedString("SurveyConsent_Legal_Bullet2", tableName: "Localizable.legal", comment: "")
		static let legalBullet3 = NSLocalizedString("SurveyConsent_Legal_Bullet3", tableName: "Localizable.legal", comment: "")

		static let acceptButtonTitle = NSLocalizedString("SurveyConsent_Accept_Button_Title", comment: "")
		static let legalDetailsButtonTitle = NSLocalizedString("SurveyConsent_Legal_Details_Button_Title", tableName: "Localizable.legal", comment: "")
		
		// Errors
		static let errorTitle = NSLocalizedString("SurveyConsent_Error_Title", comment: "")
		static let errorTryAgainLater = NSLocalizedString("SurveyConsent_Error_TryAgainLater", comment: "")
		static let errorDeviceNotSupported = NSLocalizedString("SurveyConsent_Error_DeviceNotSupported", comment: "")
		static let errorChangeDeviceTime = NSLocalizedString("SurveyConsent_Error_ChangeDeviceTime", comment: "")
		static let errorTryAgainNextMonth = NSLocalizedString("SurveyConsent_Error_TryAgainNextMonth", comment: "")
		static let errorAlreadyParticipated = NSLocalizedString("SurveyConsent_Error_AlreadyParticipated", comment: "")

		static let surveyDetailsTitle = NSLocalizedString("SurveyConsent_Legal_Details_Title", comment: "")

		static let surveyDetailsLegalHeader = NSLocalizedString("SurveyConsent_Legal_Details_Headline", tableName: "Localizable.legal", comment: "")
		static let surveyDetailsLegalBody1 = NSLocalizedString("SurveyConsent_Details_Legal_Body1", tableName: "Localizable.legal", comment: "")
		static let surveyDetailsLegalBody2 = NSLocalizedString("SurveyConsent_Details_Legal_Body2", tableName: "Localizable.legal", comment: "")

		static let surveyDetailsHeader = NSLocalizedString("SurveyConsent_Details_Headline", comment: "")
		static let surveyDetailsBody = NSLocalizedString("SurveyConsent_Details_Body", comment: "")

	}

	enum ExposureDetectionError {
		static let errorAlertMessage = NSLocalizedString("ExposureDetectionError_Alert_Message", comment: "")
		static let errorAlertFullDistSpaceMessage = NSLocalizedString("ExposureDetectionError_Alert_FullDiskSpace_Message", comment: "")
		static let errorAlertWrongDeviceTime = NSLocalizedString("ExposureDetection_WrongTime_Notification_Popover_Body", comment: "")
	}

	enum Settings {
		static let trackingStatusActive = NSLocalizedString("Settings_KontaktProtokollStatusActive", comment: "")
		static let trackingStatusInactive = NSLocalizedString("Settings_KontaktProtokollStatusInactive", comment: "")

		static let statusEnable = NSLocalizedString("Settings_StatusEnable", comment: "")
		static let statusDisable = NSLocalizedString("Settings_StatusDisable", comment: "")

		static let notificationStatusActive = NSLocalizedString("Settings_Notification_StatusActive", comment: "")
		static let notificationStatusInactive = NSLocalizedString("Settings_Notification_StatusInactive", comment: "")
		
		static let backgroundAppRefreshStatusActive = NSLocalizedString("Settings_BackgroundAppRefresh_StatusActive", comment: "")
		static let backgroundAppRefreshStatusInactive = NSLocalizedString("Settings_BackgroundAppRefresh_StatusInactive", comment: "")

		static let tracingLabel = NSLocalizedString("Settings_Tracing_Label", comment: "")
		static let notificationLabel = NSLocalizedString("Settings_Notification_Label", comment: "")
		static let backgroundAppRefreshLabel = NSLocalizedString("Settings_BackgroundAppRefresh_Label", comment: "")
		static let resetLabel = NSLocalizedString("Settings_Reset_Label", comment: "")

		static let tracingDescription = NSLocalizedString("Settings_Tracing_Description", comment: "")
		static let notificationDescription = NSLocalizedString("Settings_Notification_Description", comment: "")
		static let backgroundAppRefreshDescription = NSLocalizedString("Settings_BackgroundAppRefresh_Description", comment: "")
		static let resetDescription = NSLocalizedString("Settings_Reset_Description", comment: "")

		static let navigationBarTitle = NSLocalizedString("Settings_NavTitle", comment: "")

		static let daysSinceInstallTitle = NSLocalizedString("Settings_DaysSinceInstall_Title", comment: "")
		static let daysSinceInstallSubTitle = NSLocalizedString("Settings_DaysSinceInstall_SubTitle", comment: "")
		static let daysSinceInstallP1 = NSLocalizedString("Settings_DaysSinceInstall_P1", comment: "")
		static let daysSinceInstallP2a = NSLocalizedString("Settings_DaysSinceInstall_P2a", comment: "")
		static let daysSinceInstallP2b = NSLocalizedString("Settings_DaysSinceInstall_P2b", comment: "")

		enum Datadonation {
			static let label = NSLocalizedString("Settings_DataDonation_Label", comment: "")
			static let description = NSLocalizedString("Settings_DataDonation_Description", comment: "")
			static let statusActive = NSLocalizedString("Settings_DataDonation_StatusActive", comment: "")
			static let statusInactive = NSLocalizedString("Settings_DataDonation_StatusInactive", comment: "")
		}

	}

	enum NotificationSettings {
		static let title = NSLocalizedString("NotificationSettings_Title", comment: "")
		static let imageDescriptionOn = NSLocalizedString("NotificationSettings_ImageDescriptionOn", comment: "")
		static let imageDescriptionOff = NSLocalizedString("NotificationSettings_ImageDescriptionOff", comment: "")
		static let settingsDescription = NSLocalizedString("NotificationSettings_SettingsDescription", comment: "")
		static let notifications = NSLocalizedString("NotificationSettings_Notifications", comment: "")
		static let notificationsOn = NSLocalizedString("NotificationSettings_NotificationsOn", comment: "")
		static let notificationsOff = NSLocalizedString("NotificationSettings_NotificationsOff", comment: "")
		
		static let bulletHeadlineOn = NSLocalizedString("NotificationSettings_BulletHeadlineOn", comment: "")
		static let bulletHeadlineOff = NSLocalizedString("NotificationSettings_BulletHeadlineOff", comment: "")
		static let bulletDescOn = NSLocalizedString("NotificationSettings_BulletDescOn", comment: "")
		static let bulletDescOff = NSLocalizedString("NotificationSettings_BulletDescOff", comment: "")
		
		static let bulletPoint1 = NSLocalizedString("NotificationSettings_BulletPoint1", comment: "")
		static let bulletPoint2 = NSLocalizedString("NotificationSettings_BulletPoint2", comment: "")
		static let bulletPoint3 = NSLocalizedString("NotificationSettings_BulletPoint3", comment: "")
		static let bulletDesc2 = NSLocalizedString("NotificationSettings_BulletDesc2", comment: "")
		static let bulletDesc2FAQText = NSLocalizedString("NotificationSettings_BulletDesc2_FAQText", comment: "")
		
		static let openSystemSettings = NSLocalizedString("NotificationSettings_OpenSystemSettings", comment: "")
		
		enum DeltaOnboarding {
			static let title = NSLocalizedString("NotificationSettings_DeltaOnboarding_Title", comment: "")
			static let description = NSLocalizedString("NotificationSettings_DeltaOnboarding_Description", comment: "")
			static let primaryButtonTitle = NSLocalizedString("NotificationSettings_DeltaOnboarding_PrimaryButtonTitle", comment: "")
		}
	}

	enum BackgroundAppRefreshSettings {
		static let title = NSLocalizedString("BackgroundAppRefreshSettings_Title", comment: "")
		static let subtitle = NSLocalizedString("BackgroundAppRefreshSettings_Subtitle", comment: "")
		static let description = NSLocalizedString("BackgroundAppRefreshSettings_Description", comment: "")
		static let onImageDescription = NSLocalizedString("BackgroundAppRefreshSettings_Image_Description_On", comment: "")
		static let offImageDescription = NSLocalizedString("BackgroundAppRefreshSettings_Image_Description_Off", comment: "")
		
		enum Status {
			static let header = NSLocalizedString("BackgroundAppRefreshSettings_Status_Header", comment: "")
			static let title = NSLocalizedString("BackgroundAppRefreshSettings_Status_Title", comment: "")
			static let on = NSLocalizedString("BackgroundAppRefreshSettings_Status_On", comment: "")
			static let off = NSLocalizedString("BackgroundAppRefreshSettings_Status_Off", comment: "")
		}

		enum InfoBox {
			static let title = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_Title", comment: "")
			static let description = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_Description", comment: "")
			static let lowPowerModeDescription = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_LowPowerMode_Description", comment: "")

			enum LowPowerModeInstruction {
				static let title = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_LowPowerModeInstruction_Title", comment: "")
				static let step1 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_LowPowerModeInstruction_Step1", comment: "")
				static let step2 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_LowPowerModeInstruction_Step2", comment: "")
				static let step3 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_LowPowerModeInstruction_Step3", comment: "")
			}

			enum SystemBackgroundRefreshInstruction {
				static let title = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_SystemBackgroundRefreshInstruction_Title", comment: "")
				static let step1 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_SystemBackgroundRefreshInstruction_Step1", comment: "")
				static let step2 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_SystemBackgroundRefreshInstruction_Step2", comment: "")
				static let step3 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_SystemBackgroundRefreshInstruction_Step3", comment: "")
				static let step4 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_SystemBackgroundRefreshInstruction_Step4", comment: "")
			}

			enum AppBackgroundRefreshInstruction {
				static let title = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_AppBackgroundRefreshInstruction_Title", comment: "")
				static let step1 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_AppBackgroundRefreshInstruction_Step1", comment: "")
				static let step2 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_AppBackgroundRefreshInstruction_Step2", comment: "")
				static let step3 = NSLocalizedString("BackgroundAppRefreshSettings_InfoBox_AppBackgroundRefreshInstruction_Step3", comment: "")
			}
		}

		static let openSettingsButtonTitle = NSLocalizedString("BackgroundAppRefreshSettings_OpenSettingsButton_Title", comment: "")
		static let shareButtonTitle = NSLocalizedString("BackgroundAppRefreshSettings_ShareButton_Title", comment: "")
	}

	enum Onboarding {
		static let onboardingLetsGo = NSLocalizedString("Onboarding_LetsGo_actionText", comment: "")
		static let onboardingContinue = NSLocalizedString("Onboarding_Continue_actionText", comment: "")
		static let onboardingContinueDescription = NSLocalizedString("Onboarding_Continue_actionTextHint", comment: "")
		static let onboardingDoNotActivate = NSLocalizedString("Onboarding_DoNotActivate_actionText", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_title = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_title", comment: "")
		static let onboarding_deactivate_exposure_notif_confirmation_message = NSLocalizedString("Onboarding_DeactivateExposureConfirmation_message", comment: "")

		static let onboardingInfo_togetherAgainstCoronaPage_imageDescription = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_imageDescription", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_title = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_title", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_boldText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_boldText", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_normalText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_normalText", comment: "")
		static let onboardingInfo_togetherAgainstCoronaPage_link = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_link", tableName: "Localizable.links", comment: "URL")
		static let onboardingInfo_togetherAgainstCoronaPage_linkText = NSLocalizedString("OnboardingInfo_togetherAgainstCoronaPage_linkText", comment: "")
		static let onboardingInfo_privacyPage_imageDescription = NSLocalizedString("OnboardingInfo_privacyPage_imageDescription", comment: "")
		static let onboardingInfo_privacyPage_title = NSLocalizedString("OnboardingInfo_privacyPage_title", comment: "")
		static let onboardingInfo_privacyPage_boldText = NSLocalizedString("OnboardingInfo_privacyPage_boldText", comment: "")
		static let onboardingInfo_privacyPage_normalText = NSLocalizedString("OnboardingInfo_privacyPage_normalText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_imageDescription = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_imageDescription", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_title = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_title", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_boldText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_boldText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_normalText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_normalText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_panelTitle = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_panelTitle", tableName: "Localizable.legal", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_consentUnderagesTitle = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_consentUnderagesTitle", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_consentUnderagesText = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_consentUnderagesText", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_panelBody = NSLocalizedString("OnboardingInfo_enableLoggingOfContactsPage_panelBody", tableName: "Localizable.legal", comment: "")
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

		// Onbarding Intro EU Texts
		
		static let onboardingInfo_ParticipatingCountries_Title = NSLocalizedString("onboardingInfo_enableLoggingOfContactsPage_participatingCountriesTitle", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_euTitle = NSLocalizedString("onboardingInfo_enableLoggingOfContactsPage_euTitle", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_euDescription = NSLocalizedString("onboardingInfo_enableLoggingOfContactsPage_euDescription", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_emptyEuTitle = NSLocalizedString("onboardingInfo_enableLoggingOfContactsPage_emptyEuTitle", comment: "")
		static let onboardingInfo_enableLoggingOfContactsPage_emptyEuDescription = NSLocalizedString("onboardingInfo_enableLoggingOfContactsPage_emptyEuDescription", comment: "")
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
		static let descriptionText4 = NSLocalizedString("ExposureNotificationSetting_DescriptionText4", comment: "")
		static let actionCellHeader = NSLocalizedString("ExposureNotificationSetting_ActionCell_Header", comment: "")
		static let activateBluetooth = NSLocalizedString("ExposureNotificationSetting_Activate_Bluetooth", comment: "")
		static let activateInternet = NSLocalizedString("ExposureNotificationSetting_Activate_Internet", comment: "")
		static let bluetoothDescription = NSLocalizedString("ExposureNotificationSetting_Bluetooth_Description", comment: "")
		static let internetDescription = NSLocalizedString("ExposureNotificationSetting_Internet_Description", comment: "")
		static let detailActionButtonTitle = NSLocalizedString("ExposureNotificationSetting_Detail_Action_Button", comment: "")
		static let tracingHistoryDescription = NSLocalizedString("ENSetting_Tracing_History", comment: "")
		static let activateOldOSENSetting = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting_Pre13.7", comment: "")
		static let activateOldOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting_Description_Pre13.7", comment: "")
		static let activateOSENSetting = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting", comment: "")
		static let activateOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_Activate_OSENSetting_Description", comment: "")
		static let activateAppOSENSetting = NSLocalizedString("ExposureNotificationSetting_SetActiveApp_OSENSetting", comment: "")
		static let activateAppOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_SetActiveApp_OSENSetting_Description", comment: "")
		static let activateOldAppOSENSettingDescription = NSLocalizedString("ExposureNotificationSetting_SetActiveApp_OSENSetting_Description_Pre13.7", comment: "")
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

		// EU Settings
		
		static let euTracingRiskDeterminationTitle = NSLocalizedString("ExposureNotificationSetting_euTracingRiskDeterminationTitle", comment: "")
		static let euTracingAllCountriesTitle = NSLocalizedString("ExposureNotificationSetting_euTracingAllCountriesTitle", comment: "")
		static let euTitle = NSLocalizedString("ExposureNotificationSetting_EU_Title", comment: "")
		static let euDescription1 = NSLocalizedString("ExposureNotificationSetting_EU_Desc_1", comment: "")
		static let euDescription2 = NSLocalizedString("ExposureNotificationSetting_EU_Desc_2", comment: "")
		static let euDescription3 = NSLocalizedString("ExposureNotificationSetting_EU_Desc_3", comment: "")
		static let euDescription4 = NSLocalizedString("ExposureNotificationSetting_EU_Desc_4", comment: "")
		static let euEmptyErrorTitle = NSLocalizedString("ExposureNotificationSetting_EU_Empty_Error_Title", comment: "")
		static let euEmptyErrorDescription = NSLocalizedString("ExposureNotificationSetting_EU_Empty_Error_Desc", comment: "")
		static let euEmptyErrorButtonTitle = NSLocalizedString("ExposureNotificationSetting_EU_Empty_Error_Button_Title", comment: "")

	}

	enum ExposureNotificationError {

		static let generalErrorTitle = NSLocalizedString("ExposureNotificationSetting_GeneralError_Title", comment: "")

		static let learnMoreActionTitle = NSLocalizedString("ExposureNotificationSetting_GeneralError_LearnMore_Action", comment: "")

		static let enAuthorizationError = NSLocalizedString("ExposureNotificationSetting_AuthenticationError", comment: "")

		static let enActivationRequiredError = NSLocalizedString("ExposureNotificationSetting_exposureNotification_Required", comment: "")

		static let enUnavailableError = NSLocalizedString("ExposureNotificationSetting_exposureNotification_unavailable", comment: "")

		static let enUnknownError = NSLocalizedString("ExposureNotificationSetting_unknownError", comment: "")

		static let apiMisuse = NSLocalizedString("ExposureNotificationSetting_apiMisuse", comment: "")
		
		static let notResponding = NSLocalizedString("ExposureNotificationSetting_notResponding", comment: "")
	}

	enum Home {
		// Home Navigation
		static let leftBarButtonDescription = NSLocalizedString("Home_LeftBarButton_description", comment: "")
		static let rightBarButtonDescription = NSLocalizedString("Home_RightBarButton_description", comment: "")

		// Activate Card
		static let activateCardOnTitle = NSLocalizedString("Home_Activate_Card_On_Title", comment: "")
		static let activateCardOffTitle = NSLocalizedString("Home_Activate_Card_Off_Title", comment: "")
		static let activateCardBluetoothOffTitle = NSLocalizedString("Home_Activate_Card_Bluetooth_Off_Title", comment: "")
		
		// Inactive Card
		static let riskCardInactiveNoCalculationPossibleTitle = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Title", comment: "")
		static let riskCardInactiveOutdatedResultsTitle = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Title", comment: "")
		static let riskCardInactiveNoCalculationPossibleBody = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Body", comment: "")
		static let riskCardInactiveOutdatedResultsBody = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Body", comment: "")
		static let riskCardInactiveNoCalculationPossibleButton = NSLocalizedString("Home_Risk_Inactive_NoCalculation_Possible_Button", comment: "")
		static let riskCardInactiveOutdatedResultsButton = NSLocalizedString("Home_Risk_Inactive_Outdated_Results_Button", comment: "")

		// Failed Card
		static let riskCardFailedCalculationTitle = NSLocalizedString("Home_Risk_Failed_Title", comment: "")
		static let riskCardFailedCalculationBody = NSLocalizedString("Home_Risk_Failed_Body", comment: "")
		static let riskCardFailedCalculationRestartButtonTitle = NSLocalizedString("Home_Risk_Restart_Button_Title", comment: "")

		// Common
		static let riskCardDateItemTitle = NSLocalizedString("Home_Risk_Date_Item_Title", comment: "")
		static let riskCardNoDateTitle = NSLocalizedString("Home_Risk_No_Date_Title", comment: "")
		static let riskCardIntervalDisabledButtonTitle = NSLocalizedString("Home_Risk_Period_Disabled_Button_Title", comment: "")
		static let riskCardLastContactItemTitle = NSLocalizedString("Home_Risk_Last_Contact_Item_Title", comment: "")
		static let riskCardLastContactItemTitleOneRiskDay = NSLocalizedString("Home_Risk_Last_Contact_Item_Title_One_Risk_Day", comment: "")
		static let riskCardLastActiveItemTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Title", comment: "")
		static let riskCardLastActiveItemUnknownTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Unknown_Title", comment: "")
		static let riskCardLastActiveItemLowTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_Low_Title", comment: "")
		static let riskCardLastActiveItemHighTitle = NSLocalizedString("Home_Risk_Last_Activate_Item_High_Title", comment: "")
		static let riskCardUpdateButton = NSLocalizedString("Home_RiskCard_Update_Button", comment: "")

		// Low Card
		static let riskCardLowTitle = NSLocalizedString("Home_Risk_Low_Title", comment: "")
		static let riskCardLowTitleColorName = NSLocalizedString("Home_Risk_Low_Color", comment: "")
		static let riskCardLowNumberContactsItemTitle = NSLocalizedString("Home_Risk_Low_Number_Contacts_Item_Title", comment: "")
		static let daysSinceInstallation = NSLocalizedString("Home_Risk_Days_Since_Installation_Title", comment: "")
		static let riskEncounterLowFAQLink = NSLocalizedString("Risk_Encounter_Low_FAQ_URL", tableName: "Localizable.links", comment: "")

		// High Card
		static let riskCardHighTitle = NSLocalizedString("Home_Risk_High_Title", comment: "")
		static let riskCardHighNumberContactsItemTitle = NSLocalizedString("Home_Risk_High_Number_Contacts_Item_Title", comment: "")
		static let riskCardStatusDownloadingTitle = NSLocalizedString("Home_Risk_Status_Downloading_Title", comment: "")
		static let riskCardStatusDownloadingBody = NSLocalizedString("Home_Risk_Status_Downloading_Body", comment: "")
		static let riskCardStatusDetectingTitle = NSLocalizedString("Home_Risk_Status_Detecting_Title", comment: "")
		static let riskCardStatusDetectingBody = NSLocalizedString("Home_Risk_Status_Detecting_Body", comment: "")

		// Test Result States
		enum TestResult {
			static let pcrTitle = NSLocalizedString("Home_resultCard_PCR_Title", comment: "")
			static let antigenTitle = NSLocalizedString("Home_resultCard_Antigen_Title", comment: "")

			static let resultCardLoadingErrorTitle = NSLocalizedString("Home_resultCard_LoadingErrorTitle", comment: "")

			enum Pending {
				static let title = NSLocalizedString("Home_resultCard_ResultUnvailableTitle", comment: "")
				static let pcrDescription = NSLocalizedString("Home_resultCard_Pending_PCR_Desc", comment: "")
				static let antigenDescription = NSLocalizedString("Home_resultCard_Pending_Antigen_Desc", comment: "")
			}

			enum Available {
				static let title = NSLocalizedString("Home_resultCard_ResultAvailableTitle", comment: "")
				static let description = NSLocalizedString("Home_resultCard_AvailableDesc", comment: "")
			}

			enum Negative {
				static let caption = NSLocalizedString("Home_resultCard_NegativeCaption", comment: "")
				static let title = NSLocalizedString("Home_resultCard_NegativeTitle", comment: "")
				static let titleNegative = NSLocalizedString("Home_resultCard_NegativeTitleNegative", comment: "")
				static let description = NSLocalizedString("Home_resultCard_NegativeDesc", comment: "")
				static let datePCR = NSLocalizedString("Home_resultCard_NegativeDatePCR", comment: "")
				static let dateAntigen = NSLocalizedString("Home_resultCard_NegativeDateAntigen", comment: "")
			}

			enum Invalid {
				static let title = NSLocalizedString("Home_resultCard_InvalidTitle", comment: "")
				static let description = NSLocalizedString("Home_resultCard_InvalidDesc", comment: "")
			}

			enum Expired {
				static let title = NSLocalizedString("Home_resultCard_ExpiredTitle", comment: "")
				static let description = NSLocalizedString("Home_resultCard_ExpiredDesc", comment: "")
			}

			enum Outdated {
				static let title = NSLocalizedString("Home_resultCard_OutdatedTitle", comment: "")
				static let description = NSLocalizedString("Home_resultCard_OutdatedDesc", comment: "")
			}

			enum Loading {
				static let title = NSLocalizedString("Home_resultCard_LoadingTitle", comment: "")
				static let description = NSLocalizedString("Home_resultCard_LoadingBody", comment: "")
			}

			enum Button {
				static let showResult = NSLocalizedString("Home_resultCard_ShowResultButton", comment: "")
				static let retrieveResult = NSLocalizedString("Home_resultCard_RetrieveResultButton", comment: "")
				static let deleteTest = NSLocalizedString("Home_resultCard_DeleteTestButton", comment: "")
				static let hideTest = NSLocalizedString("Home_resultCard_HideTestButton", comment: "")
			}

			enum ShownPositive {
				static let statusTitle = NSLocalizedString("Home_Finding_Positive_Card_Status_Title", comment: "")
				static let statusSubtitle = NSLocalizedString("Home_Finding_Positive_Card_Status_Subtitle", comment: "")
				static let statusDatePCR = NSLocalizedString("Home_Finding_Positive_Card_Status_DatePCR", comment: "")
				static let statusDateAntigen = NSLocalizedString("Home_Finding_Positive_Card_Status_DateAntigen", comment: "")
				static let noteTitle = NSLocalizedString("Home_Finding_Positive_Card_Note_Title", comment: "")
				static let verifyItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Verify_Item_Title", comment: "")
				static let phoneItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Phone_Item_Title", comment: "")
				static let homeItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Home_Item_Title", comment: "")
				static let shareItemTitle = NSLocalizedString("Home_Finding_Positive_Card_Share_Item_Title", comment: "")
				static let button = NSLocalizedString("Home_Finding_Positive_Card_Button", comment: "")
				static let removeTestButton = NSLocalizedString("Home_Finding_Positive_Card_Button_Remove_Test", comment: "")
			}
		}

		enum TestRegistration {
			static let title = NSLocalizedString("Home_TestRegistration_Title", comment: "")
			static let description = NSLocalizedString("Home_TestRegistration_Body", comment: "")
			static let button = NSLocalizedString("Home_TestRegistration_Button", comment: "")
		}

		enum MoreInfoCard {
			static let title = NSLocalizedString("Home_MoreCard_Title", comment: "")
			static let settingsTitle = NSLocalizedString("Home_MoreCard_SettingsTitle", comment: "")
			static let recycleBinTitle = NSLocalizedString("Home_MoreCard_RecycleBinTitle", comment: "")
			static let appInformationTitle = NSLocalizedString("Home_MoreCard_AppInformationTitle", comment: "")
			static let faqTitle = NSLocalizedString("Home_MoreCard_FAQTitle", comment: "")
			static let shareTitle = NSLocalizedString("Home_MoreCard_ShareTitle", comment: "")
		}
		
		// Trace Locations Card
		static let traceLocationsCardTitle = NSLocalizedString("Home_TraceLocationsCard_Title", comment: "")
		static let traceLocationsCardBody = NSLocalizedString("Home_TraceLocationsCard_Body", comment: "")
		static let traceLocationsCardButton = NSLocalizedString("Home_TraceLocationsCard_Button", comment: "")

		// Risk Detection HowTo Alert

		static let riskDetectionHowToAlertTitle = NSLocalizedString("How_Risk_Detection_Works_Alert_Title", comment: "")
		static let riskDetectionHowToAlertMessage = NSLocalizedString("How_Risk_Detection_Works_Alert_Message", comment: "")

		static let riskStatusLoweredAlertTitle = NSLocalizedString("Home_Alert_RiskStatusLowered_Title", comment: "")
		static let riskStatusLoweredAlertMessage = NSLocalizedString("Home_Alert_RiskStatusLowered_Message", comment: "")
		static let riskStatusLoweredAlertPrimaryButtonTitle = NSLocalizedString("Home_Alert_RiskStatusLowered_PrimaryButtonTitle", comment: "")
	}

	enum InviteFriends {
		static let title = NSLocalizedString("InviteFriends_Title", comment: "")
		static let description = NSLocalizedString("InviteFriends_Description", comment: "")
		static let submit = NSLocalizedString("InviteFriends_Button", comment: "")
		static let navigationBarTitle = NSLocalizedString("InviteFriends_NavTitle", comment: "")
		static let shareTitle = NSLocalizedString("InviteFriends_ShareTitle", comment: "")
		static let shareUrl = NSLocalizedString("InviteFriends_ShareUrl", tableName: "Localizable.links", comment: "")
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
		static let targetURL = NSLocalizedString("safari_corona_website", tableName: "Localizable.links", comment: "")
	}

	enum LocalNotifications {
		static let ignore = NSLocalizedString("local_notifications_ignore", comment: "")
		static let detectExposureTitle = NSLocalizedString("local_notifications_detectexposure_title", comment: "")
		static let detectExposureBody = NSLocalizedString("local_notifications_detectexposure_body", comment: "")
		static let testResultsTitle = NSLocalizedString("local_notifications_testresults_title", comment: "")
		static let testResultsBody = NSLocalizedString("local_notifications_testresults_body", comment: "")
		static let certificateGenericTitle = NSLocalizedString("local_notifications_certificate_title", comment: "")
		static let certificateGenericBody = NSLocalizedString("local_notifications_certificate_body", comment: "")
		static let certificateValidityBody = NSLocalizedString("local_notifications_certificate_validity_body", comment: "")
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
		static let legend2Low = NSLocalizedString("RiskLegend_Legend2_Low", comment: "")
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
		static let appInformationNavigationTitle = NSLocalizedString("App_Information_Title", comment: "")
		static let appInformationVersion = NSLocalizedString("App_Information_Version", comment: "")

		static let newFeaturesNavigation = NSLocalizedString("App_Information_New_Features_Navigation", comment: "")
		static let aboutNavigation = NSLocalizedString("App_Information_About_Navigation", comment: "")
		static let aboutImageDescription = NSLocalizedString("App_Information_About_ImageDescription", comment: "")
		static let aboutTitle = NSLocalizedString("App_Information_About_Title", comment: "")
		static let aboutDescription = NSLocalizedString("App_Information_About_Description", comment: "")
		static let aboutText = NSLocalizedString("App_Information_About_Text", comment: "")
		static let aboutLink = NSLocalizedString("App_Information_About_Link", tableName: "Localizable.links", comment: "")
		static let aboutLinkText = NSLocalizedString("App_Information_About_LinkText", comment: "")

		static let faqNavigation = NSLocalizedString("App_Information_FAQ_Navigation", comment: "")

		static let contactNavigation = NSLocalizedString("App_Information_Contact_Navigation", comment: "")
		static let contactImageDescription = NSLocalizedString("App_Information_Contact_ImageDescription", comment: "")
		static let contactTitle = NSLocalizedString("App_Information_Contact_Title", comment: "")
		static let contactDescription = NSLocalizedString("App_Information_Contact_Description", comment: "")
		static let contactHotlineTitle = NSLocalizedString("App_Information_Contact_Hotline_Title", comment: "")
		static let contactHotlineDomesticText = NSLocalizedString("App_Information_Contact_Hotline_Text_Domestic", comment: "")
		static let contactHotlineDomesticNumber = NSLocalizedString("App_Information_Contact_Hotline_Number_Domestic", comment: "")
		static let contactHotlineDomesticDetails = NSLocalizedString("App_Information_Contact_Hotline_Details_Domestic", comment: "")
		static let contactHotlineForeignText = NSLocalizedString("App_Information_Contact_Hotline_Text_Foreign", comment: "")
		static let contactHotlineForeignNumber = NSLocalizedString("App_Information_Contact_Hotline_Number_Foreign", comment: "")
		static let contactHotlineForeignDetails = NSLocalizedString("App_Information_Contact_Hotline_Details_Foreign", comment: "")
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
		static let imprintSectionContactFormTitle = NSLocalizedString("App_Information_Contact_Form_Title", comment: "")
		static let imprintSectionContactFormLink = NSLocalizedString("App_Information_Contact_Form_Link", tableName: "Localizable.links", comment: "")

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
	
	enum NewVersionFeatures {
		static let accImageLabel = NSLocalizedString("DeltaOnboarding_NewVersionFeatures_AccessibilityImageLabel", comment: "")
		
		static let title = NSLocalizedString("DeltaOnboarding_NewVersionFeatures_Title", comment: "")
		
		static let release = NSLocalizedString("DeltaOnboarding_NewVersionFeatures_Release", comment: "")
		
		static let buttonContinue = NSLocalizedString("DeltaOnboarding_NewVersionFeatures_Button_Continue", comment: "")
		
		static let generalDescription = NSLocalizedString("DeltaOnboarding_NewVersionFeatures_Description", comment: "")
		
		static let aboutAppInformation = NSLocalizedString("NewVersionFeatures_Info_about_abb_information", comment: "")
		
		/* Version 2.15 */
		
		static let feature215TicketValidationTitle = NSLocalizedString("NewVersionFeature_215_ticketValidation_title", comment: "")
		
		static let feature215TicketValidationDescription = NSLocalizedString("NewVersionFeature_215_ticketValidation_description", comment: "")
	}
	
	enum DeltaOnboarding {
		static let accImageLabel = NSLocalizedString("DeltaOnboarding_AccessibilityImageLabel", comment: "")
		
		static let title = NSLocalizedString("DeltaOnboarding_Headline", comment: "")
		
		static let description = NSLocalizedString("DeltaOnboarding_Description", comment: "")
		static let participatingCountries = NSLocalizedString("DeltaOnboarding_ParticipatingCountries", comment: "")
		
		static let participatingCountriesListUnavailableTitle = NSLocalizedString("DeltaOnboarding_ParticipatingCountriesList_Unavailable_Title", comment: "")
		static let participatingCountriesListUnavailable = NSLocalizedString("DeltaOnboarding_ParticipatingCountriesList_Unavailable", comment: "")
		
		static let primaryButton = NSLocalizedString("DeltaOnboarding_PrimaryButton_Continue", comment: "")
		
		static let legalDataProcessingInfoTitle = NSLocalizedString("DeltaOnboarding_DataProcessing_Info_title", tableName: "Localizable.legal", comment: "")
		
		static let legalDataProcessingInfoContent = NSLocalizedString("DeltaOnboarding_DataProcessing_Info_content", tableName: "Localizable.legal", comment: "")

		static let termsDescription1 = NSLocalizedString("DeltaOnboarding_Terms_Description1", comment: "")
		static let termsButtonTitle = NSLocalizedString("DeltaOnboarding_Terms_Button", comment: "")
		static let termsDescription2 = NSLocalizedString("DeltaOnboarding_Terms_Description2", comment: "")
	}

	enum WarnOthersNotification {
		static let title = NSLocalizedString("WarnOthersNotification_Title", comment: "")
		static let description = NSLocalizedString("WarnOthersNotification_Description", comment: "")
	}

	enum WrongDeviceTime {
		static let errorPushNotificationTitle = NSLocalizedString("ExposureDetection_WrongTime_Notification_Title", comment: "")
		static let errorPushNotificationText = NSLocalizedString("ExposureDetection_WrongTime_Notification_Body", comment: "")
	}
	
	enum AutomaticSharingConsent {
		static let consentTitle = NSLocalizedString("AutomaticSharingConsent_Title", comment: "")
		static let switchTitle = NSLocalizedString("AutomaticSharingConsent_SwitchTitle", comment: "")
		static let switchTitleDescription = NSLocalizedString("AutomaticSharingConsent_SwitchTitleDesc", comment: "")
		static let consentSubTitle = NSLocalizedString("AutomaticSharingConsent_Subtitle", tableName: "Localizable.legal", comment: "")
		static let consentDescriptionPart1 = NSLocalizedString("AutomaticSharingConsent_DescriptionPart1", tableName: "Localizable.legal", comment: "")
		static let consentDescriptionPart2 = NSLocalizedString("AutomaticSharingConsent_DescriptionPart2", tableName: "Localizable.legal", comment: "")
		static let consentDescriptionPart3 = NSLocalizedString("AutomaticSharingConsent_DescriptionPart3", tableName: "Localizable.legal", comment: "")
		static let consentDescriptionPart4 = NSLocalizedString("AutomaticSharingConsent_DescriptionPart4", tableName: "Localizable.legal", comment: "")
		static let consentDescriptionPart5 = NSLocalizedString("AutomaticSharingConsent_DescriptionPart5", tableName: "Localizable.legal", comment: "")
		static let dataProcessingDetailInfo = NSLocalizedString("AutomaticSharingConsent_DataProcessingDetailInfo", comment: "")
	}

	enum ThankYouScreen {
		static let title = NSLocalizedString("Thank_You_Title", comment: "")
		static let subTitle = NSLocalizedString("Thank_You_SubTitle", comment: "")
		static let description1 = NSLocalizedString("Thank_You_Description1", comment: "")
		static let description2 = NSLocalizedString("Thank_You_Description2", comment: "")
		static let continueButton = NSLocalizedString("Thank_You_Continue_Button", comment: "")
		static let cancelButton = NSLocalizedString("Thank_You_Cancel_Button", comment: "")
		static let accImageDescription = NSLocalizedString("Thank_You_AccImageDescription", comment: "")
	}
	
	enum ContactDiary {

		enum Overview {
			static let menuButtonTitle = NSLocalizedString("ContactDiary_Overview_Button_Title_Menu", comment: "")
			static let title = NSLocalizedString("ContactDiary_Overview_Title", comment: "")
			static let description = NSLocalizedString("ContactDiary_Overview_Description", comment: "")
			static let increasedRiskTitle = NSLocalizedString("ContactDiary_Overview_Increased_Risk_Title", comment: "")
			static let lowRiskTitle = NSLocalizedString("ContactDiary_Overview_Low_Risk_Title", comment: "")
			static let riskTextStandardCause = NSLocalizedString("ContactDiary_Overview_Risk_Text_StandardCause", comment: "")
			static let riskTextLowRiskEncountersCause = NSLocalizedString("ContactDiary_Overview_Risk_Text_LowRiskEncountersCause", comment: "")
			static let riskTextDisclaimer = NSLocalizedString("ContactDiary_Overview_Risk_Text_Disclaimer", comment: "")

			enum Tests {
				static let pcrRegistered = NSLocalizedString("ContactDiary_Overview_Tests_PCR_Registered", comment: "")
				static let antigenDone = NSLocalizedString("ContactDiary_Overview_Tests_Antigen_Done", comment: "")
				static let negativeResult = NSLocalizedString("ContactDiary_Overview_Tests_Negative_Result", comment: "")
				static let positiveResult = NSLocalizedString("ContactDiary_Overview_Tests_Positive_Result", comment: "")
			}

			enum ActionSheet {
				static let infoActionTitle = NSLocalizedString("ContactDiary_Overview_ActionSheet_InfoActionTitle", comment: "")
				static let exportActionTitle = NSLocalizedString("ContactDiary_Overview_ActionSheet_ExportActionTitle", comment: "")
				static let exportActionSubject = NSLocalizedString("ContactDiary_Overview_ActionSheet_ExportActionSubject", comment: "")
				static let editPersonTitle = NSLocalizedString("ContactDiary_Overview_ActionSheet_EditPersonTitle", comment: "")
				static let editLocationTitle = NSLocalizedString("ContactDiary_Overview_ActionSheet_EditLocationTitle", comment: "")
			}

			enum PersonEncounter {
				static let durationLessThan10Minutes = NSLocalizedString("ContactDiary_Overview_PersonEncounter_Duration_LessThan10Minutes", comment: "")
				static let durationMoreThan10Minutes = NSLocalizedString("ContactDiary_Overview_PersonEncounter_Duration_MoreThan10Minutes", comment: "")

				static let maskSituationWithMask = NSLocalizedString("ContactDiary_Overview_PersonEncounter_MaskSituation_WithMask", comment: "")
				static let maskSituationWithoutMask = NSLocalizedString("ContactDiary_Overview_PersonEncounter_MaskSituation_WithoutMask", comment: "")

				static let settingOutside = NSLocalizedString("ContactDiary_Overview_PersonEncounter_Setting_Outside", comment: "")
				static let settingInside = NSLocalizedString("ContactDiary_Overview_PersonEncounter_Setting_Inside", comment: "")
			}

			enum LocationVisit {
				static let abbreviationHours = NSLocalizedString("ContactDiary_Overview_LocationVisit_Abbreviation_Hours", comment: "")
			}
			
			enum CheckinEncounter {
				static let titleHighRisk = NSLocalizedString("ContactDiaray_Overview_Checkin_Title_HighRisk", comment: "")
				static let titleLowRisk = NSLocalizedString("ContactDiaray_Overview_Checkin_Title_LowRisk", comment: "")
				static let titleSubheadline = NSLocalizedString("ContactDiaray_Overview_Checkin_Title_Subheadline", comment: "")
				static let highRisk = NSLocalizedString("ContactDiaray_Overview_Checkin_High_Risk_In_Brackets", comment: "")
				static let lowRisk = NSLocalizedString("ContactDiaray_Overview_Checkin_Low_Risk_In_Brackets", comment: "")
			}
		}

		enum Day {
			static let contactPersonsSegment = NSLocalizedString("ContactDiary_Day_ContactPersonsSegment", comment: "")
			static let addContactPerson = NSLocalizedString("ContactDiary_Day_AddContactPerson", comment: "")
			static let contactPersonsEmptyTitle = NSLocalizedString("ContactDiary_Day_ContactPersonsEmptyTitle", comment: "")
			static let contactPersonsEmptyDescription = NSLocalizedString("ContactDiary_Day_ContactPersonsEmptyDescription", comment: "")
			static let contactPersonsEmptyImageDescription = NSLocalizedString("ContactDiary_Day_ContactPersonsEmptyImageDescription", comment: "")
			static let locationsSegment = NSLocalizedString("ContactDiary_Day_LocationsSegment", comment: "")
			static let addLocation = NSLocalizedString("ContactDiary_Day_AddLocation", comment: "")
			static let locationsEmptyTitle = NSLocalizedString("ContactDiary_Day_LocationsEmptyTitle", comment: "")
			static let locationsEmptyDescription = NSLocalizedString("ContactDiary_Day_LocationsEmptyDescription", comment: "")
			static let locationsEmptyImageDescription = NSLocalizedString("ContactDiary_Day_LocationsEmptyImageDescription", comment: "")

			enum Encounter {
				static let lessThan10Minutes = NSLocalizedString("ContactDiary_Day_Encounter_LessThan10Minutes", comment: "")
				static let moreThan10Minutes = NSLocalizedString("ContactDiary_Day_Encounter_MoreThan10Minutes", comment: "")
				static let withMask = NSLocalizedString("ContactDiary_Day_Encounter_WithMask", comment: "")
				static let withoutMask = NSLocalizedString("ContactDiary_Day_Encounter_WithoutMask", comment: "")
				static let outside = NSLocalizedString("ContactDiary_Day_Encounter_Outside", comment: "")
				static let inside = NSLocalizedString("ContactDiary_Day_Encounter_Inside", comment: "")
				static let notesPlaceholder = NSLocalizedString("ContactDiary_Day_Encounter_Notes_Placeholder", comment: "")
			}

			enum Visit {
				static let duration = NSLocalizedString("ContactDiary_Day_Visit_Duration", comment: "")
				static let notesPlaceholder = NSLocalizedString("ContactDiary_Day_Visit_Notes_Placeholder", comment: "")
			}
		}

		enum EditEntries {
			enum ContactPersons {
				static let title = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_Title", comment: "")
				static let deleteAllButtonTitle = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_DeleteAllButtonTitle", comment: "")

				enum DeleteOneAlert {
					static let title = NSLocalizedString("ContactDiary_EditEntries_ContactPerson_AlertTitle", comment: "")
					static let message = NSLocalizedString("ContactDiary_EditEntries_ContactPerson_AlertMessage", comment: "")
					static let confirmButtonTitle = NSLocalizedString("ContactDiary_EditEntries_ContactPerson_AlertConfirmButtonTitle", comment: "")
					static let cancelButtonTitle = NSLocalizedString("ContactDiary_EditEntries_ContactPerson_AlertCancelButtonTitle", comment: "")
				}

				enum DeleteAllAlert {
					static let title = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_AlertTitle", comment: "")
					static let message = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_AlertMessage", comment: "")
					static let confirmButtonTitle = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_AlertConfirmButtonTitle", comment: "")
					static let cancelButtonTitle = NSLocalizedString("ContactDiary_EditEntries_ContactPersons_AlertCancelButtonTitle", comment: "")
				}
			}

			enum Locations {
				static let title = NSLocalizedString("ContactDiary_EditEntries_Locations_Title", comment: "")
				static let deleteAllButtonTitle = NSLocalizedString("ContactDiary_EditEntries_Locations_DeleteAllButtonTitle", comment: "")

				enum DeleteOneAlert {
					static let title = NSLocalizedString("ContactDiary_EditEntries_Location_AlertTitle", comment: "")
					static let message = NSLocalizedString("ContactDiary_EditEntries_Location_AlertMessage", comment: "")
					static let confirmButtonTitle = NSLocalizedString("ContactDiary_EditEntries_Location_AlertConfirmButtonTitle", comment: "")
					static let cancelButtonTitle = NSLocalizedString("ContactDiary_EditEntries_Location_AlertCancelButtonTitle", comment: "")
				}

				enum DeleteAllAlert {
					static let title = NSLocalizedString("ContactDiary_EditEntries_Locations_AlertTitle", comment: "")
					static let message = NSLocalizedString("ContactDiary_EditEntries_Locations_AlertMessage", comment: "")
					static let confirmButtonTitle = NSLocalizedString("ContactDiary_EditEntries_Locations_AlertConfirmButtonTitle", comment: "")
					static let cancelButtonTitle = NSLocalizedString("ContactDiary_EditEntries_Locations_AlertCancelButtonTitle", comment: "")
				}
			}
		}

		enum Information {
			static let title = NSLocalizedString("ContactDiary_Information_Title", comment: "")
			static let imageDescription = NSLocalizedString("ContactDiary_Information_ImageDescription", comment: "")
			static let descriptionTitle = NSLocalizedString("ContactDiary_Information_DescriptionTitle", comment: "")
			static let descriptionSubHeadline = NSLocalizedString("ContactDiary_Information_DescriptionSubHeadline", comment: "")
			static let itemPersonTitle = NSLocalizedString("ContactDiary_Information_Item_Person_Title", comment: "")
			static let itemContactTitle = NSLocalizedString("ContactDiary_Information_Item_Location_Title", comment: "")
			static let itemLockTitle = NSLocalizedString("ContactDiary_Information_Item_Lock_Title", comment: "")
			static let deletedAutomatically = NSLocalizedString("ContactDiary_Information_Item_DeletedAutomatically_Title", comment: "")
			static let exportTextformat = NSLocalizedString("ContactDiary_Information_Item_ExportTextFormat_Title", comment: "")
			static let exposureHistory = NSLocalizedString("ContactDiary_Information_Item_ExposureHistory_Title", comment: "")
			static let legalHeadline_1 = NSLocalizedString("ContactDiary_Information_Legal_Headline_1", tableName: "Localizable.legal", comment: "")
			static let legalSubHeadline_1 = NSLocalizedString("ContactDiary_Information_Legal_SubHeadline_1", tableName: "Localizable.legal", comment: "")
			static let legalSubHeadline_2 = NSLocalizedString("ContactDiary_Information_Legal_SubHeadline_2", tableName: "Localizable.legal", comment: "")
			static let legalText_1 = NSLocalizedString("ContactDiary_Information_Legal_Text_1", tableName: "Localizable.legal", comment: "")
			static let legalText_2 = NSLocalizedString("ContactDiary_Information_Legal_Text_2", tableName: "Localizable.legal", comment: "")
			static let legalText_3 = NSLocalizedString("ContactDiary_Information_Legal_Text_3", tableName: "Localizable.legal", comment: "")
			static let legalText_4 = NSLocalizedString("ContactDiary_Information_Legal_Text_4", tableName: "Localizable.legal", comment: "")
			static let dataPrivacyTitle = NSLocalizedString("ContactDiary_Information_Dataprivacy_Title", comment: "")
			static let primaryButtonTitle = NSLocalizedString("ContactDiary_Information_PrimaryButton_Title", comment: "")
		}

		enum AddEditEntry {
			static let primaryButtonTitle = NSLocalizedString("ContactDiary_AddEditEntry_PrimaryButton_Title", comment: "")

			enum location {
				static let title = NSLocalizedString("ContactDiary_AddEditEntry_LocationTitle", comment: "")
				enum placeholders {
					static let name = NSLocalizedString("ContactDiary_AddEditEntry_LocationPlaceholder_Name", comment: "")
					static let phoneNumber = NSLocalizedString("ContactDiary_AddEditEntry_LocationPlaceholder_PhoneNumber", comment: "")
					static let email = NSLocalizedString("ContactDiary_AddEditEntry_LocationPlaceholder_EmailAddress", comment: "")
				}
			}

			enum person {
				static let title = NSLocalizedString("ContactDiary_AddEditEntry_PersonTitle", comment: "")
				enum placeholders {
					static let name = NSLocalizedString("ContactDiary_AddEditEntry_PersonPlaceholder_Name", comment: "")
					static let phoneNumber = NSLocalizedString("ContactDiary_AddEditEntry_PersonPlaceholder_PhoneNumber", comment: "")
					static let email = NSLocalizedString("ContactDiary_AddEditEntry_PersonPlaceholder_EmailAddress", comment: "")
				}
			}
		}
		
		enum NotesInformation {
			static let title = NSLocalizedString("Contact_Journal_Notes_Description_Title", comment: "")
			static let description = NSLocalizedString("Contact_Journal_Notes_Description", comment: "")
		}
	}

	enum Statistics {
		static let error = NSLocalizedString("Statistics_LoadingError", comment: "")
		enum AddCard {
			static let sevenDayIncidence = NSLocalizedString("Statistics_Add_SevenDayIncidence", comment: "")
			static let disabledAddTitle = NSLocalizedString("Statistics_Add_DisabledAddTitle", comment: "")

			static let localCardTitle = NSLocalizedString("Statistics_Add_LocalCardTitle", comment: "")
			static let stateWide = NSLocalizedString("Statistics_Add_fromTheWholeCountry", comment: "")
			static let modify = NSLocalizedString("Statistics_Card_Manage", comment: "")
		}
		enum Card {
			static let fromNationWide = NSLocalizedString("Statistics_Card_From_Nationwide", comment: "")
			static let fromCWA = NSLocalizedString("Statistics_Card_From_CWA", comment: "")

			enum Infections {
				static let title = NSLocalizedString("Statistics_Card_Infections_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_Infections_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_Infections_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_Infections_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_Infections_SecondaryLabelTitle", comment: "")
				static let tertiaryLabelTitle = NSLocalizedString("Statistics_Card_Infections_TertiaryLabelTitle", comment: "")
			}

			enum Region {
				static let today = NSLocalizedString("Statistics_Card_Region_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_Region_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_Region_Date", comment: "")
				static let primaryLabelSubtitle = NSLocalizedString("Statistics_Card_Region_PrimaryLabelSubtitle", comment: "")
				static let secondaryLabelSubtitleFederalState = NSLocalizedString("Statistics_Card_Region_SecondaryLabelSubtitle_FederalState", comment: "")
				static let secondaryLabelSubtitleAdministrativeUnit = NSLocalizedString("Statistics_Card_Region_SecondaryLabelSubtitle_AdministrativeUnit", comment: "")
			}

			enum KeySubmissions {
				static let title = NSLocalizedString("Statistics_Card_KeySubmissions_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_KeySubmissions_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_KeySubmissions_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_KeySubmissions_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_KeySubmissions_SecondaryLabelTitle", comment: "")
				static let tertiaryLabelTitle = NSLocalizedString("Statistics_Card_KeySubmissions_TertiaryLabelTitle", comment: "")
				static let footnote = NSLocalizedString("Statistics_Card_KeySubmissions_Footnote", comment: "")
			}

			enum ReproductionNumber {
				static let title = NSLocalizedString("Statistics_Card_ReproductionNumber_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_ReproductionNumber_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_ReproductionNumber_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_ReproductionNumber_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_ReproductionNumber_SecondaryLabelTitle", comment: "")
			}

			enum AtleastOneVaccinated {
				static let title = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_SecondaryLabelTitle", comment: "")
				static let primarySubtitle = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_SecondarySubtitleLabel", comment: "")
				static let tertiaryLabelTitle = NSLocalizedString("Statistics_Card_AtLeastOneVaccinated_TertiaryLabelTitle", comment: "")

			}
			
			enum FullyVaccinated {
				static let title = NSLocalizedString("Statistics_Card_FullyVaccinated_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_FullyVaccinated_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_FullyVaccinated_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_FullyVaccinated_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_FullyVaccinated_SecondaryLabelTitle", comment: "")
				static let tertiaryLabelTitle = NSLocalizedString("Statistics_Card_FullyVaccinated_TertiaryLabelTitle", comment: "")
				static let primarySubtitle = NSLocalizedString("Statistics_Card_FullyVaccinated_SecondarySubtitleLabel", comment: "")
				static let percent = NSLocalizedString("Statistics_Card_FullyVaccinated_Percent", comment: "")
			}
			
			enum DoseRates {
				static let title = NSLocalizedString("Statistics_Card_AppliedDoseRates_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_AppliedDoseRates_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_AppliedDoseRates_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_AppliedDoseRates_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_AppliedDoseRates_SecondaryLabelTitle", comment: "")
				static let tertiaryLabelTitle = NSLocalizedString("Statistics_Card_AppliedDoseRates_TertiaryLabelTitle", comment: "")
			}
			
			enum Combined7DaysIncidence {
				static let title = NSLocalizedString("Statistics_Card_CombinedIncidence_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_CombinedIncidence_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_CombinedIncidence_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_CombinedIncidence_Date", comment: "")
				static let primaryLabelSubtitle = NSLocalizedString("Statistics_Card_CombinedIncidence_PrimaryLabelSubtitle", comment: "")
				static let secondaryLabelSubtitle = NSLocalizedString("Statistics_Card_CombinedIncidence_SecondaryLabelSubtitle", comment: "")
			}

			enum IntensiveCare {
				static let title = NSLocalizedString("Statistics_Card_IntensiveCare_Title", comment: "")
				static let today = NSLocalizedString("Statistics_Card_IntensiveCare_Today", comment: "")
				static let yesterday = NSLocalizedString("Statistics_Card_IntensiveCare_Yesterday", comment: "")
				static let date = NSLocalizedString("Statistics_Card_IntensiveCare_Date", comment: "")
				static let secondaryLabelTitle = NSLocalizedString("Statistics_Card_IntensiveCare_SecondaryLabelTitle", comment: "")
			}
			
			static let trendIncreasing = NSLocalizedString("Statistics_Card_Trend_Increasing", comment: "")
			static let trendDecreasing = NSLocalizedString("Statistics_Card_Trend_Decreasing", comment: "")
			static let trendStable = NSLocalizedString("Statistics_Card_Trend_Stable", comment: "")

			static let trendSemanticNegative = NSLocalizedString("Statistics_Card_TrendSemantic_Negative", comment: "")
			static let trendSemanticPositive = NSLocalizedString("Statistics_Card_TrendSemantic_Positive", comment: "")
			static let trendSemanticNeutral = NSLocalizedString("Statistics_Card_TrendSemantic_Neutral", comment: "")

			static let million = NSLocalizedString("Statistics_Card_Million", comment: "")

		}

		enum Info {
			static let title = NSLocalizedString("Statistics_Info_Title", comment: "")
			static let subtitle = NSLocalizedString("Statistics_Info_Subtitle", comment: "")
			static let incidenceTitle = NSLocalizedString("Statistics_Info_Incidence_Title", comment: "")
			static let local7DaysTitle = NSLocalizedString("Statistics_Info_Local7Days_Title", comment: "")
			static let local7DaysText = NSLocalizedString("Statistics_Info_Local7Days_Text", comment: "")
			static let newInfectionTitle = NSLocalizedString("Statistics_Info_NewInfection_Title", comment: "")
			static let newInfectionText = NSLocalizedString("Statistics_Info_NewInfection_Text", comment: "")
			static let hospitalizationRateTitle = NSLocalizedString("Statistics_Info_HospitalizationRate_Title", comment: "")
			static let hospitalizationRateText = NSLocalizedString("Statistics_Info_HospitalizationRate_Text", comment: "")
			static let intensiveCareTitle = NSLocalizedString("Statistics_Info_IntensiveCare_Title", comment: "")
			static let intensiveCareText = NSLocalizedString("Statistics_Info_IntensiveCare_Text", comment: "")
			static let infectionsTitle = NSLocalizedString("Statistics_Info_Infections_Title", comment: "")
			static let infectionsText = NSLocalizedString("Statistics_Info_Infections_Text", comment: "")
			static let keySubmissionsTitle = NSLocalizedString("Statistics_Info_KeySubmissions_Title", comment: "")
			static let keySubmissionsText = NSLocalizedString("Statistics_Info_KeySubmissions_Text", comment: "")
			static let reproductionNumberTitle = NSLocalizedString("Statistics_Info_ReproductionNumber_Title", comment: "")
			static let reproductionNumberText = NSLocalizedString("Statistics_Info_ReproductionNumber_Text", comment: "")
			static let vaccinatedAtLeastOnceTitle = NSLocalizedString("Statistics_Info_AtLeastOnce_Title", comment: "")
			static let vaccinatedAtLeastOnceText = NSLocalizedString("Statistics_Info_AtLeastOnce_Text", comment: "")
			static let fullyVaccinatedTitle = NSLocalizedString("Statistics_Info_FullyVaccinated_Title", comment: "")
			static let fullyVaccinatedText = NSLocalizedString("Statistics_Info_FullyVaccinated_Text", comment: "")
			static let dosesAdministeredTitle = NSLocalizedString("Statistics_Info_DosesAdministered_Title", comment: "")
			static let dosesAdministeredText = NSLocalizedString("Statistics_Info_DosesAdministered_Text", comment: "")
			static let faqLinkText = NSLocalizedString("Statistics_Info_FAQLink_Text", comment: "")
			static let faqLinkTitle = NSLocalizedString("Statistics_Info_FAQLink_Title", comment: "")
			static let faqLink = NSLocalizedString("Statistics_Info_FAQ_URL", tableName: "Localizable.links", comment: "")
			static let definitionsTitle = NSLocalizedString("Statistics_Info_Definitions_Title", comment: "")
			static let periodTitle = NSLocalizedString("Statistics_Info_Period_Title", comment: "")
			static let yesterdayTitle = NSLocalizedString("Statistics_Info_Yesterday_Title", comment: "")
			static let yesterdayText = NSLocalizedString("Statistics_Info_Yesterday_Text", comment: "")
			static let meanTitle = NSLocalizedString("Statistics_Info_Mean_Title", comment: "")
			static let meanText = NSLocalizedString("Statistics_Info_Mean_Text", comment: "")
			static let totalTitle = NSLocalizedString("Statistics_Info_Total_Title", comment: "")
			static let totalText = NSLocalizedString("Statistics_Info_Total_Text", comment: "")
			static let trendTitle = NSLocalizedString("Statistics_Info_Trend_Title", comment: "")
			static let trendText = NSLocalizedString("Statistics_Info_Trend_Text", comment: "")
			static let trendsTitle = NSLocalizedString("Statistics_Info_Trends_Title", comment: "")
			static let trendsIncreasing = NSLocalizedString("Statistics_Info_Trends_Increasing", comment: "")
			static let trendsDecreasing = NSLocalizedString("Statistics_Info_Trends_Decreasing", comment: "")
			static let trendsStable = NSLocalizedString("Statistics_Info_Trends_Stable", comment: "")
			static let trendsFootnote = NSLocalizedString("Statistics_Info_Trends_Footnote", comment: "")
			static let titleImageAccLabel = NSLocalizedString("Statistics_Info_Image_AccLabel", comment: "")
			static let blogDescription = NSLocalizedString("Statistics_Info_Blog_Description", comment: "")
			static let blog = NSLocalizedString("Statistics_Info_More_Information_Blog", comment: "")
		}
	}
	
	enum UpdateOS {
		static let title = NSLocalizedString("UpdateOS_title", comment: "")
		static let text = NSLocalizedString("UpdateOS_text", comment: "")
	}
	
	enum Tabbar {
		static let homeTitle = NSLocalizedString("Tabbar_Home_Title", comment: "")
		static let certificatesTitle = NSLocalizedString("Tabbar_Certificates_Title", comment: "")
		static let scannerTitle = NSLocalizedString("Tabbar_Scanner_Title", comment: "")
		static let checkInTitle = NSLocalizedString("Tabbar_CheckIn_Title", comment: "")
		static let diaryTitle = NSLocalizedString("Tabbar_Diary_Title", comment: "")
	}
	
	enum DataDonation {
		enum ValueSelection {
			static let noValue = NSLocalizedString("DataDonation_ValueSelection_None", comment: "")
			enum Title {
				static let FederalState = NSLocalizedString("DataDonation_ValueSelection_Title_State", comment: "")
				static let Region = NSLocalizedString("DataDonation_ValueSelection_Title_Region", comment: "")
				static let Age = NSLocalizedString("DataDonation_ValueSelection_Title_Age", comment: "")
			}
			enum Ages {
				static let Below29 = NSLocalizedString("DataDonation_ValueSelection_Age_Below29", comment: "")
				static let Between30And59 = NSLocalizedString("DataDonation_ValueSelection_Age_Between30And59", comment: "")
				static let Min60OrAbove = NSLocalizedString("DataDonation_ValueSelection_Age_Min60OrAbove", comment: "")
			}
		}

		enum Info {
			static let introductionText = NSLocalizedString("DataDonation_IntroductionText", comment: "")
			static let settingsSubHeadline = NSLocalizedString("DataDonation_SubHead_Settings", comment: "")
			static let accImageDescription = NSLocalizedString("DataDonation_AccImageDescription", comment: "")
			static let title = NSLocalizedString("DataDonation_Headline", comment: "")
			static let description = NSLocalizedString("DataDonation_Description", comment: "")
			static let subHeadState = NSLocalizedString("DataDonation_SubHead_YourState", comment: "")
			static let subHeadAgeGroup = NSLocalizedString("DataDonation_SubHead_AgeGroup", comment: "")
			static let noSelectionState = NSLocalizedString("DataDonation_State_NoSelection_Text", comment: "")
			static let noSelectionRegion = NSLocalizedString("DataDonation_Region_NoSelection_Text", comment: "")
			static let noSelectionAgeGroup = NSLocalizedString("DataDonation_AgeGroup_NoSelection_Text", comment: "")
			static let dataProcessingDetails = NSLocalizedString("DataDonation_DetailedInformation_DataProcessing", comment: "")
			static let buttonOK = NSLocalizedString("DataDonation_Button_OK", comment: "")
			static let buttonNOK = NSLocalizedString("DataDonation_Button_NotOK", comment: "")
			
			static let legalTitle = NSLocalizedString("DataDonation_Acknowledgement_Title", tableName: "Localizable.legal", comment: "")
			static let legalAcknowledgementContent = NSLocalizedString("DataDonation_Acknowledgement_Content", tableName: "Localizable.legal", comment: "")
			static let legalAcknowledgementBulletPoint1 = NSLocalizedString("DataDonation_Acknowledgement_BulletPoint_1", tableName: "Localizable.legal", comment: "")
			static let legalAcknowledgementBulletPoint2 = NSLocalizedString("DataDonation_Acknowledgement_BulletPoint_2", tableName: "Localizable.legal", comment: "")
			static let legalAcknowledgementBulletPoint3 = NSLocalizedString("DataDonation_Acknowledgement_BulletPoint_3", tableName: "Localizable.legal", comment: "")
			
		}

		enum DetailedInfo {
			static let title = NSLocalizedString("DetailedInfosDataDonation_Headline", comment: "")
			
			static let legalHeadline = NSLocalizedString("DataDonation_DetailedInformation_Headline", tableName: "Localizable.legal", comment: "")
			static let legalParagraph = NSLocalizedString("DataDonation_DetailedInformation_Text", tableName: "Localizable.legal", comment: "")
			
			static let headline = NSLocalizedString("DetailedInfosDataDonation_SubHead_DataProcessing", comment: "")
			static let paragraph1 = NSLocalizedString("DetailedInfosDataDonation_DataProcessing_Description", comment: "")
			static let paragraph2 = NSLocalizedString("DetailedInfosDataDonation_SubHead_RKI_DataCollection", comment: "")
			static let paragraph3 = NSLocalizedString("DetailedInfosDataDonation_SubHead_RetrievedTestResult", comment: "")
			static let paragraph4 = NSLocalizedString("DetailedInfosDataDonation_SubHead_WarnOthers", comment: "")
			static let paragraph5 = NSLocalizedString("DetailedInfosDataDonation_Misc_SubHead_MiscInformation", comment: "")
			static let paragraph6 = NSLocalizedString("DetailedInfosDataDonation_General_Privacy_Infos", comment: "")
			
			static let bullet01_title = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImproveddRiskDetermination_BulletTitle", comment: "")
			static let bullet01_text = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImproveddRiskDetermination", comment: "")

			static let bullet02_title = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImproveddUserNavigation_BulletTitle", comment: "")
			static let bullet02_text = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImproveddUserNavigation", comment: "")

			static let bullet03_title = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_AppSupport_BulletTitle", comment: "")
			static let bullet03_text = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_AppSupport", comment: "")

			static let bullet04_title = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImprovedStatistics_BulletTitle", comment: "")
			static let bullet04_text = NSLocalizedString("DetailedInfosDataDonation_BulletPoint_ImprovedStatistics", comment: "")
			
			static let bullet05_text = NSLocalizedString("DetailedInfosDataDonation_RKI_DataCollection_BulletPoint_Date", comment: "")
			static let bullet06_text = NSLocalizedString("DetailedInfosDataDonation_RKI_DataCollection_BulletPoint_ChangeOfWarnHistory", comment: "")
			static let bullet07_text = NSLocalizedString("DetailedInfosDataDonation_RKI_DataCollection_BulletPoint_InfoAboutRisk", comment: "")
			static let bullet08_text = NSLocalizedString("DetailedInfosDataDonation_RKI_DataCollection_BulletPoint_RiskStatus_Base", comment: "")
			static let bullet09_text = NSLocalizedString("DetailedInfosDataDonation_RetrievedTestResult_BulletPoint_KindOfTestResult", comment: "")
			static let bullet10_text = NSLocalizedString("DetailedInfosDataDonation_RetrievedTestResult_BulletPoint_CalculatedRisk", comment: "")
			static let bullet11_text = NSLocalizedString("DetailedInfosDataDonation_RetrievedTestResult_BulletPoint_PeriodHighRisk", comment: "")
			static let bullet12_text = NSLocalizedString("DetailedInfosDataDonation_RetrievedTestResult_BulletPoint_PeriodLastInfoHighRisk", comment: "")
			static let bullet13_text = NSLocalizedString("DetailedInfosDataDonation_RetrievedTestResult_BulletPoint_SharedTestResult", comment: "")
			static let bullet14_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_Canceled", comment: "")
			static let bullet15_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_SymptompsStart", comment: "")
			static let bullet16_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_Consent", comment: "")
			static let bullet17_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_HowFar", comment: "")
			static let bullet18_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_HoursUntilReceived", comment: "")
			static let bullet19_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_DaysElapsed", comment: "")
			static let bullet20_text = NSLocalizedString("DetailedInfosDataDonation_WarnOthers_BulletPoint_HoursSinceRegistration", comment: "")
			static let bullet21_text = NSLocalizedString("DetailedInfosDataDonation_Misc_SubHead_BulletPoint_AgeGroup", comment: "")
			static let bullet22_text = NSLocalizedString("DetailedInfosDataDonation_Misc_SubHead_BulletPoint_Region", comment: "")
			static let bullet23_text = NSLocalizedString("DetailedInfosDataDonation_Misc_SubHead_BulletPoint_TechSpecs", comment: "")
		}
		
		enum AppSettings {
			static let ppaSettingsPrivacyInformationBody = NSLocalizedString("ppa_settings_privacy_information_body", tableName: "Localizable.legal", comment: "")
		}
	}

	enum ErrorReport {
		
		// Top ViewController UI
		static let title = NSLocalizedString("ErrorReport_Title", comment: "")
		static let description1 = NSLocalizedString("ErrorReport_Description1", comment: "")
		static let faq = NSLocalizedString("ErrorReport_FAQ", comment: "")
		static let faqURL = NSLocalizedString("errorReport_FAQ_URL", tableName: "Localizable.links", comment: "")
		static let privacyInformation = NSLocalizedString("ErrorReport_PrivacyInformation", comment: "")
		static let detailedInformationTitle = NSLocalizedString("ErrorReport_DetailedInformation_Title", comment: "")
		
		// Bottom ViewController UI
		static let analysisTitle = NSLocalizedString("ErrorReport_Analysis", comment: "")
		static let activeStatusTitle = NSLocalizedString("ErrorReport_ActiveStatus_Title", comment: "")
		static let inactiveStatusTitle = NSLocalizedString("ErrorReport_InactiveStatus_Title", comment: "")
		static let statusProgress = NSLocalizedString("ErrorReport_Progress_Description", comment: "")
		static let startButtonTitle = NSLocalizedString("ErrorReport_StartButtonTitle", comment: "")
		static let stopAndDeleteButtonTitle = NSLocalizedString("ErrorReport_StopAndDeleteButtonTitle", comment: "")
		static let saveButtonTitle = NSLocalizedString("ErrorReport_SaveButtonTitle", comment: "")
		static let sendButtontitle = NSLocalizedString("ErrorReport_SendButtonTitle", comment: "")
		
		// Confirm and Send Reports screen
		static let sendReportsTitle = NSLocalizedString("ErrorReport_SendReports_Title", comment: "")
		static let sendReportsParagraph = NSLocalizedString("ErrorReport_SendReports_Paragraph", comment: "")
		static let sendReportsDetails = NSLocalizedString("ErrorReport_SendReports_Details", comment: "")
		static let sendReportsButtonTitle = NSLocalizedString("ErrorReport_SendReports_Button_Title", comment: "")

		// History ViewController UI
		static let historyTitle = NSLocalizedString("ErrorReport_History_Title", comment: "")
		static let historyDescription = NSLocalizedString("ErrorReport_History_Description", comment: "")
		static let historyCellID = NSLocalizedString("ErrorReport_History_Cell_ID", comment: "")
		static let historyNavigationSubline = NSLocalizedString("ErrorReport_History_Navigation_Subline", comment: "")

		enum Legal {
			static let dataPrivacy_Headline = NSLocalizedString("errorReport_Legal_DataPrivacy_Headline", tableName: "Localizable.legal", comment: "")
			static let dataPrivacy_Bullet1 = NSLocalizedString("errorReport_Legal_DataPrivacy_Bullet1", tableName: "Localizable.legal", comment: "")
			static let dataPrivacy_Bullet2 = NSLocalizedString("errorReport_Legal_DataPrivacy_Bullet2", tableName: "Localizable.legal", comment: "")
			static let dataPrivacy_Bullet3 = NSLocalizedString("errorReport_Legal_DataPrivacy_Bullet3", tableName: "Localizable.legal", comment: "")
			static let dataPrivacy_Bullet4 = NSLocalizedString("errorReport_Legal_DataPrivacy_Bullet4", tableName: "Localizable.legal", comment: "")
			static let dataPrivacy_Bullet5 = NSLocalizedString("errorReport_Legal_DataPrivacy_Bullet5", tableName: "Localizable.legal", comment: "")
			
			static let consent_Headline = NSLocalizedString("errorReport_Legal_Consent_Headline", tableName: "Localizable.legal", comment: "")
			static let consent_Intro = NSLocalizedString("errorReport_Legal_Consent_Intro", tableName: "Localizable.legal", comment: "")
			static let consent_Bullet1_Header = NSLocalizedString("errorReport_Legal_Consent_Bullet1_Header", tableName: "Localizable.legal", comment: "")
			static let consent_Bullet1_Paragraph = NSLocalizedString("errorReport_Legal_Consent_Bullet1_Paragraph", tableName: "Localizable.legal", comment: "")
			static let consent_Bullet2 = NSLocalizedString("errorReport_Legal_Consent_Bullet2", tableName: "Localizable.legal", comment: "")
			static let consent_Last_Paragraph = NSLocalizedString("errorReport_Legal_Consent_LastParagraph", tableName: "Localizable.legal", comment: "")
			
			static let sendReports_Headline = NSLocalizedString("errorReport_Legal_SendReports_Headline", tableName: "Localizable.legal", comment: "")
			static let sendReports_Subline = NSLocalizedString("errorReport_Legal_SendReports_Subline", tableName: "Localizable.legal", comment: "")
			static let sendReports_Bullet1_Part1 = NSLocalizedString("errorReport_Legal_SendReports_Bullet1_Part1", tableName: "Localizable.legal", comment: "")
			static let sendReports_Bullet1_Part2 = NSLocalizedString("errorReport_Legal_SendReports_Bullet1_Part2", tableName: "Localizable.legal", comment: "")
			static let sendReports_Bullet2 = NSLocalizedString("errorReport_Legal_SendReports_Bullet2", tableName: "Localizable.legal", comment: "")
			static let sendReports_Paragraph = NSLocalizedString("errorReport_Legal_SendReports_Paragraph", tableName: "Localizable.legal", comment: "")
		}
		
		static let detailedInfo_Headline = NSLocalizedString("errorReport_DetailedInformation_Headline", comment: "")
		static let detailedInfo_Content1 = NSLocalizedString("errorReport_DetailedInformation_Content1", comment: "")
		static let detailedInfo_Subheadline = NSLocalizedString("ErrorReport_DetailedInformation_Subheadline", comment: "")
		static let detailedInfo_Content2 = NSLocalizedString("ErrorReport_DetailedInformation_Content2", comment: "")
	}

	enum Checkins {
		enum Edit {
			static let primaryButtonTitle = NSLocalizedString("Checkins_Edit_PrimaryButton_Title", comment: "")
			static let sectionHeaderTitle = NSLocalizedString("Checkins_Edit_Section_Title", comment: "")
			static let checkedIn = NSLocalizedString("Checkins_Edit_CheckedIn", comment: "")
			static let checkedOut = NSLocalizedString("Checkins_Edit_CheckedOut", comment: "")
			static let notice = NSLocalizedString("Checkins_Edit_Notice", comment: "")
		}

		enum QRScannerError {
			static let title = NSLocalizedString("Checkin_QR_Scanner_Checkin_Error_Title", comment: "")
			static let invalidURL = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidURL", comment: "")
			static let invalidPayload = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidPayload", comment: "")
			static let invalidVendorData = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidURLVendorData", comment: "")
			static let invalidDescription = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidDescription", comment: "")
			static let invalidAddress = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidAddress", comment: "")
			static let invalidCryptographicSeed = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidCryptographicSeed", comment: "")
			static let invalidTimeStamps = NSLocalizedString("Checkin_QR_Scanner_Error_InvalidTimeStamps", comment: "")
		}

		enum Overview {
			static let title = NSLocalizedString("Checkins_Overview_Title", comment: "")
			static let menuButtonTitle = NSLocalizedString("Checkins_Overview_MenuButtonTitle", comment: "")
			static let scanButtonTitle = NSLocalizedString("Checkins_Overview_ScanButtonTitle", comment: "")
			static let emptyTitle = NSLocalizedString("Checkins_Overview_EmptyTitle", comment: "")
			static let emptyDescription = NSLocalizedString("Checkins_Overview_EmptyDescription", comment: "")
			static let emptyImageDescription = NSLocalizedString("Checkins_Overview_EmptyImageDescription", comment: "")
			static let deleteAllButtonTitle = NSLocalizedString("Checkins_Overview_DeleteAllButtonTitle", comment: "")
			static let itemPrefixCheckIn = NSLocalizedString("Checkins_Overview_Item_Prefix_CheckIn", comment: "")
			static let itemPrefixCheckedOut = NSLocalizedString("Checkins_Overview_Item_Prefix_CheckedOut", comment: "")
			
			static let durationTitle = NSLocalizedString("Checkins_Overview_DurationTitle", comment: "")
			static let checkinTimeTemplate = NSLocalizedString("Checkins_Overview_CheckinTimeTemplate", comment: "")
			static let checkinDateTemplate = NSLocalizedString("Checkins_Overview_CheckinDateTemplate", comment: "")
			static let checkoutButtonTitle = NSLocalizedString("Checkins_Overview_CheckoutButtonTitle", comment: "")

			enum DeleteOneAlert {
				static let title = NSLocalizedString("Checkins_Overview_DeleteOne_AlertTitle", comment: "")
				static let message = NSLocalizedString("Checkins_Overview_DeleteOne_AlertMessage", comment: "")
				static let confirmButtonTitle = NSLocalizedString("Checkins_Overview_DeleteOne_AlertConfirmButtonTitle", comment: "")
				static let cancelButtonTitle = NSLocalizedString("Checkins_Overview_DeleteOne_AlertCancelButtonTitle", comment: "")
			}

			enum DeleteAllAlert {
				static let title = NSLocalizedString("Checkins_Overview_DeleteAll_AlertTitle", comment: "")
				static let message = NSLocalizedString("Checkins_Overview_DeleteAll_AlertMessage", comment: "")
				static let confirmButtonTitle = NSLocalizedString("Checkins_Overview_DeleteAll_AlertConfirmButtonTitle", comment: "")
				static let cancelButtonTitle = NSLocalizedString("Checkins_Overview_DeleteAll_AlertCancelButtonTitle", comment: "")
			}

			enum ActionSheet {
				static let infoTitle = NSLocalizedString("Checkins_Overview_ActionSheet_InfoTitle", comment: "")
				static let editTitle = NSLocalizedString("Checkins_Overview_ActionSheet_EditTitle", comment: "")
			}
		}
		
		enum Information {
			static let title = NSLocalizedString("Checkin_Information_Title", comment: "")
			static let imageDescription = NSLocalizedString("Checkin_Information_ImageDescription", comment: "")
			static let descriptionTitle = NSLocalizedString("Checkin_Information_DescriptionTitle", comment: "")
			static let descriptionSubHeadline = NSLocalizedString("Checkin_Information_DescriptionSubHeadline", comment: "")
			static let itemRiskStatusTitle = NSLocalizedString("Checkin_Information_Item_RiskStatus_Title", comment: "")
			static let itemTimeTitle = NSLocalizedString("Checkin_Information_Item_Time_Title", comment: "")

			static let legalHeadline01 = NSLocalizedString("Checkin_Information_Legal_Headline_1", tableName: "Localizable.legal", comment: "")
			static let legalSubHeadline01 = NSLocalizedString("Checkin_Information_Legal_SubHeadline_1", tableName: "Localizable.legal", comment: "")
			static let legalSubHeadline02 = NSLocalizedString("Checkin_Information_Legal_SubHeadline_2", tableName: "Localizable.legal", comment: "")
			static let legalText01bold = NSLocalizedString("Checkin_Information_Legal_Text_1_bold", tableName: "Localizable.legal", comment: "")
			static let legalText01normal = NSLocalizedString("Checkin_Information_Legal_Text_1_normal", tableName: "Localizable.legal", comment: "")
			static let legalText02 = NSLocalizedString("Checkin_Information_Legal_Text_2", tableName: "Localizable.legal", comment: "")
			static let legalText03 = NSLocalizedString("Checkin_Information_Legal_Text_3", tableName: "Localizable.legal", comment: "")
			static let dataPrivacyTitle = NSLocalizedString("Checkin_Information_Dataprivacy_Title", comment: "")
			static let primaryButtonTitle = NSLocalizedString("Checkin_Information_PrimaryButton_Title", comment: "")
		}
		
		enum Details {
			static let checkInButton = NSLocalizedString("Checkin_Details_CheckIn_Button", comment: "")
			static let hoursShortVersion = NSLocalizedString("Checkin_Details_HoursShortVersion", comment: "")
			static let checkinFor = NSLocalizedString("Checkin_Details_CheckinFor", comment: "")
			static let saveToDiary = NSLocalizedString("Checkin_Details_SaveToDiary", comment: "")
			static let saveSwitch = NSLocalizedString("Checkin_Details_SaveSwitch", comment: "")
			static let saveSwitchOn = NSLocalizedString("Checkin_Details_SaveSwitch_On", comment: "")
			static let saveSwitchOff = NSLocalizedString("Checkin_Details_SaveSwitch_Off", comment: "")
			static let automaticCheckout = NSLocalizedString("Checkin_Details_AutomaticCheckout", comment: "")
			static let eventNotStartedYet = NSLocalizedString("Checkin_Details_EventNotStartedYet", comment: "")
			static let eventEnded = NSLocalizedString("Checkin_Details_EventEnded", comment: "")
		}
	}

	enum Checkout {
		static let notificationTitle = NSLocalizedString("Checkout_Notification_Title", comment: "")
		static let notificationBody = NSLocalizedString("Checkout_Notification_Body", comment: "")
	}

	enum TraceLocations {

		enum unspecified {
			static let title = NSLocalizedString("TraceLocations_Type_Title_Unspecified", comment: "")
		}

		enum permanent {
			static let name = NSLocalizedString("TraceLocations_Section_Title_Permanent", comment: "")

			enum title {
				static let other = NSLocalizedString("TraceLocations_Type_Title_PermanentOther", comment: "")
				static let retail = NSLocalizedString("TraceLocations_Type_Title_PermanentRetail", comment: "")
				static let foodService = NSLocalizedString("TraceLocations_Title_Type_PermanentFoodService", comment: "")
				static let craft = NSLocalizedString("TraceLocations_Type_Title_PermanentCraft", comment: "")
				static let workplace = NSLocalizedString("TraceLocations_Type_Title_PermanentWorkplace", comment: "")
				static let educationalInstitution = NSLocalizedString("TraceLocations_Type_Title_PermanentEducationalInstitution", comment: "")
				static let publicBuilding = NSLocalizedString("TraceLocations_Type_Title_PermanentPublicBuilding", comment: "")
			}

			enum subtitle {
				static let retail = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentRetail", comment: "")
				static let foodService = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentFoodService", comment: "")
				static let craft = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentCraft", comment: "")
				static let workplace = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentWorkplace", comment: "")
				static let educationalInstitution = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentEducationalInstitution", comment: "")
				static let publicBuilding = NSLocalizedString("TraceLocations_Type_Subtitle_PermanentPublicBuilding", comment: "")
			}
		}

		enum temporary {
			static let name = NSLocalizedString("TraceLocations_Section_Title_Temporary", comment: "")

			enum title {
				static let other = NSLocalizedString("TraceLocations_Type_Title_TemporaryOther", comment: "")
				static let culturalEvent = NSLocalizedString("TraceLocations_Type_Title_TemporaryCulturalEvent", comment: "")
				static let clubActivity = NSLocalizedString("TraceLocations_Type_Title_TemporaryClubActivity", comment: "")
				static let privateEvent = NSLocalizedString("TraceLocations_Type_Title_TemporaryPrivateEvent", comment: "")
				static let worshipService = NSLocalizedString("TraceLocations_Type_Title_TemporaryWorshipService", comment: "")
			}
			enum subtitle {
				static let culturalEvent = NSLocalizedString("TraceLocations_Type_Subtitle_TemporaryCulturalEvent", comment: "")
				static let clubActivity = NSLocalizedString("TraceLocations_Type_Subtitle_TemporaryClubActivity", comment: "")
				static let privateEvent = NSLocalizedString("TraceLocations_Type_Subtitle_TemporaryPrivateEvent", comment: "")
			}
		}

		enum Information {
			static let title = NSLocalizedString("TraceLocation_Information_Title", comment: "")
			static let imageDescription = NSLocalizedString("TraceLocation_Information_ImageDescription", comment: "")
			static let descriptionTitle = NSLocalizedString("TraceLocation_Information_DescriptionTitle", comment: "")
			static let descriptionSubHeadline = NSLocalizedString("TraceLocation_Information_DescriptionSubHeadline", comment: "")
			static let itemCheckinRiskStatus = NSLocalizedString("TraceLocation_Information_Item_RiskStatus", comment: "")
			static let itemCheckinTitle = NSLocalizedString("TraceLocation_Information_Item_Checkin", comment: "")
			static let itemContactTitle = NSLocalizedString("TraceLocation_Information_Item_RenewQRCode", comment: "")
			static let legalHeadline = NSLocalizedString("TraceLocation_Information_Legal_Headline_1", tableName: "Localizable.legal", comment: "")

			static let legalText01 = NSLocalizedString("TraceLocation_Information_Legal_Text_1", tableName: "Localizable.legal", comment: "")
			static let legalText02bold = NSLocalizedString("TraceLocation_Information_Legal_Text_2_bold", tableName: "Localizable.legal", comment: "")
			static let legalText02 = NSLocalizedString("TraceLocation_Information_Legal_Text_2", tableName: "Localizable.legal", comment: "")
			static let legalText03bold = NSLocalizedString("TraceLocation_Information_Legal_Text_3_bold", tableName: "Localizable.legal", comment: "")
			static let legalText03 = NSLocalizedString("TraceLocation_Information_Legal_Text_3", tableName: "Localizable.legal", comment: "")
			static let legalText04 = NSLocalizedString("TraceLocation_Information_Legal_Text_4", tableName: "Localizable.legal", comment: "")
			static let legalText05 = NSLocalizedString("TraceLocation_Information_Legal_Text_5", tableName: "Localizable.legal", comment: "")
			static let dataPrivacyTitle = NSLocalizedString("Checkin_Information_Dataprivacy_Title", comment: "")
			static let primaryButtonTitle = NSLocalizedString("TraceLocation_Information_PrimaryButton_Title", comment: "")
		}

		enum Overview {
			static let title = NSLocalizedString("TraceLocations_Overview_Title", comment: "")
			static let menuButtonTitle = NSLocalizedString("TraceLocations_Overview_MenuButtonTitle", comment: "")
			static let addButtonTitle = NSLocalizedString("TraceLocations_Overview_AddButtonTitle", comment: "")
			static let emptyTitle = NSLocalizedString("TraceLocations_Overview_EmptyTitle", comment: "")
			static let emptyDescription = NSLocalizedString("TraceLocations_Overview_EmptyDescription", comment: "")
			static let emptyImageDescription = NSLocalizedString("TraceLocations_Overview_EmptyImageDescription", comment: "")
			static let deleteAllButtonTitle = NSLocalizedString("TraceLocations_Overview_DeleteAllButtonTitle", comment: "")
			static let itemPrefix = NSLocalizedString("TraceLocations_Overview_Item_Prefix", comment: "")

			static let selfCheckinButtonTitle = NSLocalizedString("TraceLocations_Overview_SelfCheckinButtonTitle", comment: "")

			enum DeleteOneAlert {
				static let title = NSLocalizedString("TraceLocations_Overview_DeleteOne_AlertTitle", comment: "")
				static let message = NSLocalizedString("TraceLocations_Overview_DeleteOne_AlertMessage", comment: "")
				static let confirmButtonTitle = NSLocalizedString("TraceLocations_Overview_DeleteOne_AlertConfirmButtonTitle", comment: "")
				static let cancelButtonTitle = NSLocalizedString("TraceLocations_Overview_DeleteOne_AlertCancelButtonTitle", comment: "")
			}

			enum DeleteAllAlert {
				static let title = NSLocalizedString("TraceLocations_Overview_DeleteAll_AlertTitle", comment: "")
				static let message = NSLocalizedString("TraceLocations_Overview_DeleteAll_AlertMessage", comment: "")
				static let confirmButtonTitle = NSLocalizedString("TraceLocations_Overview_DeleteAll_AlertConfirmButtonTitle", comment: "")
				static let cancelButtonTitle = NSLocalizedString("TraceLocations_Overview_DeleteAll_AlertCancelButtonTitle", comment: "")
			}

			enum ActionSheet {
				static let infoTitle = NSLocalizedString("TraceLocations_Overview_ActionSheet_InfoTitle", comment: "")
				static let onBehalfCheckinSubmissionTitle = NSLocalizedString("TraceLocations_Overview_ActionSheet_OnBehalfCheckinSubmissionTitle", comment: "")
				static let editTitle = NSLocalizedString("TraceLocations_Overview_ActionSheet_EditTitle", comment: "")
			}
		}

		enum Details {
			static let printVersionButtonTitle = NSLocalizedString("TraceLocations_Details_PrintVersionButtonTitle", comment: "")
			static let duplicateButtonTitle = NSLocalizedString("TraceLocations_Details_DuplicateButtonTitle", comment: "")
		}


		enum TypeSelection {
			static let title = NSLocalizedString("TraceLocations_TypeSelection_Title", comment: "")

			static let otherLocationTitle = NSLocalizedString("TraceLocations_TypeSelection_OtherLocation_Title", comment: "")
			static let otherEventTitle = NSLocalizedString("TraceLocations_TypeSelection_OtherEvent_Title", comment: "")
		}

		enum Configuration {
			static let title = NSLocalizedString("TraceLocations_Configuration_Title", comment: "")
			static let descriptionPlaceholder = NSLocalizedString("TraceLocations_Configuration_DescriptionPlaceholder", comment: "")
			static let addressPlaceholder = NSLocalizedString("TraceLocations_Configuration_AddressPlaceholder", comment: "")
			static let startDateTitle = NSLocalizedString("TraceLocations_Configuration_StartDateTitle", comment: "")
			static let endDateTitle = NSLocalizedString("TraceLocations_Configuration_EndDateTitle", comment: "")
			static let defaultCheckinLengthTitle = NSLocalizedString("TraceLocations_Configuration_DefaultCheckinLengthTitle", comment: "")
			static let defaultCheckinLengthFootnote = NSLocalizedString("TraceLocations_Configuration_DefaultCheckinLengthFootnote", comment: "")
			static let primaryButtonTitle = NSLocalizedString("TraceLocations_Configuration_PrimaryButtonTitle", comment: "")
			static let hoursUnit = NSLocalizedString("TraceLocations_Configuration_HoursUnit", comment: "")
			static let savingErrorMessage = NSLocalizedString("TraceLocations_Configuration_SavingErrorMessage", comment: "")
		}
	}

	enum OnBehalfCheckinSubmission {

		enum Info {
			static let title = NSLocalizedString("OnBehalfCheckinSubmission_Info_Title", comment: "")
			static let subtitle = NSLocalizedString("OnBehalfCheckinSubmission_Info_Subtitle", comment: "")
			static let description = NSLocalizedString("OnBehalfCheckinSubmission_Info_Description", comment: "")
			static let bulletPoint1 = NSLocalizedString("OnBehalfCheckinSubmission_Info_BulletPoint1", comment: "")
			static let bulletPoint2 = NSLocalizedString("OnBehalfCheckinSubmission_Info_BulletPoint2", comment: "")
			static let primaryButtonTitle = NSLocalizedString("OnBehalfCheckinSubmission_Info_PrimaryButtonTitle", comment: "")
		}

		enum TraceLocationSelection {
			static let title = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_Title", comment: "")
			static let description = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_Description", comment: "")
			static let scanButtonTitle = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_ScanButtonTitle", comment: "")
			static let primaryButtonTitle = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_PrimaryButtonTitle", comment: "")

			enum EmptyState {
				static let title = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_EmptyState_Title", comment: "")
				static let description = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_EmptyState_Description", comment: "")
				static let imageDescription = NSLocalizedString("OnBehalfCheckinSubmission_TraceLocationSelection_EmptyState_ImageDescription", comment: "")
			}
		}

		enum DateTimeSelection {
			static let title = NSLocalizedString("OnBehalfCheckinSubmission_DateTimeSelection_Title", comment: "")
			static let description = NSLocalizedString("OnBehalfCheckinSubmission_DateTimeSelection_Description", comment: "")
			static let start = NSLocalizedString("OnBehalfCheckinSubmission_DateTimeSelection_Start", comment: "")
			static let duration = NSLocalizedString("OnBehalfCheckinSubmission_DateTimeSelection_Duration", comment: "")
			static let primaryButtonTitle = NSLocalizedString("OnBehalfCheckinSubmission_DateTimeSelection_PrimaryButtonTitle", comment: "")
		}

		enum TANInput {
			static let title = NSLocalizedString("OnBehalfCheckinSubmission_TANInput_Title", comment: "")
			static let description = NSLocalizedString("OnBehalfCheckinSubmission_TANInput_Description", comment: "")
			static let primaryButtonTitle = NSLocalizedString("OnBehalfCheckinSubmission_TANInput_PrimaryButtonTitle", comment: "")
		}

		enum ThankYou {
			static let title = NSLocalizedString("OnBehalfCheckinSubmission_ThankYou_Title", comment: "")
			static let description = NSLocalizedString("OnBehalfCheckinSubmission_ThankYou_Description", comment: "")
		}

		enum Error {
			static let failed = NSLocalizedString("OnBehalfCheckinSubmissionError_Failed", comment: "")
			static let invalidTAN = NSLocalizedString("OnBehalfCheckinSubmissionError_InvalidTAN", comment: "")
			static let tryAgain = NSLocalizedString("OnBehalfCheckinSubmissionError_TryAgain", comment: "")
			static let noNetwork = NSLocalizedString("OnBehalfCheckinSubmissionError_NoNetwork", comment: "")
		}

	}

	enum AntigenProfile {
		
		enum Create {
			static let title = NSLocalizedString("AntigenProfile_Create_Title", comment: "")
			static let description = NSLocalizedString("AntigenProfile_Create_Description", comment: "")
			static let firstNameTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_FirstNamePlaceholder", comment: "")
			static let lastNameTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_LastNamePlaceholder", comment: "")
			static let birthDateTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_BirthDatePlaceholder", comment: "")
			static let streetTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_StreetPlaceholder", comment: "")
			static let postalCodeTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_PostalCodePlaceholder", comment: "")
			static let cityTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_CityPlaceholder", comment: "")
			static let phoneNumberTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_PhoneNumberPlaceholder", comment: "")
			static let emailAddressTextFieldPlaceholder = NSLocalizedString("AntigenProfile_Create_EmailAddressPlaceholder", comment: "")
			static let saveButtonTitle = NSLocalizedString("AntigenProfile_Create_Save_Button_Title", comment: "")
		}
		
		enum Profile {
			static let infoActionTitle = NSLocalizedString("AntigenProfile_Info_Action_Title", comment: "")
			static let editActionTitle = NSLocalizedString("AntigenProfile_Edit_Action_Title", comment: "")
			static let deleteActionTitle = NSLocalizedString("AntigenProfile_Delete_Action_Title", comment: "")
			static let cancelActionTitle = NSLocalizedString("AntigenProfile_Cancel_Action_Title", comment: "")
			static let deleteAlertTitle = NSLocalizedString("AntigenProfile_Delete_Alert_Title", comment: "")
			static let deleteAlertDescription = NSLocalizedString("AntigenProfile_Delete_Alert_Description", comment: "")
			static let deleteAlertDeleteButtonTitle = NSLocalizedString("AntigenProfile_Delete_Alert_Delete_Button_Title", comment: "")
		}
	}

	enum CovPass {
		enum Information {
			static let title = NSLocalizedString("CovPass_Check_Info_Title", comment: "")
			static let body = NSLocalizedString("CovPass_Check_Info_body", comment: "")
			static let faq = NSLocalizedString("CovPass_Check_Info_faq", comment: "")
			static let faqLink = NSLocalizedString("CovPass_Check_FAQLink", tableName: "Localizable.links", comment: "")
			static let section01 = NSLocalizedString("CovPass_Check_Info_text01", comment: "")
			static let section02 = NSLocalizedString("CovPass_Check_Info_text02", comment: "")
			static let section03 = NSLocalizedString("CovPass_Check_Info_text03", comment: "")
		}
	}

	enum HealthCertificate {

		enum UnifiedQRCode {
			static let notice = NSLocalizedString("HealthCertificate_unified_QR_code_notice", comment: "")
		}

		enum Overview {
			static let title = NSLocalizedString("HealthCertificate_Overview_title", comment: "")
			static let addCertificate = NSLocalizedString("HealthCertificate_Overview_add", comment: "")
			static let emptyTitle = NSLocalizedString("HealthCertificate_Overview_EmptyTitle", comment: "")
			static let emptyDescription = NSLocalizedString("HealthCertificate_Overview_EmptyDescription", comment: "")
			static let emptyImageDescription = NSLocalizedString("HealthCertificate_Overview_EmptyImageDescription", comment: "")
			static let covidTitle = NSLocalizedString("HealthCertificate_Overview_Covid_Title", comment: "")
			static let covidDescription = NSLocalizedString("HealthCertificate_Overview_Covid_Certificate_Description", comment: "")
			static let news = NSLocalizedString("HealthCertificate_Overview_News", comment: "")

			enum TestCertificateRequest {
				static let title = NSLocalizedString("TestCertificateRequest_title", comment: "")
				static let loadingSubtitle = NSLocalizedString("TestCertificateRequest_loadingSubtitle", comment: "")
				static let errorSubtitle = NSLocalizedString("TestCertificateRequest_errorSubtitle", comment: "")
				static let registrationDate = NSLocalizedString("TestCertificateRequest_registrationDate", comment: "")
				static let loadingStateDescription = NSLocalizedString("TestCertificateRequest_loadingStateDescription", comment: "")
				static let tryAgainButtonTitle = NSLocalizedString("TestCertificateRequest_tryAgainButtonTitle", comment: "")
				static let removeButtonTitle = NSLocalizedString("TestCertificateRequest_removeButtonTitle", comment: "")

				enum ErrorAlert {
					static let title = NSLocalizedString("TestCertificateRequest_ErrorAlert_title", comment: "")
					static let buttonTitle = NSLocalizedString("TestCertificateRequest_ErrorAlert_Button_title", comment: "")
				}

				enum DeleteAlert {
					static let title = NSLocalizedString("TestCertificateRequest_RemoveAlert_title", comment: "")
					static let message = NSLocalizedString("TestCertificateRequest_RemoveAlert_message", comment: "")
					static let cancelButtonTitle = NSLocalizedString("TestCertificateRequest_RemoveAlert_CancelButton_title", comment: "")
					static let deleteButtonTitle = NSLocalizedString("TestCertificateRequest_RemoveAlert_DeleteButton_title", comment: "")
				}

				enum Error {
					static let clientErrorCallHotline = NSLocalizedString("TestCertificateRequest_Error_CLIENT_ERROR_CALL_HOTLINE", comment: "")
					static let dccExpired = NSLocalizedString("TestCertificateRequest_Error_DCC_EXPIRED", comment: "")
					static let dccNotSupportedByLab = NSLocalizedString("TestCertificateRequest_Error_DCC_NOT_SUPPORTED_BY_LAB", comment: "")
					static let e2eErrorCallHotline = NSLocalizedString("TestCertificateRequest_Error_E2E_ERROR_CALL_HOTLINE", comment: "")
					static let noNetwork = NSLocalizedString("TestCertificateRequest_Error_NO_NETWORK", comment: "")
					static let tryAgain = NSLocalizedString("TestCertificateRequest_Error_TRY_AGAIN", comment: "")
					static let tryAgainDCCNotAvailableYet = NSLocalizedString("TestCertificateRequest_Error_TRY_AGAIN_DCC_NOT_AVAILABLE_YET", comment: "")
					static let dgcNotSupportedByLab = NSLocalizedString("TestCertificateRequest_Error_DGC_NOT_SUPPORTED_BY_LAB", comment: "")
					static let faqDescription = NSLocalizedString("TestCertificate_Error_FAQ_Description", comment: "")
					static let faqButtonTitle = NSLocalizedString("TestCertificate_Error_FAQ_Button_Title", comment: "")
				}
			}
		}

		enum Info {
			static let title = NSLocalizedString("HealthCertificate_Info_Title", comment: "")
			static let imageDescription = NSLocalizedString("HealthCertificate_Info_imageDescription", comment: "")
			static let description = NSLocalizedString("HealthCertificate_Info_description", comment: "")
			static let section01 = NSLocalizedString("HealthCertificate_Info_section01", comment: "")
			static let section02 = NSLocalizedString("HealthCertificate_Info_section02", comment: "")
			static let section03 = NSLocalizedString("HealthCertificate_Info_section03", comment: "")
			static let section04 = NSLocalizedString("HealthCertificate_Info_section04", comment: "")

			enum Legal {
				static let headline = NSLocalizedString("HealthCertificate_Info_Legal_headline", tableName: "Localizable.legal", comment: "")
				static let section01 = NSLocalizedString("HealthCertificate_Info_Legal_section01", tableName: "Localizable.legal", comment: "")
				static let section02 = NSLocalizedString("HealthCertificate_Info_Legal_section02", tableName: "Localizable.legal", comment: "")
				static let section03 = NSLocalizedString("HealthCertificate_Info_Legal_section03", tableName: "Localizable.legal", comment: "")
				static let section04 = NSLocalizedString("HealthCertificate_Info_Legal_section04", tableName: "Localizable.legal", comment: "")
			}

			static let disclaimer = NSLocalizedString("HealthCertificate_Info_disclaimer", tableName: "Localizable.legal", comment: "")
			static let primaryButton = NSLocalizedString("HealthCertificate_Info_primaryButton", comment: "")
		}

		enum Person {
			static let title = NSLocalizedString("HealthCertifiedPerson_title", comment: "")

			static let QRCodeImageDescription = NSLocalizedString("HealthCertifiedPerson_QRCode_Image_Description", comment: "")
			static let validationButtonTitle = NSLocalizedString("HealthCertifiedPerson_validationButtonTitle", comment: "")
			static let currentlyUsedCertificate = NSLocalizedString("HealthCertifiedPerson_currentlyUsedCertificate", comment: "")
			static let newlyAddedCertificate = NSLocalizedString("HealthCertifiedPerson_newlyAddedCertificate", comment: "")

			enum VaccinationHint {
				static let title = NSLocalizedString("HealthCertifiedPerson_VaccinationHint_title", comment: "")
				static let daysSinceLastVaccination = NSLocalizedString("HealthCertifiedPerson_daysSinceLastVaccination", comment: "")
				static let partiallyVaccinated = NSLocalizedString("HealthCertifiedPerson_partiallyVaccinated", comment: "")
				static let daysUntilCompleteProtection = NSLocalizedString("HealthCertifiedPerson_daysUntilCompleteProtection", comment: "")
				static let completelyProtected = NSLocalizedString("HealthCertifiedPerson_completelyProtected", comment: "")
				static let boosterRuleFAQ = NSLocalizedString("HealthCertifiedPerson_boosterRuleFAQ", comment: "")
				static let boosterRuleFAQPlaceholder = NSLocalizedString("HealthCertifiedPerson_boosterRuleFAQ_placeholder_FAQ", comment: "")
			}

			enum PreferredPerson {
				static let dateOfBirth = NSLocalizedString("HealthCertifiedPerson_dateOfBirth", comment: "")
				static let description = NSLocalizedString("HealthCertifiedPerson_preferredPersonDescription", comment: "")
			}

			enum VaccinationCertificate {
				static let headline = NSLocalizedString("HealthCertifiedPerson_VaccinationCertificate_headline", comment: "")
				static let vaccinationCount = NSLocalizedString("HealthCertifiedPerson_VaccinationCertificate_vaccinationCount", comment: "")
				static let vaccinationDate = NSLocalizedString("HealthCertifiedPerson_VaccinationCertificate_vaccinationDate", comment: "")
			}

			enum TestCertificate {
				static let headline = NSLocalizedString("HealthCertifiedPerson_TestCertificate_headline", comment: "")
				static let pcrTest = NSLocalizedString("HealthCertifiedPerson_TestCertificate_pcrTest", comment: "")
				static let antigenTest = NSLocalizedString("HealthCertifiedPerson_TestCertificate_antigenTest", comment: "")
				static let sampleCollectionDate = NSLocalizedString("HealthCertifiedPerson_TestCertificate_sampleCollectionDate", comment: "")
			}

			enum RecoveryCertificate {
				static let headline = NSLocalizedString("HealthCertifiedPerson_RecoveryCertificate_headline", comment: "")
				static let validityDate = NSLocalizedString("HealthCertifiedPerson_RecoveryCertificate_validityDate", comment: "")
			}

		}

		enum Details {
			static let vaccinationCount = NSLocalizedString("HealthCertificate_Details_vaccinationCount", comment: "")
			static let vaccinationCertificate = NSLocalizedString("HealthCertificate_Details_certificate", comment: "")
			static let euCovidCertificate =
				NSLocalizedString("HealthCertificate_Details_EU_Covid_Certificate", comment: "")
			static let QRCodeImageDescription = NSLocalizedString("HealthCertificate_Details_QRCode_Image_Description", comment: "")
			static let certificateCount = NSLocalizedString("HealthCertificate_Details_certificateCount", comment: "")
			static let validity = NSLocalizedString("HealthCertificate_Details_validity", comment: "")
			static let dateOfBirth = NSLocalizedString("HealthCertificate_Details_dateOfBirth", comment: "")
			static let dateOfVaccination = NSLocalizedString("HealthCertificate_Details_dateOfVaccination", comment: "")
			static let vaccine = NSLocalizedString("HealthCertificate_Details_vaccine", comment: "")
			static let vaccineType = NSLocalizedString("HealthCertificate_Details_vaccineType", comment: "")
			static let manufacture = NSLocalizedString("HealthCertificate_Details_manufacture", comment: "")
			static let issuer = NSLocalizedString("HealthCertificate_Details_issuer", comment: "")
			static let country = NSLocalizedString("HealthCertificate_Details_country", comment: "")
			static let identifier = NSLocalizedString("HealthCertificate_Details_identifier", comment: "")
			static let validationButtonTitle = NSLocalizedString("HealthCertificate_Details_validationButtonTitle", comment: "")
			static let deleteButtonTitle = NSLocalizedString("HealthCertificate_Details_deleteButtonTitle", comment: "")
			static let expirationDateTitle = NSLocalizedString("HealthCertificate_Details_expirationDateTitle", comment: "")
			static let expirationDatePlaceholder = NSLocalizedString("HealthCertificate_Details_expirationDatePlaceholder", comment: "")
			static let expirationDateDetails = NSLocalizedString("HealthCertificate_Details_expirationDateDetails", comment: "")
			static let moreButtonTitle = NSLocalizedString("HealthCertificate_Details_moreButtonTitle", comment: "")
			
			enum VaccinationCertificate {
				static let oneOfOneHint = NSLocalizedString("VaccinationCertificate_Details_OneOfOneHint", comment: "")
			}

			enum TestCertificate {
				static let title = NSLocalizedString("TestCertificate_Details_title", comment: "")
				static let subtitle = NSLocalizedString("TestCertificate_Details_subtitle", comment: "")
				static let primaryButton = NSLocalizedString("TestCertificate_Details_primaryButton", comment: "")
			}

			enum RecoveryCertificate {
				static let title = NSLocalizedString("RecoveryCertificate_Details_title", comment: "")
				static let subtitle = NSLocalizedString("RecoveryCertificate_Details_subtitle", comment: "")
				static let primaryButton = NSLocalizedString("RecoveryCertificate_Details_primaryButton", comment: "")
			}
		}
		
		enum PrintPDF {
			static let showVersion = NSLocalizedString("HealthCertificate_PrintPdf_showPrintableVersion", comment: "")
			static let cancel = NSLocalizedString("HealthCertificate_PrintPdf_cancelActionSheet", comment: "")
			static let shareTitle = NSLocalizedString("HealthCertificate_PrintPdf_Share_title", comment: "")
			
			enum Info {
				static let title = NSLocalizedString("HealthCertificate_PrintPdf_Info_title", comment: "")
				static let section01 = NSLocalizedString("HealthCertificate_PrintPdf_Info_section01", comment: "")
				static let section02 = NSLocalizedString("HealthCertificate_PrintPdf_Info_section02", comment: "")
				static let section03 = NSLocalizedString("HealthCertificate_PrintPdf_Info_section03", comment: "")
				static let primaryButton = NSLocalizedString("HealthCertificate_PrintPdf_Info_primaryButton", comment: "")
			}
			
			enum ErrorAlert {
				enum pdfGeneration {
					static let title = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_Title", comment: "")
					static let message = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_Message", comment: "")
					static let faq = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_FAQ", comment: "")
					static let ok = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_OK", comment: "")
				}
				enum fetchValueSets {
					static let title = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_ValueSetsFetching_Title", comment: "")
					static let message = NSLocalizedString("HealthCertificate_PrintPdf_ErrorAlert_ValueSetsFetching_Message", comment: "")
				}
			}
		}

		enum ValidityState {
			static let expiringSoon = NSLocalizedString("HealthCertificate_ValidityState_ExpiringSoon", comment: "")
			static let expiringSoonDescription = NSLocalizedString("HealthCertificate_ValidityState_ExpiringSoon_description", comment: "")
			static let expired = NSLocalizedString("HealthCertificate_ValidityState_Expired", comment: "")
			static let expiredDescription = NSLocalizedString("HealthCertificate_ValidityState_Expired_description", comment: "")
			static let invalid = NSLocalizedString("HealthCertificate_ValidityState_Invalid", comment: "")
			static let invalidDescription = NSLocalizedString("HealthCertificate_ValidityState_Invalid_description", comment: "")
			static let blocked = NSLocalizedString("HealthCertificate_ValidityState_Blocked", comment: "")
			static let blockedDescription = NSLocalizedString("HealthCertificate_ValidityState_Blocked_description", comment: "")
		}

		enum Alert {
			static let deleteButton = NSLocalizedString("HealthCertificate_Alert_deleteButton", comment: "")
			static let cancelButton = NSLocalizedString("HealthCertificate_Alert_cancelButton", comment: "")

			enum VaccinationCertificate {
				static let title = NSLocalizedString("VaccinationCertificate_Alert_title", comment: "")
			 static let message = NSLocalizedString("VaccinationCertificate_Alert_message", comment: "")
			}

			enum TestCertificate {
				static let title = NSLocalizedString("TestCertificate_Alert_title", comment: "")
				static let message = NSLocalizedString("TestCertificate_Alert_message", comment: "")
			}

			enum RecoveryCertificate {
				static let title = NSLocalizedString("RecoveryCertificate_Alert_title", comment: "")
				static let message = NSLocalizedString("RecoveryCertificate_Alert_message", comment: "")
			}
		}

		enum Error {
			static let title = NSLocalizedString("HealthCertificate_Error_Title", comment: "")
			static let faqDescription = NSLocalizedString("HealthCertificate_Error_FAQ_Description", comment: "")
			static let faqButtonTitle = NSLocalizedString("HealthCertificate_Error_FAQ_Button_Title", comment: "")
			static let hcAlreadyRegistered = NSLocalizedString("HealthCertificate_Error_HC_ALREADY_REGISTERED", comment: "")
			static let hcInvalid = NSLocalizedString("HealthCertificate_Error_HC_INVALID", comment: "")
			static let hcNotSupported = NSLocalizedString("HealthCertificate_Error_HC_NOT_SUPPORTED", comment: "")
			static let hcQRCodeError = NSLocalizedString("HealthCertificate_Error_HC_QR_CODE_ERROR", comment: "")

			static let invalidSignatureTitle = NSLocalizedString("HealthCertificate_Error_invalidSignature_title", comment: "")
			static let invalidSignatureText = NSLocalizedString("HealthCertificate_Error_invalidSignature_msg", comment: "")
			static let invalidSignatureFAQButtonTitle = NSLocalizedString("HealthCertificate_Error_invalidSignature_FAQ_Button_Title", comment: "")

		}

		enum Validation {
			static let title = NSLocalizedString("HealthCertificate_Validation_Title", comment: "")
			static let countrySelectionTitle = NSLocalizedString("HealthCertificate_Validation_CountrySelection_Title", comment: "")
			static let dateTimeSelectionTitle = NSLocalizedString("HealthCertificate_Validation_DateTimeSelection_Title", comment: "")
			static let dateTimeSelectionInfo = NSLocalizedString("HealthCertificate_Validation_DateTimeSelection_Info", comment: "")
			static let body1 = NSLocalizedString("HealthCertificate_Validation_Body1", comment: "")
			static let headline1 = NSLocalizedString("HealthCertificate_Validation_Headline1", comment: "")
			static let body2 = NSLocalizedString("HealthCertificate_Validation_Body2", comment: "")
			static let headline2 = NSLocalizedString("HealthCertificate_Validation_Headline2", comment: "")
			static let bullet1 = NSLocalizedString("HealthCertificate_Validation_Bullet1", comment: "")
			static let bullet2 = NSLocalizedString("HealthCertificate_Validation_Bullet2", comment: "")
			static let bullet4 = NSLocalizedString("HealthCertificate_Validation_Bullet4", comment: "")
			static let legalTitle = NSLocalizedString("HealthCertificate_Validation_Legal_Title", comment: "")
			static let legalDescription = NSLocalizedString("HealthCertificate_Validation_Legal_Description", comment: "")
			static let body4 = NSLocalizedString("HealthCertificate_Validation_Body4", comment: "")
			static let buttonTitle = NSLocalizedString("HealthCertificate_Validation_ButtonTitle", comment: "")
			static let moreInformation = NSLocalizedString("HealthCertificate_Validation_Result_moreInformation", comment: "")
			static let moreInformationPlaceholderFAQ = NSLocalizedString("HealthCertificate_Validation_Result_moreInformation_placeholder_FAQ", comment: "")

			enum Info {
				static let imageDescription = NSLocalizedString("HealthCertificate_Validation_Info_imageDescription", comment: "")
				static let title = NSLocalizedString("HealthCertificate_Validation_Info_title", comment: "")
				static let byCar = NSLocalizedString("HealthCertificate_Validation_Info_byCar", comment: "")
				static let byPlane = NSLocalizedString("HealthCertificate_Validation_Info_byPlane", comment: "")
			}

			enum Error {
				static let title = NSLocalizedString("HealthCertificate_Validation_Error_Title", comment: "")
				static let tryAgain = NSLocalizedString("HealthCertificate_Validation_Error_TRY_AGAIN", comment: "")
				static let noNetwork = NSLocalizedString("HealthCertificate_Validation_Error_NO_NETWORK", comment: "")
			}

			enum Result {
				static let validationParameters = NSLocalizedString("HealthCertificate_Validation_Result_validationParameters", comment: "")
				static let acceptanceRule = NSLocalizedString("HealthCertificate_Validation_Result_acceptanceRule", comment: "")
				static let invalidationRule = NSLocalizedString("HealthCertificate_Validation_Result_invalidationRule", comment: "")

				enum Passed {
					static let title = NSLocalizedString("HealthCertificate_Validation_Passed_title", comment: "")
					static let unknownTitle = NSLocalizedString("HealthCertificate_Validation_Passed_unknownTitle", comment: "")
					static let subtitle = NSLocalizedString("HealthCertificate_Validation_Passed_subtitle", comment: "")
					static let unknownSubtitle = NSLocalizedString("HealthCertificate_Validation_Passed_unknownSubtitle", comment: "")
					static let description = NSLocalizedString("HealthCertificate_Validation_Passed_description", comment: "")
					static let hintsTitle = NSLocalizedString("HealthCertificate_Validation_Passed_hintsTitle", comment: "")
					static let hint1 = NSLocalizedString("HealthCertificate_Validation_Passed_hint1", comment: "")
					static let hint2 = NSLocalizedString("HealthCertificate_Validation_Passed_hint2", comment: "")
					static let hint4 = NSLocalizedString("HealthCertificate_Validation_Passed_hint4", comment: "")
					static let primaryButtonTitle = NSLocalizedString("HealthCertificate_Validation_Passed_primaryButtonTitle", comment: "")
				}

				enum Open {
					static let title = NSLocalizedString("HealthCertificate_Validation_Open_title", comment: "")
					static let subtitle = NSLocalizedString("HealthCertificate_Validation_Open_subtitle", comment: "")
					static let openSectionTitle = NSLocalizedString("HealthCertificate_Validation_Open_openSectionTitle", comment: "")
					static let openSectionDescription = NSLocalizedString("HealthCertificate_Validation_Open_openSectionDescription", comment: "")
				}

				enum Failed {
					static let title = NSLocalizedString("HealthCertificate_Validation_Failed_title", comment: "")
					static let subtitle = NSLocalizedString("HealthCertificate_Validation_Failed_subtitle", comment: "")
					static let failedSectionTitle = NSLocalizedString("HealthCertificate_Validation_Failed_failedSectionTitle", comment: "")
					static let failedSectionDescription = NSLocalizedString("HealthCertificate_Validation_Failed_failedSectionDescription", comment: "")
					static let openSectionTitle = NSLocalizedString("HealthCertificate_Validation_Failed_openSectionTitle", comment: "")
					static let openSectionDescription = NSLocalizedString("HealthCertificate_Validation_Failed_openSectionDescription", comment: "")
				}

				enum TechnicalFailed {
					static let title = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_title", comment: "")
					static let subtitle = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_subtitle", comment: "")
					static let failedSectionTitle = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_failedSectionTitle", comment: "")
					static let failedSectionDescription = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_failedSectionDescription", comment: "")
					static let certificateNotValid = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_certificateNotValid", comment: "")
					static let technicalExpirationDatePassed = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_technicalExpirationDatePassed", comment: "")
					static let expirationDateTitle = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_expirationDateTitle", comment: "")
					static let expirationDate = NSLocalizedString("HealthCertificate_Validation_TechnicalFailed_expirationDate", comment: "")
				}
			}
		}
	}

	enum UniversalQRScanner {
		static let scannerTitle = NSLocalizedString("UniversalQRScanner_ScannerTitle", comment: "")
		static let instructionTitle = NSLocalizedString("UniversalQRScanner_InstructionTitle", comment: "")
		static let instructionDescription = NSLocalizedString("UniversalQRScanner_InstructionDescription", comment: "")

		static let fileButtonTitle = NSLocalizedString("UniversalQRScanner_FileButtonTitle", comment: "")
		static let flashButtonAccessibilityLabel = NSLocalizedString("UniversalQRScanner_CameraFlash", comment: "")
		static let flashButtonAccessibilityOnValue = NSLocalizedString("UniversalQRScanner_CameraFlash_On", comment: "")
		static let flashButtonAccessibilityOffValue = NSLocalizedString("UniversalQRScanner_CameraFlash_Off", comment: "")
		static let flashButtonAccessibilityEnableAction = NSLocalizedString("UniversalQRScanner_CameraFlash_Enable", comment: "")
		static let flashButtonAccessibilityDisableAction = NSLocalizedString("UniversalQRScanner_CameraFlash_Disable", comment: "")

		static let certificateRestoredFromBinAlertTitle = NSLocalizedString("UniversalQRScanner_RestoredFromBinAlert_Title", comment: "")
		static let certificateRestoredFromBinAlertMessage = NSLocalizedString("UniversalQRScanner_RestoredFromBinAlert_Message", comment: "")

		static let testRestoredFromBinAlertTitle = NSLocalizedString("UniversalQRScanner_TestRestoredFromBinAlert_Title", comment: "")
		static let testRestoredFromBinAlertMessage = NSLocalizedString("UniversalQRScanner_TestRestoredFromBinAlert_Message", comment: "")

		enum MaxPersonAmountAlert {
			static let warningTitle = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_warningTitle", comment: "")
			static let errorTitle = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_errorTitle", comment: "")
			static let message = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_message", comment: "")
			static let covPassCheckButton = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_covPassCheckButton", comment: "")
			static let covPassCheckLink = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_CovPassCheckLink", tableName: "Localizable.links", comment: "")
			static let faqButton = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_faqButton", comment: "")
			static let faqLink = NSLocalizedString("UniversalQRScanner_MaxPersonAmountAlert_FAQLink", tableName: "Localizable.links", comment: "")
		}

		enum Error {
			enum CameraPermissionDenied {
				static let title = NSLocalizedString("UniversalQRScanner_Error_cameraPermissionDenied_title", comment: "")
				static let message = NSLocalizedString("UniversalQRScanner_Error_cameraPermissionDenied", comment: "")
				static let settingsButton = NSLocalizedString("UniversalQRScanner_Error_cameraPermissionDenied_settingsButton", comment: "")
			}
			static let unsupportedQRCode = NSLocalizedString("UniversalQRScanner_Error_unsupportedQRCode", comment: "")
		}

		enum Tooltip {
			static let title = NSLocalizedString("UniversalQRScanner_Tooltip_title", comment: "")
			static let description = NSLocalizedString("UniversalQRScanner_Tooltip_description", comment: "")
		}

		enum Info {
			static let title = NSLocalizedString("UniversalQRScanner_Info_title", comment: "")
			static let bulletPoint1 = NSLocalizedString("UniversalQRScanner_Info_bulletPoint1", comment: "")
			static let bulletPoint2 = NSLocalizedString("UniversalQRScanner_Info_bulletPoint2", comment: "")
			static let bulletPoint3 = NSLocalizedString("UniversalQRScanner_Info_bulletPoint3", comment: "")
			static let bulletPoint4 = NSLocalizedString("UniversalQRScanner_Info_bulletPoint4", comment: "")
			static let body1 = NSLocalizedString("UniversalQRScanner_Info_body1", comment: "")
			static let body2 = NSLocalizedString("UniversalQRScanner_Info_body2", comment: "")
			static let dataPrivacy = NSLocalizedString("UniversalQRScanner_Info_dataPrivacy", comment: "")
		}
	}

	enum FileScanner {
		static let hudText = NSLocalizedString("FileScanner_HUD_text", comment: "")

		enum sheet {
			static let photos = NSLocalizedString("FileScanner_sheet_photos", comment: "")
			static let documents = NSLocalizedString("FileScanner_sheet_documents", comment: "")
			static let cancel = NSLocalizedString("FileScanner_sheet_cancel", comment: "")
		}

		enum AccessError {
			static let title = NSLocalizedString("FileScanner_AccessError_title", comment: "")
			static let message = NSLocalizedString("FileScanner_AccessError_message", comment: "")
			static let cancel = NSLocalizedString("FileScanner_AccessError_cancel", comment: "")
			static let settings = NSLocalizedString("FileScanner_AccessError_settings", comment: "")
		}

		enum PasswordEntry {
			static let title = NSLocalizedString("FileScanner_PasswordEntry_title", comment: "")
			static let message = NSLocalizedString("FileScanner_PasswordEntry_message", comment: "")
			static let placeholder = NSLocalizedString("FileScanner_PasswordEntry_placeholder", comment: "")
		}

		enum PasswordError {
			static let title = NSLocalizedString("FileScanner_PasswordError_title", comment: "")
			static let message = NSLocalizedString("FileScanner_PasswordError_message", comment: "")
		}

		enum AlreadyRegistered {
			static let title = NSLocalizedString("FileScanner_AlreadyRegistered_title", comment: "")
			static let message = NSLocalizedString("FileScanner_AlreadyRegistered_message", comment: "")
		}

		enum InvalidQRCodeError {
			static let title = NSLocalizedString("FileScanner_InvalidQRCode_title", comment: "")
			static let message = NSLocalizedString("FileScanner_InvalidQRCode_message", comment: "")
		}

		enum FileNotReadable {
			static let title = NSLocalizedString("FileScanner_FileNotReadable_title", comment: "")
			static let message = NSLocalizedString("FileScanner_FileNotReadable_message", comment: "")
		}

		enum NoQRCodeFound {
			static let title = NSLocalizedString("FileScanner_NoQRCodeFound_title", comment: "")
			static let message = NSLocalizedString("FileScanner_NoQRCodeFound_message", comment: "")
		}
	}

	enum FederalStateName {
		static let badenWuerttemberg = NSLocalizedString("FederalState_BadenWuerttemberg", comment: "")
		static let bayen = NSLocalizedString("FederalState_Bayern", comment: "")
		static let berlin = NSLocalizedString("FederalState_Berlin", comment: "")
		static let brandenburg = NSLocalizedString("FederalState_Brandenburg", comment: "")
		static let bremen = NSLocalizedString("FederalState_Bremen", comment: "")
		static let hamburg = NSLocalizedString("FederalState_Hamburg", comment: "")
		static let hessen = NSLocalizedString("FederalState_Hessen", comment: "")
		static let mecklenburgVorpommern = NSLocalizedString("FederalState_MecklenburgVorpommern", comment: "")
		static let niedersachsen = NSLocalizedString("FederalState_Niedersachsen", comment: "")
		static let nordrheinWestfalen = NSLocalizedString("FederalState_NordrheinWestfalen", comment: "")
		static let rheinlandPfalz = NSLocalizedString("FederalState_RheinlandPfalz", comment: "")
		static let saarland = NSLocalizedString("FederalState_Saarland", comment: "")
		static let sachsen = NSLocalizedString("FederalState_Sachsen", comment: "")
		static let sachsenAnhalt = NSLocalizedString("FederalState_SachsenAnhalt", comment: "")
		static let schleswigHolstein = NSLocalizedString("FederalState_SchleswigHolstein", comment: "")
		static let thueringen = NSLocalizedString("FederalState_Thueringen", comment: "")
	}

	enum RecycleBin {
		static let title = NSLocalizedString("RecycleBin_title", comment: "")
		static let description = NSLocalizedString("RecycleBin_description", comment: "")
		static let deleteAllButtonTitle = NSLocalizedString("RecycleBin_deleteAllButtonTitle", comment: "")

		enum VaccinationCertificate {
			static let headline = NSLocalizedString("RecycleBin_VaccinationCertificate_headline", comment: "")
			static let vaccinationCount = NSLocalizedString("RecycleBin_VaccinationCertificate_vaccinationCount", comment: "")
			static let vaccinationDate = NSLocalizedString("RecycleBin_VaccinationCertificate_vaccinationDate", comment: "")
		}

		enum TestCertificate {
			static let headline = NSLocalizedString("RecycleBin_TestCertificate_headline", comment: "")
			static let pcrTest = NSLocalizedString("RecycleBin_TestCertificate_pcrTest", comment: "")
			static let antigenTest = NSLocalizedString("RecycleBin_TestCertificate_antigenTest", comment: "")
			static let sampleCollectionDate = NSLocalizedString("RecycleBin_TestCertificate_sampleCollectionDate", comment: "")
		}

		enum RecoveryCertificate {
			static let headline = NSLocalizedString("RecycleBin_RecoveryCertificate_headline", comment: "")
			static let validityDate = NSLocalizedString("RecycleBin_RecoveryCertificate_validityDate", comment: "")
		}

		enum CoronaTest {
			static let headline = NSLocalizedString("RecycleBin_CoronaTest_headline", comment: "")
			static let pcrTest = NSLocalizedString("RecycleBin_CoronaTest_pcrTest", comment: "")
			static let antigenTest = NSLocalizedString("RecycleBin_CoronaTest_antigenTest", comment: "")
			static let registrationDate = NSLocalizedString("RecycleBin_CoronaTest_registrationDate", comment: "")
			static let sampleCollectionDate = NSLocalizedString("RecycleBin_CoronaTest_sampleCollectionDate", comment: "")
		}

		enum EmptyState {
			static let title = NSLocalizedString("RecycleBin_EmptyState_title", comment: "")
			static let description = NSLocalizedString("RecycleBin_EmptyState_description", comment: "")
			static let imageDescription = NSLocalizedString("RecycleBin_EmptyState_imageDescription", comment: "")
		}

		enum RestoreCertificateAlert {
			static let title = NSLocalizedString("RecycleBin_RestoreCertificate_AlertTitle", comment: "")
			static let message = NSLocalizedString("RecycleBin_RestoreCertificate_AlertMessage", comment: "")
			static let confirmButtonTitle = NSLocalizedString("RecycleBin_RestoreCertificate_AlertConfirmButtonTitle", comment: "")
			static let cancelButtonTitle = NSLocalizedString("RecycleBin_RestoreCertificate_AlertCancelButtonTitle", comment: "")
		}

		enum RestoreCoronaTestAlert {
			static let title = NSLocalizedString("RecycleBin_CoronaTest_AlertTitle", comment: "")
			static let message = NSLocalizedString("RecycleBin_CoronaTest_AlertMessage", comment: "")
			static let confirmButtonTitle = NSLocalizedString("RecycleBin_CoronaTest_AlertConfirmButtonTitle", comment: "")
			static let cancelButtonTitle = NSLocalizedString("RecycleBin_CoronaTest_AlertCancelButtonTitle", comment: "")
		}

		enum DeleteAllAlert {
			static let title = NSLocalizedString("RecycleBin_DeleteAll_AlertTitle", comment: "")
			static let message = NSLocalizedString("RecycleBin_DeleteAll_AlertMessage", comment: "")
			static let confirmButtonTitle = NSLocalizedString("RecycleBin_DeleteAll_AlertConfirmButtonTitle", comment: "")
			static let cancelButtonTitle = NSLocalizedString("RecycleBin_DeleteAll_AlertCancelButtonTitle", comment: "")
		}
	}

	enum TicketValidation {
		enum FirstConsent {
			static let title = NSLocalizedString("TicketValidation_FirstConsent_title", comment: "")
			static let imageDescription = NSLocalizedString("TicketValidation_FirstConsent_imageDescription", comment: "")
			static let subtitle = NSLocalizedString("TicketValidation_FirstConsent_subtitle", comment: "")
			static let serviceProvider = NSLocalizedString("TicketValidation_FirstConsent_serviceProvider", comment: "")
			static let serviceProviderValue = NSLocalizedString("\"%@\"", comment: "")
			static let subject = NSLocalizedString("TicketValidation_FirstConsent_subject", comment: "")
			static let subjectValue = NSLocalizedString("\"%@\"", comment: "")
			static let explination = NSLocalizedString("TicketValidation_FirstConsent_explination", comment: "")
			static let bulletPoint1 = NSLocalizedString("TicketValidation_FirstConsent_BulletPoint1", comment: "")
			static let bulletPoint2 = NSLocalizedString("TicketValidation_FirstConsent_BulletPoint2", comment: "")
			static let bulletPoint3 = NSLocalizedString("TicketValidation_FirstConsent_BulletPoint3", comment: "")
			static let bulletPoint4 = NSLocalizedString("TicketValidation_FirstConsent_BulletPoint4", comment: "")
			static let dataPrivacyTitle = NSLocalizedString("TicketValidation_FirstConsent_DataPrivacyTitle", comment: "")
			static let primaryButtonTitle = NSLocalizedString("TicketValidation_FirstConsent_primaryButtonTitle", comment: "")
			static let secondaryButtonTitle = NSLocalizedString("TicketValidation_FirstConsent_secondaryButtonTitle", comment: "")
			
			enum Legal {
				static let title = NSLocalizedString("TicketValidation_FirstConsent_Legal_title", tableName: "Localizable.legal", comment: "")
				static let subtitle = NSLocalizedString("TicketValidation_FirstConsent_Legal_subtitle", tableName: "Localizable.legal", comment: "")
				static let bulletPoint1 = NSLocalizedString("TicketValidation_FirstConsent_Legal_bulletPoint1", tableName: "Localizable.legal", comment: "")
				static let bulletPoint2 = NSLocalizedString("TicketValidation_FirstConsent_Legal_bulletPoint2", tableName: "Localizable.legal", comment: "")
			}
		}
		
		enum CertificateSelection {
			static let title = NSLocalizedString("TicketValidation_CertificateSelection_title", comment: "")
			static let serviceProviderRequirementsHeadline = NSLocalizedString("TicketValidation_CertificateSelection_serviceProviderRequirementsHeadline", comment: "")
			static let serviceProviderRelevantCertificatesHeadline = NSLocalizedString("TicketValidation_CertificateSelection_serviceProviderRelevantCertificatesHeadline", comment: "")
			static let serviceProviderRequiredCertificateHeadline = NSLocalizedString("TicketValidation_CertificateSelection_serviceProviderRequiredCertificateHeadline", comment: "")
			static let noSupportedCertificateHeadline = NSLocalizedString("TicketValidation_CertificateSelection_noSupportedCertificateHeadline", comment: "")
			static let noSupportedCertificateDescription = NSLocalizedString("TicketValidation_CertificateSelection_noSupportedCertificateDescription", comment: "")
			static let faqDescription = NSLocalizedString("TicketValidation_CertificateSelection_faqDescription", comment: "")
			static let faq = NSLocalizedString("TicketValidation_CertificateSelection_faq", comment: "")
			static let dateOfBirth = NSLocalizedString("TicketValidation_CertificateSelection_dateOfBirth", comment: "")
		}

		enum SupportedCertificateType {
			static let vaccinationCertificate = NSLocalizedString("TicketValidation_SupportedCertificateType_Vaccination_Certificate", comment: "")
			static let recoveryCertificate = NSLocalizedString("TicketValidation_SupportedCertificateType_RecoveryCertificate", comment: "")
			static let testCertificate = NSLocalizedString("TicketValidation_SupportedCertificateType_TestCertificate", comment: "")
			static let pcrTestCertificate = NSLocalizedString("TicketValidation_SupportedCertificateType_PCRTestCertificate", comment: "")
			static let ratTestCertificate = NSLocalizedString("TicketValidation_SupportedCertificateType_RATTestCertificate", comment: "")
		}

		enum SecondConsent {
			static let title = NSLocalizedString("TicketValidation_SecondConsent_title", comment: "")
			static let subtitle = NSLocalizedString("TicketValidation_SecondConsent_subtitle", comment: "")
			static let serviceIdentity = NSLocalizedString("TicketValidation_SecondConsent_serviceIdentity", comment: "")
			static let serviceIdentityValue = NSLocalizedString("\"%@\"", comment: "")
			static let serviceProvider = NSLocalizedString("TicketValidation_SecondConsent_serviceProvider", comment: "")
			static let serviceProviderValue = NSLocalizedString("\"%@\"", comment: "")
			static let explination = NSLocalizedString("TicketValidation_SecondConsent_explination", comment: "")
			static let bulletPoint1 = NSLocalizedString("TicketValidation_SecondConsent_BulletPoint1", comment: "")
			static let bulletPoint2 = NSLocalizedString("TicketValidation_SecondConsent_BulletPoint2", comment: "")
			static let bulletPoint3 = NSLocalizedString("TicketValidation_SecondConsent_BulletPoint3", comment: "")
			static let bulletPoint4 = NSLocalizedString("TicketValidation_SecondConsent_BulletPoint4", comment: "")
			static let dataPrivacyTitle = NSLocalizedString("TicketValidation_SecondConsent_DataPrivacyTitle", comment: "")
			static let primaryButtonTitle = NSLocalizedString("TicketValidation_SecondConsent_primaryButtonTitle", comment: "")
			static let secondaryButtonTitle = NSLocalizedString("TicketValidation_SecondConsent_secondaryButtonTitle", comment: "")
			enum Legal {
				static let title = NSLocalizedString("TicketValidation_SecondConsent_Legal_title", tableName: "Localizable.legal", comment: "")
				static let subtitle = NSLocalizedString("TicketValidation_SecondConsent_Legal_subtitle", tableName: "Localizable.legal", comment: "")
				static let bulletPoint1 = NSLocalizedString("TicketValidation_SecondConsent_Legal_bulletPoint1", tableName: "Localizable.legal", comment: "")
				static let bulletPoint2 = NSLocalizedString("TicketValidation_SecondConsent_Legal_bulletPoint2", tableName: "Localizable.legal", comment: "")
				static let subBulletPoint1 = NSLocalizedString("TicketValidation_SecondConsent_Legal_subBulletPoint1", tableName: "Localizable.legal", comment: "")
				static let subBulletPoint2 = NSLocalizedString("TicketValidation_SecondConsent_Legal_subBulletPoint2", tableName: "Localizable.legal", comment: "")
				static let subBulletPoint3 = NSLocalizedString("TicketValidation_SecondConsent_Legal_subBulletPoint3", tableName: "Localizable.legal", comment: "")
				static let subBulletPoint4 = NSLocalizedString("TicketValidation_SecondConsent_Legal_subBulletPoint4", tableName: "Localizable.legal", comment: "")
			}
	
		}
		
		enum Result {
			static let validationParameters = NSLocalizedString("TicketValidation_Result_validationParameters", comment: "")
			static let moreInformation = NSLocalizedString("TicketValidation_Result_moreInformation", comment: "")
			static let moreInformationPlaceholderFAQ = NSLocalizedString("TicketValidation_Result_moreInformation_placeholder_FAQ", comment: "")

			enum Passed {
				static let title = NSLocalizedString("TicketValidation_Result_Passed_title", comment: "")
				static let subtitle = NSLocalizedString("TicketValidation_Result_Passed_subtitle", comment: "")
				static let description = NSLocalizedString("TicketValidation_Result_Passed_description", comment: "")
			}

			enum Open {
				static let title = NSLocalizedString("TicketValidation_Result_Open_title", comment: "")
				static let subtitle = NSLocalizedString("TicketValidation_Result_Open_subtitle", comment: "")
				static let description = NSLocalizedString("TicketValidation_Result_Open_description", comment: "")
			}

			enum Failed {
				static let title = NSLocalizedString("TicketValidation_Result_Failed_title", comment: "")
				static let subtitle = NSLocalizedString("TicketValidation_Result_Failed_subtitle", comment: "")
				static let description = NSLocalizedString("TicketValidation_Result_Failed_description", comment: "")
			}
		}

		enum CancelAlert {
			static let title = NSLocalizedString("TicketValidation_CancelAlert_title", comment: "")
			static let message = NSLocalizedString("TicketValidation_CancelAlert_message", comment: "")
			static let cancelButtonTitle = NSLocalizedString("TicketValidation_CancelAlert_cancelButtonTitle", comment: "")
			static let continueButtonTitle = NSLocalizedString("TicketValidation_CancelAlert_continueButtonTitle", comment: "")
		}

		enum Error {
			static let title = NSLocalizedString("TicketValidation_Error_title", comment: "")
			static let serviceProviderErrorNoName = NSLocalizedString("TicketValidation_Error_serviceProviderErrorNoName", comment: "")
			static let serviceProviderError = NSLocalizedString("TicketValidation_Error_serviceProviderError", comment: "")
			static let tryAgain = NSLocalizedString("TicketValidation_Error_tryAgain", comment: "")
			static let outdatedApp = NSLocalizedString("TicketValidation_Error_OutdatedApp", comment: "")
			static let updateApp = NSLocalizedString("TicketValidation_Error_UpdateAction", comment: "")
			static let serviceProviderErrorNoMatch = NSLocalizedString("TicketValidation_Error_serviceProviderErrorNoMatch", comment: "")
			static let serviceProviderErrorNoMatchTitle = NSLocalizedString("TicketValidation_Error_serviceProviderErrorNoMatchTitle", comment: "")
		}
	}
	// swiftlint:disable:next file_length
}
