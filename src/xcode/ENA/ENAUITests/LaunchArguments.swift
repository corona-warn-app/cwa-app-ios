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

/*
 * To add a launch argument for UI testing simply add an entry here
 * Setup in UI test will be like app.setLaunchArgument(LaunchArguments.xyz.abc, to: <value>)
 * Access the value like LaunchArguments.xyz.abc.intValue
 * Please write a comment if you introduce a new launch argument
 */
enum LaunchArguments {

	enum common {
		/// Coming from ENF and used to set exposure notification to active
		static let ENStatus = LaunchArgument(name: "ENStatus")
		/// Number of days the app is installed, shown on home / detail screens
		static let appInstallationDays = LaunchArgument(name: "appInstallationDays")
	}

	enum onboarding {
		/// If user has already been onboarded
		static let isOnboarded = LaunchArgument(name: "isOnboarded")
		/// Set the self defined version of onboarding
		static let onboardingVersion = LaunchArgument(name: "onboardingVersion")
		/// Set the current version of onbaording
		static let setCurrentOnboardingVersion = LaunchArgument(name: "setCurrentOnboardingVersion")
		/// Reset the flag for delta onboarding
		static let resetFinishedDeltaOnboardings = LaunchArgument(name: "resetFinishedDeltaOnboardings")
	}

	enum infoScreen {
		/// To show various info screens
		static let diaryInfoScreenShown = LaunchArgument(name: "diaryInfoScreenShown")
		static let antigenTestProfileInfoScreenShown = LaunchArgument(name: "antigenTestProfileInfoScreenShown")
		static let traceLocationsInfoScreenShown = LaunchArgument(name: "traceLocationsInfoScreenShown")
		static let checkinInfoScreenShown = LaunchArgument(name: "checkinInfoScreenShown")
		static let healthCertificateInfoScreenShown = LaunchArgument(name: "healthCertificateInfoScreenShown")
		static let userNeedsToBeInformedAboutHowRiskDetectionWorks = LaunchArgument(name: "userNeedsToBeInformedAboutHowRiskDetectionWorks")
		static let showUpdateOS = LaunchArgument(name: "showUpdateOS")
	}

	enum risk {
		/// Set the level of risk
		static let riskLevel = LaunchArgument(name: "riskLevel")
		/// Number of days with the certain risk level
		static let numberOfDaysWithRiskLevel = LaunchArgument(name: "numberOfDaysWithRiskLevel")
		/// Set the level of risk for checkin
		static let checkinRiskLevel = LaunchArgument(name: "checkinRiskLevel")
	}
	
	enum exposureSubmission {
        /// the problem is in UITesting sometimes we directly try to fetch the submissionTan without fetching the registration token first, this make setting the restServiceProvider in coronaTestService dynamic as in this case we expect directly the tan result and without the token result

		static let isFetchingSubmissionTan = LaunchArgument(name: "isFetchingSubmissionTan")
	}

	enum consent {
		/// To set the various consent flags
		static let isDatadonationConsentGiven = LaunchArgument(name: "isDatadonationConsentGiven")
	}

	enum test {

		enum common {
			/// To scroll the pcr test card to top, so both can be seen on a screen
			static let showTestResultCards = LaunchArgument(name: "showTestResultCards")
		}

		enum pcr {
			/// Set the PCR Test Result
			static let testResult = LaunchArgument(name: "pcrTestResult")
			/// Flag to set if positive result was shown for PCR, set it to true for positive PCR
			static let positiveTestResultWasShown = LaunchArgument(name: "pcrPositiveTestResultWasShown")
			/// Flag to set if the submission consent was given for PCR
			static let isSubmissionConsentGiven = LaunchArgument(name: "isPCRSubmissionConsentGiven")
			/// Flag to set if the keys are submitted for PCR
			static let keysSubmitted = LaunchArgument(name: "pcrKeysSubmitted")
		}

		enum antigen {
			/// Set the Antigen Test Result
			static let testResult = LaunchArgument(name: "antigenTestResult")
			/// Flag to set if positive result was shown for Antigen, set it to true for positive Antigen
			static let positiveTestResultWasShown = LaunchArgument(name: "antigenPositiveTestResultWasShown")
			/// Flag to set if the submission consent was given for Antigen
			static let isSubmissionConsentGiven = LaunchArgument(name: "isAntigenSubmissionConsentGiven")
			/// Flag to set if the keys are submitted for Antigen
			static let keysSubmitted = LaunchArgument(name: "antigenKeysSubmitted")
			/// To remove the antigen test profile
			static let removeAntigenTestProfile = LaunchArgument(name: "removeAntigenTestProfile")
		}

	}

	enum recycleBin {
		static let pcrTest = LaunchArgument(name: "recycleBinPCRTest")
	}

	enum errorReport {
		/// To show if els logging should be active when starting the app
		static let elsLogActive = LaunchArgument(name: "elsLogActive")
		/// To create some fake history entries for the els log
		static let elsCreateFakeHistory = LaunchArgument(name: "elsCreateFakeHistory")
	}

	enum contactJournal {
		/// To remove all the persons from contact journal
		static let journalRemoveAllPersons = LaunchArgument(name: "journalRemoveAllPersons")
		/// To remove all the locations from contact journal
		static let journalRemoveAllLocations = LaunchArgument(name: "journalRemoveAllLocations")
		/// to remove all the corona tests from the contact journal
		static let journalRemoveAllCoronaTests = LaunchArgument(name: "journalRemoveAllCoronaTests")
		/// inject test data to journal
		static let testsRiskLevel = LaunchArgument(name: "journalTestsRiskLevel")
	}

	enum healthCertificate {
		/// Flag to set health certificates
		static let noHealthCertificate = LaunchArgument(name: "noHealthCertificate")
		static let firstHealthCertificate = LaunchArgument(name: "firstHealthCertificate")
		static let firstAndSecondHealthCertificate = LaunchArgument(name: "firstAndSecondHealthCertificate")
		static let hasBoosterNotification = LaunchArgument(name: "hasBoosterNotification")
		static let firstAndSecondHealthCertificateIssuerDE = LaunchArgument(name: "firstAndSecondHealthCertificateIssuerDE")
		static let isCertificateInvalid = LaunchArgument(name: "isCertificateInvalid")
		static let isCertificateExpiring = LaunchArgument(name: "isCertificateExpiring")
		static let hasCertificateExpired = LaunchArgument(name: "hasCertificateExpired")
		static let newTestCertificateRegistered = LaunchArgument(name: "newTestCertificateRegistered")
		static let testCertificateRegistered = LaunchArgument(name: "testCertificateRegistered")
		static let recoveryCertificateRegistered = LaunchArgument(name: "recoveryCertificateRegistered")
		static let familyCertificates = LaunchArgument(name: "familyCertificates")
		static let invalidCertificateCheck = LaunchArgument(name: "invalidCertificateCheck")
		static let showTestCertificateOnTestResult = LaunchArgument(name: "showTestCertificateOnTestResult")
	}

	enum notifications {
		/// Turn notifications for the settings screen on or off - does NOT sync or reflect the system setting. But needed to test the different screens.
		static let isNotificationsEnabled = LaunchArgument(name: "isNotificationsEnabled")
	}

	enum statistics {
		/// Set the selected regions to maximum i.e., 5
		static let maximumRegionsSelected = LaunchArgument(name: "maximumRegionsSelected")
	}

}
