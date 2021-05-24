//
// 🦠 Corona-Warn-App
//

import Foundation

struct LaunchArgument {

	let name: String

	var boolValue: Bool {
		UserDefaults.standard.bool(forKey: name)
	}

	var stringValue: String? {
		UserDefaults.standard.string(forKey: name)
	}

	var intValue: Int {
		UserDefaults.standard.integer(forKey: name)
	}

}

enum LaunchArguments {
	enum common {
		// Coming from ENF and used to set exposure notification to active
		static let ENStatus = LaunchArgument(name: "ENStatus")
		// Number of days the app is installed, shown on home / detail screens
		static let appInstallationDays = LaunchArgument(name: "appInstallationDays")
	}
	enum onboarding {
		// If user has already been onboarded
		static let isOnboarded = LaunchArgument(name: "isOnboarded")
		// Set the self defined version of onboarding
		static let onboardingVersion = LaunchArgument(name: "onboardingVersion")
		// Set the current version of onbaording
		static let setCurrentOnboardingVersion = LaunchArgument(name: "setCurrentOnboardingVersion")
		// Reset the flag for delta onboarding
		static let resetFinishedDeltaOnboardings = LaunchArgument(name: "resetFinishedDeltaOnboardings")
	}
	enum infoScreen {
		// To show various info screens
		static let diaryInfoScreenShown = LaunchArgument(name: "diaryInfoScreenShown")
		static let antigenTestProfileInfoScreenShown = LaunchArgument(name: "antigenTestProfileInfoScreenShown")
		static let traceLocationsInfoScreenShown = LaunchArgument(name: "traceLocationsInfoScreenShown")
		static let checkinInfoScreenShown = LaunchArgument(name: "checkinInfoScreenShown")
		static let userNeedsToBeInformedAboutHowRiskDetectionWorks = LaunchArgument(name: "userNeedsToBeInformedAboutHowRiskDetectionWorks")
		static let showUpdateOS = LaunchArgument(name: "showUpdateOS")
	}
	enum risk {
		// Set the level of risk
		static let riskLevel = LaunchArgument(name: "riskLevel")
		// Number of days with the certain risk level
		static let numberOfDaysWithRiskLevel = LaunchArgument(name: "numberOfDaysWithRiskLevel")
		// Set the level of risk for checkin
		static let checkinRiskLevel = LaunchArgument(name: "checkinRiskLevel")
	}
	enum consent {
		// To set the various consent flags
		static let isDatadonationConsentGiven = LaunchArgument(name: "isDatadonationConsentGiven")
		static let isPCRSubmissionConsentGiven = LaunchArgument(name: "isPCRSubmissionConsentGiven")
		static let isAntigenSubmissionConsentGiven = LaunchArgument(name: "isAntigenSubmissionConsentGiven")
	}
	enum test {
		enum common {
			// To scroll the pcr test card to top, so both can be seen on a screen
			static let showTestResultCards = LaunchArgument(name: "showTestResultCards")
		}
		enum pcr {
			// Set the PCR Test Result
			static let pcrTestResult = LaunchArgument(name: "pcrTestResult")
			// Flag to set if positive result was shown for PCR, set it to true for positive PCR
			static let pcrPositiveTestResultWasShown = LaunchArgument(name: "pcrPositiveTestResultWasShown")
			// Flag to set if the keys are submitted for PCR
			static let pcrKeysSubmitted = LaunchArgument(name: "pcrKeysSubmitted")
		}
		enum antigen {
			// Set the Antigen Test Result
			static let antigenTestResult = LaunchArgument(name: "antigenTestResult")
			// Flag to set if positive result was shown for Antigen, set it to true for positive Antigen
			static let antigenPositiveTestResultWasShown = LaunchArgument(name: "antigenPositiveTestResultWasShown")
			// Flag to set if the keys are submitted for Antigen
			static let antigenKeysSubmitted = LaunchArgument(name: "antigenKeysSubmitted")
			// To remove the antigen test profile
			static let removeAntigenTestProfile = LaunchArgument(name: "removeAntigenTestProfile")
		}
	}
	enum statistics {
		// To use the mock data for statistics
		static let useMockDataForStatistics = LaunchArgument(name: "useMockDataForStatistics")
	}
	enum errorReport {
		// To show if els logging should be active when starting the app
		static let elsLogActive = LaunchArgument(name: "elsLogActive")
		// To create some fake history entries for the els log
		static let elsCreateFakeHistory = LaunchArgument(name: "elsCreateFakeHistory")
	}
	enum contactJournal {
		// To remove all the persons from contact journal
		static let journalRemoveAllPersons = LaunchArgument(name: "journalRemoveAllPersons")
		// To remove all the locations from contact journal
		static let journalRemoveAllLocations = LaunchArgument(name: "journalRemoveAllLocations")
	}
	enum healthCertificate {
		// Flag to set health certificates
		static let noHealthCertificate = LaunchArgument(name: "noHealthCertificate")
		static let firstHealthCertificate = LaunchArgument(name: "firstHealthCertificate")
		static let firstAndSecondHealthCertificate = LaunchArgument(name: "firstAndSecondHealthCertificate")
	}
}
