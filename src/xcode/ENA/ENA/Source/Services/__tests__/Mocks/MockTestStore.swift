//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class MockTestStore: Store, AppConfigCaching {
	var isAllowedToPerformBackgroundFakeRequests = false
	var firstPlaybookExecution: Date?
	var lastBackgroundFakeRequest: Date = .init()
	var hasSeenBackgroundFetchAlert: Bool = false
	var previousRiskLevel: EitherLowOrIncreasedRiskLevel?
	var shouldShowRiskStatusLoweredAlert: Bool = false
	var summary: SummaryMetadata?
	var tracingStatusHistory: TracingStatusHistory = []
	var testResultReceivedTimeStamp: Int64?
	func clearAll(key: String?) {}
	var hasSeenSubmissionExposureTutorial: Bool = false
	var lastSuccessfulSubmitDiagnosisKeyTimestamp: Int64?
	var numberOfSuccesfulSubmissions: Int64?
	var initialSubmitCompleted: Bool = false
	var exposureActivationConsentAcceptTimestamp: Int64?
	var exposureActivationConsentAccept: Bool = false
	var isOnboarded: Bool = false
	var onboardingVersion: String = ""
	var dateOfAcceptedPrivacyNotice: Date?
	var allowsCellularUse: Bool = false
	var developerSubmissionBaseURLOverride: String?
	var developerDistributionBaseURLOverride: String?
	var developerVerificationBaseURLOverride: String?
	var teleTan: String?
	var tan: String?
	var testGUID: String?
	var devicePairingConsentAccept: Bool = false
	var devicePairingConsentAcceptTimestamp: Int64?
	var devicePairingSuccessfulTimestamp: Int64?
	var isAllowedToSubmitDiagnosisKeys: Bool = false
	var registrationToken: String?
	var allowRiskChangesNotification: Bool = true
	var allowTestsStatusNotification: Bool = true
	var hourlyFetchingEnabled: Bool = true
	var userNeedsToBeInformedAboutHowRiskDetectionWorks = false
	var selectedServerEnvironment: ServerEnvironmentData = ServerEnvironment().defaultEnvironment()
	var isDeviceTimeCorrect = true
	var wasDeviceTimeErrorShown = false

	#if !RELEASE
	// Settings from the debug menu.
	var fakeSQLiteError: Int32?
	#endif

	// MARK: - AppConfigCaching
	
	var lastAppConfigETag: String?
	var lastAppConfigFetch: Date?
	var appConfig: SAP_Internal_ApplicationConfiguration?
}
