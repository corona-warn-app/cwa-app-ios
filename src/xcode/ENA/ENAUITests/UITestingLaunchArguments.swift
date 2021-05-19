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
	enum testResult {
		enum common {
			static let testResultResponse = "-testResultResponse"
			static let showTestResultCards = "-showTestResultCards"
		}
		enum pcr {
			static let pcrTestResult = "-pcrTestResult"
			static let pcrPositiveTestResultWasShown = "-pcrPositiveTestResultWasShown"
		}
		enum antigen {
			static let antigenTestResult = "-antigenTestResult"
		}
	}
	enum testProfile {
		static let removeAntigenTestProfile = "-removeAntigenTestProfile"
	}
	enum statistics {
		static let useMockDataForStatistics = "-useMockDataForStatistics"
	}
	enum errorReport {
		static elsLogActive = "-elsLogActive"
		static elsCreateFakeHistory = "-elsCreateFakeHistory"
	}
	enum contactJournal {
		static journalRemoveAllPersons = "-journalRemoveAllPersons"
		static journalRemoveAllLocations = "-journalRemoveAllLocations"
	}
}
