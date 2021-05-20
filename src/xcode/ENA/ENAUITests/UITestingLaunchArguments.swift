////
// 🦠 Corona-Warn-App
//

import Foundation

enum UITestingLaunchArguments {
	enum common {
		static let ENStatus = "-ENStatus"
		static let appInstallationDays = "-appInstallationDays"
		static let showUpdateOS = "-showUpdateOS"
	}
	enum onboarding {
		static let isOnboarded = "-isOnboarded"
		static let onboardingVersion = "-onboardingVersion"
		static let setCurrentOnboardingVersion = "-setCurrentOnboardingVersion"
		static let resetFinishedDeltaOnboardings = "-resetFinishedDeltaOnboardings"
	}
	enum infoScreen {
		static let diaryInfoScreenShown = "-diaryInfoScreenShown"
		static let antigenTestProfileInfoScreenShown = "-antigenTestProfileInfoScreenShown"
		static let traceLocationsInfoScreenShown = "-traceLocationsInfoScreenShown"
		static let checkinInfoScreenShown = "-checkinInfoScreenShown"
		static let userNeedsToBeInformedAboutHowRiskDetectionWorks = "-userNeedsToBeInformedAboutHowRiskDetectionWorks"
	}
	enum risk {
		static let riskLevel = "-riskLevel"
		static let numberOfDaysWithRiskLevel = "-numberOfDaysWithRiskLevel"
		static let checkinRiskLevel = "-checkinRiskLevel"
	}
	enum consent {
		static let isDatadonationConsentGiven = "-isDatadonationConsentGiven"
		static let isPCRSubmissionConsentGiven = "-isPCRSubmissionConsentGiven"
	}
	enum test {
		enum common {
			static let showTestResultCards = "-showTestResultCards"
		}
		enum pcr {
			static let pcrTestResult = "-pcrTestResult"
			static let pcrTestResultResponse = "-pcrTestResultResponse"
			static let pcrPositiveTestResultWasShown = "-pcrPositiveTestResultWasShown"
		}
		enum antigen {
			static let antigenTestResult = "-antigenTestResult"
			static let antigenTestResultResponse = "-antigenTestResultResponse"
			static let removeAntigenTestProfile = "-removeAntigenTestProfile"
		}
	}
	enum statistics {
		static let useMockDataForStatistics = "-useMockDataForStatistics"
	}
	enum errorReport {
		static let elsLogActive = "-elsLogActive"
		static let elsCreateFakeHistory = "-elsCreateFakeHistory"
	}
	enum contactJournal {
		static let journalRemoveAllPersons = "-journalRemoveAllPersons"
		static let journalRemoveAllLocations = "-journalRemoveAllLocations"
	}
}
