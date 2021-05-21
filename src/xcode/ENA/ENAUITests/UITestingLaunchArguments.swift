////
// 🦠 Corona-Warn-App
//

import Foundation

enum UITestingLaunchArguments {
	enum common {
		// Coming from ENF and used to set exposure notification to active
		static let ENStatus = "-ENStatus"
		// Number of days the app is installed, shown on home / detail screens
		static let appInstallationDays = "-appInstallationDays"
		//
		static let showUpdateOS = "-showUpdateOS"
	}
	enum onboarding {
		// If user has already been onboarded
		static let isOnboarded = "-isOnboarded"
		// Set the self defined version of onboarding
		static let onboardingVersion = "-onboardingVersion"
		// Set the current version of onbaording
		static let setCurrentOnboardingVersion = "-setCurrentOnboardingVersion"
		// Reset the flag for delta onboarding
		static let resetFinishedDeltaOnboardings = "-resetFinishedDeltaOnboardings"
	}
	enum infoScreen {
		// To show various info screens
		static let diaryInfoScreenShown = "-diaryInfoScreenShown"
		static let antigenTestProfileInfoScreenShown = "-antigenTestProfileInfoScreenShown"
		static let traceLocationsInfoScreenShown = "-traceLocationsInfoScreenShown"
		static let checkinInfoScreenShown = "-checkinInfoScreenShown"
		static let userNeedsToBeInformedAboutHowRiskDetectionWorks = "-userNeedsToBeInformedAboutHowRiskDetectionWorks"
	}
	enum risk {
		// Set the level of risk
		static let riskLevel = "-riskLevel"
		// Number of days with the certain risk level
		static let numberOfDaysWithRiskLevel = "-numberOfDaysWithRiskLevel"
		// Set the level of risk for checkin
		static let checkinRiskLevel = "-checkinRiskLevel"
	}
	enum consent {
		// To set the various consent flags
		static let isDatadonationConsentGiven = "-isDatadonationConsentGiven"
		static let isPCRSubmissionConsentGiven = "-isPCRSubmissionConsentGiven"
		static let isAntigenSubmissionConsentGiven = "-isAntigenSubmissionConsentGiven"
	}
	enum test {
		enum common {
			// To scroll the pcr test card to top, so both can be seen on a screen
			static let showTestResultCards = "-showTestResultCards"
		}
		enum pcr {
			
			static let pcrTestResult = "-pcrTestResult"
			static let pcrTestResultResponse = "-pcrTestResultResponse"
			// To
			static let pcrPositiveTestResultWasShown = "-pcrPositiveTestResultWasShown"
		}
		enum antigen {
			static let antigenTestResult = "-antigenTestResult"
			static let antigenTestResultResponse = "-antigenTestResultResponse"
			// To remove the antigen test profile
			static let removeAntigenTestProfile = "-removeAntigenTestProfile"
		}
	}
	enum statistics {
		// To use the mock data for statistics
		static let useMockDataForStatistics = "-useMockDataForStatistics"
	}
	enum errorReport {
		// To show if els logging should be active when starting the app
		static let elsLogActive = "-elsLogActive"
		// To create some fake history entries for the els log
		static let elsCreateFakeHistory = "-elsCreateFakeHistory"
	}
	enum contactJournal {
		// To remove all the persons from contact journal
		static let journalRemoveAllPersons = "-journalRemoveAllPersons"
		// To remove all the locations from contact journal
		static let journalRemoveAllLocations = "-journalRemoveAllLocations"
	}
}
