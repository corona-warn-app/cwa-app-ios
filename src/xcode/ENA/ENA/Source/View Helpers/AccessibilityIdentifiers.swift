//
// 🦠 Corona-Warn-App
//

import Darwin

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
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
		enum DeltaOnboarding {
			static let imageOn = "AppStrings.NotificationSettings.imageDescriptionOn"
			static let imageOff = "AppStrings.NotificationSettings.imageDescriptionOff"
			static let description = "AppStrings.NotificationSettings.DeltaOnboarding.description"
		}
		static let notifications = "AppStrings.NotificationSettings.notifications"
		static let notificationsOn = "AppStrings.NotificationSettings.notificationsOn"
		static let notificationsOff = "AppStrings.NotificationSettings.notificationsOff"
		
		static let bulletDescOn = "AppStrings.NotificationSettings.bulletDescOn"
		static let bulletDescOff = "AppStrings.NotificationSettings.bulletDescOff"
		static let bulletPoint1 = "AppStrings.NotificationSettings.bulletPoint1"
		static let bulletPoint2 = "AppStrings.NotificationSettings.bulletPoint2"
		static let bulletPoint3 = "AppStrings.NotificationSettings.bulletPoint3"
		static let bulletDesc2 = "AppStrings.NotificationSettings.bulletDesc2"
		
		static let openSystemSettings = "AppStrings.NotificationSettings.openSystemSettings"
		static let close = "AppStrings.NotificationSettings.DeltaOnboarding.primaryButtonTitle"
	}
	
	enum Home {
		static let leftBarButtonDescription = "AppStrings.Home.leftBarButtonDescription"
		static let rightBarButtonDescription = "AppStrings.Home.rightBarButtonDescription"
		static let activateCardOnTitle = "AppStrings.Home.activateCardOnTitle"
		static let activateCardOffTitle = "AppStrings.Home.activateCardOffTitle"
		static let activateCardBluetoothOffTitle = "AppStrings.Home.activateCardBluetoothOffTitle"
		static let riskCardIntervalUpdateTitle = "AppStrings.Home.riskCardIntervalUpdateTitle"
		static let tableView = "AppStrings.Home.tableView"

		enum RiskTableViewCell {
			static let topContainer = "[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer]"
			static let bodyLabel = "HomeRiskTableViewCell.bodyLabel"
			static let updateButton = "HomeRiskTableViewCell.updateButton"
		}

		enum TestResultCell {
			static let pendingPCRButton = "AccessibilityIdentifiers.Home.pendingPCRButton"
			static let pendingAntigenButton = "AccessibilityIdentifiers.Home.pendingAntigenButton"
			static let negativePCRButton = "AccessibilityIdentifiers.Home.negativePCRButton"
			static let negativeAntigenButton = "AccessibilityIdentifiers.Home.negativeAntigenButton"
			static let availablePCRButton = "AccessibilityIdentifiers.Home.availablePCRButton"
			static let availableAntigenButton = "AccessibilityIdentifiers.Home.availableAntigenButton"
			static let invalidPCRButton = "AccessibilityIdentifiers.Home.invalidPCRButton"
			static let invalidAntigenButton = "AccessibilityIdentifiers.Home.invalidAntigenButton"
			static let expiredPCRButton = "AccessibilityIdentifiers.Home.expiredPCRButton"
			static let expiredAntigenButton = "AccessibilityIdentifiers.Home.expiredAntigenButton"
			static let outdatedAntigenButton = "AccessibilityIdentifiers.Home.outdatedAntigenButton"
			static let loadingPCRButton = "AccessibilityIdentifiers.Home.loadingPCRButton"
			static let loadingAntigenButton = "AccessibilityIdentifiers.Home.loadingAntigenButton"
			static let unconfiguredButton = "AccessibilityIdentifiers.Home.unconfiguredButton"
		}

		enum ShownPositiveTestResultCell {
			static let pcrCell = "AccessibilityIdentifiers.Home.pcrCell"
			static let antigenCell = "AccessibilityIdentifiers.Home.antigenCell"
			static let submittedPCRCell = "AccessibilityIdentifiers.Home.submittedPCRCell"
			static let submittedAntigenCell = "AccessibilityIdentifiers.Home.submittedAntigenCell"
			static let removeTestButton = "AppStrings.Home.TestResult.ShownPositive.removeTestButton"
			static let deleteAlertDeleteButton = "AppStrings.Home.TestResult.ShownPositive.deleteAlertDeleteButton"
		}

		enum MoreInfoCell {
			static let moreCell = "AppStrings.Home.moreCell"

			static let settingsLabel = "AppStrings.Home.settingsActionView"
			static let recycleBinLabel = "AppStrings.Home.recycleBinActionView"
			static let appInformationLabel = "AppStrings.Home.appInformationActionView"
			static let faqLabel = "AppStrings.Home.faqActionView"
			static let shareLabel = "AppStrings.Home.shareActionView"
		}
		
		static let submitCardButton = "AppStrings.Home.submitCardButton"
		static let traceLocationsCardButton = "AppStrings.Home.traceLocationsCardButton"
	}
	
	enum ContactDiary {
		static let segmentedControl = "AppStrings.ContactDiary.Day"
		static let dayTableView = "AppStrings.ContactDiary.Day.TableView"
	}
	
	enum ContactDiaryInformation {
		static let imageDescription = "AppStrings.ContactDiaryInformation.imageDescription"
		static let descriptionTitle = "AppStrings.ContactDiaryInformation.descriptionTitle"
		static let descriptionSubHeadline = "AppStrings.ContactDiaryInformation.descriptionSubHeadline"
		static let dataPrivacyTitle = "AppStrings.ContactDiaryInformation.dataPrivacyTitle"
		static let legal_1 = "AppStrings.ContactDiaryInformation.legalHeadline_1"
		
		enum Day {
			static let durationSegmentedContol = "AppStrings.ContactDiaryInformation.durationSegmentedContol"
			static let maskSituationSegmentedControl = "AppStrings.ContactDiaryInformation.maskSituationSegmentedControl"
			static let settingSegmentedControl = "AppStrings.ContactDiaryInformation.settingSegmentedControl"
			static let notesTextField = "AppStrings.ContactDiaryInformation.notesTextField"
			static let notesInfoButton = "AppStrings.ContactDiaryInformation.notesInfoButton"
		}
		
		enum EditEntries {
			static let tableView = "AppStrings.ContactDiary.EditEntries.tableView"
			static let nameTextField = "AppStrings.ContactDiary.EditEntries.nameTextField"
			static let phoneNumberTextField = "AppStrings.ContactDiary.EditEntries.phoneNumberTextField"
			static let eMailTextField = "AppStrings.ContactDiary.EditEntries.eMailTextField"
		}
		
		enum Overview {
			static let riskLevelLow = "AppStrings.ContactDiary.Overview.lowRiskTitle"
			static let riskLevelHigh = "AppStrings.ContactDiary.Overview.increasedRiskTitle"
			static let tableView = "AppStrings.ContactDiary.Overview.tableView"
			
			static let checkinRiskLevelLow = "AppStrings.ContactDiary.Overview.CheckinEncounter.titleLowRisk"
			static let checkinRiskLevelHigh = "AppStrings.ContactDiary.Overview.CheckinEncounter.titleHighRisk"
			static let checkinTableView = "AppStrings.ContactDiary.Overview.CheckinEncounter.tableView"
			static let cell = "ContactDiary_Overview_cell-%d"
			static let person = "ContactDiary_Overview_personEntry-%d"
			static let location = "ContactDiary_Overview_locationEntry-%d"
		}
		
		enum NotesInformation {
			static let titel = "AppStrings.ContactDiary.NotesInformation.title"
		}
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

	enum RecycleBin {
		static let itemCell = "RecycleBin.itemCell"
		static let restorationConfirmationButton = "RecycleBin.restorationConfirmationButton"
	}
	
	enum Settings {
		static let tracingLabel = "AppStrings.Settings.tracingLabel"
		static let notificationLabel = "AppStrings.Settings.notificationLabel"
		static let backgroundAppRefreshLabel = "AppStrings.Settings.backgroundAppRefreshLabel"
		static let resetLabel = "AppStrings.Settings.resetLabel"
		static let backgroundAppRefreshImageDescription = "AppStrings.Settings.backgroundAppRefreshImageDescription"
		static let dataDonation = "AppStrings.Settings.Datadonation.description"
	}
	
	enum AppInformation {
		static let newFeaturesNavigation = "AppStrings.AppInformation.newFeaturesNavigation"
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
		
		static let contactHotlineDomesticText = "AppStrings.AppInformation.contactHotlineDomesticText"
		static let contactHotlineDomesticDetails = "AppStrings.AppInformation.contactHotlineDomesticDetails"
		static let contactHotlineForeignText = "AppStrings.AppInformation.contactHotlineForeignText"
		static let contactHotlineForeignDetails = "AppStrings.AppInformation.contactHotlineForeignDetails"
		
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
		
		static let guideFAQ = "AppStrings.ExposureDetection.guideFAQ"
		
		static let surveyCardCell = "AppStrings.ExposureDetection.surveyCardCell"
		static let surveyCardButton = "AppStrings.ExposureDetection.surveyCardButton"
		static let surveyStartButton = "AppStrings.ExposureDetection.surveyStartButton"
	}
	
	enum SurveyConsent {
		static let acceptButton = "AppStrings.SurveyConsent.acceptButton"
		static let titleImage = "AppStrings.SurveyConsent.titleImage"
		static let title = "AppStrings.SurveyConsent.title"
		static let legalDetailsButton = "AppStrings.SurveyConsent.legalDetailsButton"
	}
	
	enum UniversalQRScanner {
		static let flash = "ExposureSubmissionQRScanner_flash"
		static let file = "QRScanner_file"
		static let info = "QRScanner_info"
		static let dataPrivacy = "QRScanner_dataPrivacy"

		#if targetEnvironment(simulator)
		static let fakeHC1 = "QRScanner_FAKE_HC1"
		static let fakeHC2 = "QRScanner_FAKE_HC2"
		static let fakePCR = "QRScanner_FAKE_PCR"
		static let fakePCR2 = "QRScanner_FAKE_PCR2"
		static let fakeEvent = "QRScanner_FAKE_EVENT"
		static let fakeTicketValidation = "QRScanner_FAKE_TICKET_VALIDATION"
		static let other = "QRScanner_OTHER"
		static let cancel = "QRScanner_CANCEL"
		#endif
	}

	enum FileScanner {
		static let cancelSheet = "FileScanner_Sheet_Cancel_Button"
		static let photo = "FileScanner_Sheet_Photo_Button"
		static let file = "FileScanner_Sheet_File_Button"
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
		static let findTestCentersButtonDescription = "AppStrings.ExposureSubmissionDispatch.findTestCentersButtonDescription"
	}
	
	enum ExposureSubmissionResult {
		static let procedure = "AppStrings.ExposureSubmissionResult.procedure"
		static let furtherInfos_Title = "AppStrings.ExposureSubmissionResult.furtherInfos_Title"
		static let warnOthersConsentGivenCell = "AppStrings.ExposureSubmissionResult.warnOthersConsentGiven"
		static let warnOthersConsentNotGivenCell = "AppStrings.ExposureSubmissionResult.warnOthersConsentNotGiven"
		
		enum Antigen {
			static let proofTitle = "AppStrings.ExposureSubmissionResult.Antigen.proofTitle"
			static let proofDesc = "AppStrings.ExposureSubmissionResult.Antigen.proofDesc"
		}
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
		static let closeButton = "AppStrings.ExposureSubmissionSuccess.button"
	}
	
	enum ExposureSubmissionHotline {
		static let imageDescription = "AppStrings.ExposureSubmissionHotline.imageDescription"
		static let description = "AppStrings.ExposureSubmissionHotline.description"
		static let sectionTitle = "AppStrings.ExposureSubmissionHotline.sectionTitle"
		static let primaryButton = "AppStrings.ExposureSubmissionHotline.tanInputButtonTitle"
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
		static let acknowledgementTitle = "AppStrings.ExposureSubmissionWarnOthers.acknowledgement_title"
		static let countryList = "AppStrings.ExposureSubmissionWarnOthers.countryList"
		static let dataProcessingDetailInfo = "AppStrings.AppStrings.ExposureSubmissionWarnOthers.dataProcessingDetailInfo"
	}
	
	enum DeltaOnboarding {
		static let accImageDescription = "AppStrings.DeltaOnboarding.accImageLabel"
		static let newVersionFeaturesAccImageDescription = "AppStrings.DeltaOnboarding.newVersionFeaturesAccImageLabel"
		static let newVersionFeaturesGeneralDescription = "AppStrings.DeltaOnboarding.NewVersionFeatures.GeneralDescription"
		static let newVersionFeaturesGeneralAboutAppInformation = "AppStrings.DeltaOnboarding.NewVersionFeatures.AboutAppInformation"
		static let newVersionFeaturesVersionInfo = "AppStrings.DeltaOnboarding.NewVersionFeatures.VersionInfo"
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
	enum LocalStatistics {
		static let title = "AppStrings.Statistics.Card.Incidence.title"
		static let infoButton = "AppStrings.Statistics.Card.Incidence.infoButton"
		static let selectState = "AppStrings.LocalStatistics.selectState"
		static let selectDistrict = "AppStrings.LocalStatistics.selectDistrict"
		static let manageStatisticsCard = "AppStrings.LocalStatistics.manageStatisticsCard"
		static let localStatisticsCard = "AppStrings.LocalStatistics.localStatisticsCard"
		static let addLocalIncidencesButton = "AppStrings.LocalStatistics.addLocalIncidencesButton"
		static let addLocalIncidenceLabel = "AppStrings.LocalStatistics.addLocalIncidenceLabel"
		static let modifyLocalIncidencesButton = "AppStrings.LocalStatistics.modifyLocalIncidencesButton"
		static let modifyLocalIncidenceLabel = "AppStrings.LocalStatistics.modifyLocalIncidenceLabel"
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

		enum OverwriteNotice {
			static let imageDescription = "AppStrings.ExposureSubmission.OverwriteNotice.imageDescription"

			enum Pcr {
				static let headline = "AppStrings.ExposureSubmission.OverwriteNotice.Pcr.headline"
				static let text = "AppStrings.ExposureSubmission.OverwriteNotice.Pcr.text"
			}

			enum Antigen {
				static let headline = "AppStrings.ExposureSubmission.OverwriteNotice.Antigen.headline"
				static let text = "AppStrings.ExposureSubmission.OverwriteNotice.Antigen.text"
			}
		}

		enum AntigenTest {
			enum Information {
				static let imageDescription = "AppStrings.ExposureSubmission.AntigenTest.Information.imageDescription"
				static let descriptionTitle = "AppStrings.ExposureSubmission.AntigenTest.Information.descriptionTitle"
				static let descriptionSubHeadline = "AppStrings.ExposureSubmission.AntigenTest.Information.descriptionSubHeadline"
				static let acknowledgementTitle = "AntigenTest_Information_acknowledgement_title"
				static let dataPrivacyTitle = "AppStrings.ExposureSubmission.AntigenTest.Information.dataPrivacyTitle"
				static let continueButton = "AppStrings.ExposureSubmission.AntigenTest.Information.primaryButton"
			}
			
			enum Create {
				static let saveButton = "AppStrings.AntigenProfile.Create.saveButtonTitle"
			}
			
			enum Profile {
				static let profileTile_Description = "AppStrings.ExposureSubmission.AntigenTest.Profile.profileTile_Description"
				static let createProfileTile_Description = "AppStrings.ExposureSubmission.AntigenTest.Profile.createProfileTile_Description"
				static let continueButton = "AppStrings.ExposureSubmission.AntigenTest.Profile.primaryButton"
				static let editButton = "AppStrings.ExposureSubmission.AntigenTest.Profile.secondaryButton"
				static let deleteAction = "AppStrings.ExposureSubmission.AntigenTest.Profile.deleteAction"
				static let editAction = "AppStrings.ExposureSubmission.AntigenTest.Profile.editAction"
			}
		}

		enum TestCertificate {
			enum Info {
				static let imageDescription = "AppStrings.ExposureSubmission.TestCertificate.Info.imageDescription"
				static let body = "AppStrings.ExposureSubmission.TestCertificate.Info.body"
				static let acknowledgementTitle = "ExposureSubmissionTestCertificateInfo_acknowledgement_title"
				static let dataPrivacyTitle = "AppStrings.ExposureSubmission.TestCertificate.Info.dataPrivacyTitle"
				static let birthdayPlaceholder = "AppStrings.ExposureSubmission.TestCertificate.Info.birthDayPlaceholder"
				static let birthdayText = "AppStrings.ExposureSubmission.TestCertificate.Info.birthDayText"
			}
		}

	}
	
	enum ExposureSubmissionTestResultConsent {
		static let switchIdentifier = "ExposureSubmissionTestResultConsent.SwitchIdentifier"
	}
	
	enum ExposureSubmissionTestResultAvailable {
		static let primaryButton = "AppStrings.ExposureSubmissionTestResultAvailable.primaryButtonTitle"
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
		static let deleteButton = "General.deleteButton"
		static let webView = "HTMLView"
	}
	
	enum DatePickerOption {
		static let day = "AppStrings.DatePickerOption.day"
	}
	
	enum ThankYouScreen {
		static let accImageDescription = "AppStrings.ThankYouScreen.accImageDescription"
	}
	
	enum Statistics {
		enum Infections {
			static let title = "AppStrings.Statistics.Card.Infections.title"
			static let infoButton = "AppStrings.Statistics.Card.Infections.infoButton"
		}
		enum KeySubmissions {
			static let title = "AppStrings.Statistics.Card.KeySubmissions.title"
			static let infoButton = "AppStrings.Statistics.Card.KeySubmissions.infoButton"
		}
		enum ReproductionNumber {
			static let title = "AppStrings.Statistics.Card.ReproductionNumber.title"
			static let infoButton = "AppStrings.Statistics.Card.ReproductionNumber.infoButton"
		}
		enum AtLeastOneVaccination {
			static let title = "AppStrings.Statistics.Card.AtLeastOneVaccination.title"
			static let infoButton = "AppStrings.Statistics.Card.AtLeastOneVaccination.infoButton"
		}
		enum FullyVaccinated {
			static let title = "AppStrings.Statistics.Card.FullyVaccinated.title"
			static let infoButton = "AppStrings.Statistics.Card.FullyVaccinated.infoButton"
		}
		enum Doses {
			static let title = "AppStrings.Statistics.Card.Doses.title"
			static let infoButton = "AppStrings.Statistics.Card.Doses.infoButton"
		}
		enum IntensiveCare {
			static let title = "AppStrings.Statistics.Card.IntensiveCare.title"
			static let infoButton = "AppStrings.Statistics.Card.IntensiveCare.infoButton"
		}
		enum Combined7DayIncidence {
			static let title = "AppStrings.Statistics.Card.Combined7DayIncidence.title"
			static let infoButton = "AppStrings.Statistics.Card.Combined7DayIncidence.infoButton"
		}
		enum General {
			static let tableViewCell = "HomeStatisticsTableViewCell"
			static let card = "HomeStatisticsCard"
		}
	}
	
	enum UpdateOSScreen {
		static let mainImage = "UpdateOSScreen.mainImage"
		static let logo = "UpdateOSScreen.logo"
		static let title = "UpdateOSScreen.title"
		static let text = "UpdateOSScreen.text"
	}

	enum TabBar {
		static let home = "TabBar.home"
		static let certificates = "TabBar.certificates"
		static let scanner = "TabBar.scanner"
		static let checkin = "TabBar.checkin"
		static let diary = "TabBar.diary"
	}
	
	enum DataDonation {
		static let accImageDescription = "AppStrings.DataDonation.Info.accImageDescription"
		static let accDataDonationTitle = "AppStrings.DataDonation.Info.title"
		static let accDataDonationDescription = "AppStrings.DataDonation.Info.description"
		static let accSubHeadState = "AppStrings.DataDonation.Info.subHeadState"
		static let accSubHeadAgeGroup = "AppStrings.DataDonation.Info.subHeadAgeGroup"
		static let consentSwitch = "DataDonation.Consent.Switch"
		static let federalStateName = "AppStrings.DataDonation.Info.noSelectionState"
		static let regionName = "AppStrings.DataDonation.Info.noSelectionRegion"
		static let ageGroup = "AppStrings.DataDonation.Info.noSelectionAgeGroup"
		static let federalStateCell = "DataDonation.FederalState.Identifier"
		static let regionCell = "DataDonation.Region.Identifier"
		static let ageGroupCell = "DataDonation.AgeGroup.Identifier"
	}

	enum ErrorReport {
		// Main Error Logging Screen
		// - top ViewController
		static let navigation = "AppStrings.ErrorReport.navigation"
		static let topBody = "AppStrings.ErrorReport.topBody"
		static let faq = "AppStrings.ErrorReport.faq"
		static let privacyInformation = "AppStrings.ErrorReport.privacyInformation"
		static let privacyNavigation = "AppStrings.ErrorReport.privacyNavigation"
		static let historyNavigation = "AppStrings.ErrorReport.historyNavigation"

		static let historyTitle = "AppStrings.ErrorReport.historyTitle"
		static let historyDescription = "AppStrings.ErrorReport.historyDescription"
		
		static let startButton = "AppStrings.ErrorReport.startButtonTitle"
		static let sendReportButton = "AppStrings.ErrorReport.sendButtontitle"
		static let saveLocallyButton = "AppStrings.ErrorReport.saveButtonTitle"
		static let stopAndDeleteButton = "AppStrings.ErrorReport.stopAndDeleteButtonTitle"

		static let legalSendReports = "AppStrings.ErrorReport.Legal.sendReports_Headline"
		static let sendReportsDetails = "AccessibilityIdentifiers.ErrorReport.sendReportsDetails"
		static let detailedInformationTitle = "AccessibilityIdentifiers.ErrorReport.detailedInformationTitle"
		static let detailedInformationSubHeadline = "AccessibilityIdentifiers.ErrorReport.detailedInformationSubHeadline"
		static let detailedInformationContent2 = "AccessibilityIdentifiers.ErrorReport.detailedInformationContent2"
		
		static let agreeAndSendButton = "AccessibilityIdentifiers.ErrorReport.agreeAndSendButton"
	}
	
	enum TraceLocation {
		static let imageDescription = "AppStrings.TraceLocations.imageDescription"
		static let descriptionTitle = "AppStrings.TraceLocations.descriptionTitle"
		static let descriptionSubHeadline = "AppStrings.TraceLocations.descriptionSubHeadline"
		static let dataPrivacyTitle = "AppStrings.TraceLocations.dataPrivacyTitle"
		static let acknowledgementTitle = "TraceLocation.acknowledgementTitle"
		static let legal_1 = "AppStrings.TraceLocations.legalHeadline_1"
		
		enum Details {
			static let printVersionButton = "AppStrings.TraceLocations.Details.printVersionButtonTitle"
			static let duplicateButton = "AppStrings.TraceLocations.Details.duplicateButtonTitle"
			static let titleLabel = "AppStrings.TraceLocations.Details.titleLabel"
			static let locationLabel = "AppStrings.TraceLocations.Details.locationLabel"
			static let checkInButton = "AppStrings.Checkins.Details.checkInButton"
		}
		
		enum Overview {
			static let tableView = "TableView.TracelocationOverview"
			static let menueButton = "AppStrings.TraceLocations.Overview.menueButton"
		}
		
		enum Configuration {
			static let descriptionPlaceholder = "AppStrings.TraceLocations.Configuration.descriptionPlaceholder"
			static let addressPlaceholder = "AppStrings.TraceLocations.Configuration.addressPlaceholder"
			static let temporaryDefaultLengthTitleLabel = "AppStrings.TraceLocations.Configuration.temporaryDefaultLengthTitleLabel"
			static let temporaryDefaultLengthFootnoteLabel = "AppStrings.TraceLocations.Configuration.temporaryDefaultLengthFootnoteLabel"
			static let permanentDefaultLengthTitleLabel = "AppStrings.TraceLocations.Configuration.permanentDefaultLengthTitleLabel"
			static let permanentDefaultLengthFootnoteLabel = "AppStrings.TraceLocations.Configuration.permanentDefaultLengthFootnoteLabel"
			static let eventTableViewCellButton = "AppStrings.TraceLocations.Configuration.eventTableViewCellButton"
		}
	}

	enum Checkin {
		
		enum Overview {
			static let menueButton = "AppStrings.CheckIn.Overview.menueButton"
		}
		
		enum Details {
			static let typeLabel = "AppStrings.CheckIn.Edit.checkedOut"
			static let traceLocationTypeLabel = "AppStrings.CheckIn.Edit.traceLocationTypeLabel"
			static let traceLocationDescriptionLabel = "AppStrings.CheckIn.Edit.traceLocationDescriptionLabel"
			static let traceLocationAddressLabel = "AppStrings.CheckIn.Edit.traceLocationAddressLabel"
			static let saveToDiary = "AppStrings.Checkins.Details.saveToDiary"
			static let automaticCheckout = "AppStrings.Checkins.Details.automaticCheckout"
			static let checkinFor = "AppStrings.Checkins.Details.checkinFor"
		}
		
		enum Information {
			static let imageDescription = "AppStrings.Checkins.Information.imageDescription"
			static let descriptionTitle = "AppStrings.Checkins.Information.descriptionTitle"
			static let descriptionSubHeadline = "AppStrings.Checkins.Information.descriptionSubHeadline"
			static let dataPrivacyTitle = "AppStrings.Checkins.Information.dataPrivacyTitle"
			static let primaryButton = "AppStrings.Checkins.Information.primaryButton"
			static let acknowledgementTitle = "Checkins.Information.acknowledgement_title"
		}
		
	}

	enum OnBehalfCheckinSubmission {

		enum TraceLocationSelection {
			static let selectionCell = "OnBehalfCheckinSubmission.TraceLocationSelection.selectionCell"
		}

		enum DateTimeSelection {
			static let dateCell = "OnBehalfCheckinSubmission.DateTimeSelection.dateCell"
			static let durationCell = "OnBehalfCheckinSubmission.DateTimeSelection.durationCell"
		}

	}
	
	enum AntigenProfile {
		
		enum Create {
			static let title = "AppStrings.AntigenProfile.Create.title"
			static let description = "AppStrings.AntigenProfile.Create.description"
			static let firstNameTextField = "AppStrings.AntigenProfile.Create.firstNameTextFieldPlaceholder"
			static let lastNameTextField = "AppStrings.AntigenProfile.Create.lastNameTextFieldPlaceholder"
			static let birthDateTextField = "AppStrings.AntigenProfile.Create.birthDateTextFieldPlaceholder"
			static let streetTextField = "AppStrings.AntigenProfile.Create.streetTextFieldPlaceholder"
			static let postalCodeTextField = "AppStrings.AntigenProfile.Create.postalCodeTextFieldPlaceholder"
			static let cityTextField = "AppStrings.AntigenProfile.Create.cityTextFieldPlaceholder"
			static let phoneNumberTextField = "AppStrings.AntigenProfile.Create.phoneNumberTextFieldPlaceholder"
			static let emailAddressTextField = "AppStrings.AntigenProfile.Create.emailAddressTextFieldPlaceholder"
			static let saveButtonTitle = "AppStrings.AntigenProfile.Create.saveButtonTitle"
		}
	}

	enum HealthCertificate {

		enum Validation {
			static let countrySelection = "HealthCertificate.Validation.CountrySelection"
			static let dateTimeSelection = "HealthCertificate.Validation.DateTimeSelection"
			enum Info {
				static let imageDescription = "AppStrings.HealthCertificate.Validation.Info.imageDescription"
			}
		}

		enum Overview {
			static let addCertificateCell =
				"addCertificateCell"
			static let healthCertifiedPersonCell = "AppStrings.HealthCertificate.healthCertifiedPersonCell"
			static let testCertificateRequestCell = "AppStrings.HealthCertificate.testCertificateRequestCell"
		}

		enum Info {
			static let imageDescription = "AppStrings.HealthCertificate.Info.imageDescription"

			enum Register {
				static let headline = "AppStrings.HealthCertificate.Info.Register.headline"
				static let text = "AppStrings.HealthCertificate.Info.Register.text"
			}

			static let disclaimer = "AppStrings.HealthCertificate.Info.disclaimer"
			static let acknowledgementTitle = "HealthCertificate.Info.acknowledgement"
		}

		enum Person {
			static let certificateCell = "HealthCertificate.Person.cell"
			static let validationButton = "HealthCertificate.Person.validationButton"
		}

		enum Certificate {
			static let headline = "HealthCertificate.title"
			static let deleteButton = "HealthCertificate.deleteButton"
			static let deletionConfirmationButton = "HealthCertificate.deletionConfirmationButton"
		}
		
		enum PrintPdf {
			static let imageDescription = "AppStrings.HealthCertificate.PrintPDF.imageDescription"
			static let infoPrimaryButton = "AppStrings.HealthCertificate.PrintPDF.infoPrimaryButton"
			static let printButton = "AppStrings.HealthCertificate.PrintPDF.printButton"
			static let shareButton = "AppStrings.HealthCertificate.PrintPDF.shareButton"
			static let faqAction = "AppStrings.HealthCertificate.PrintPDF.faqAction"
			static let okAction = "AppStrings.HealthCertificate.PrintPDF.okAction"
		}

		static let qrCodeCell = "HealthCertificate.qrCodeCell"
	}
	
	enum TicketValidation {
		
		enum FirstConsent {
			static let image = "TicketValidation.FirstConsent.image"
			static let legalBox = "TicketValidation.FirstConsent.legalBox"
			static let dataPrivacy = "TicketValidation.FirstConsent.dataPrivacy"
		}
	}

}
