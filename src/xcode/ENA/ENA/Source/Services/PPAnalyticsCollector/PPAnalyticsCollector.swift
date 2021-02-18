////
// 🦠 Corona-Warn-App
//

import Foundation

typealias Analytics = PPAnalyticsCollector

/// Singleton to collect the analytics dataand to save it in the database, to load it from the database, to remove every analytics data from the store. This also triggers a submission.
enum PPAnalyticsCollector {

	// MARK: - Internal

	static func setup(
		store: Store,
		submitter: PPAnalyticsSubmitter
	) {
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.submitter = submitter
	}

	static func setupMock(
		store: Store? = nil,
		submitter: PPAnalyticsSubmitter? = nil
	) {
		PPAnalyticsCollector.store = store
		PPAnalyticsCollector.submitter = submitter
	}

	static func log(_ dataType: PPADataType) {
		guard let store = store else {
			Log.warning("I cannot log analytics data. Perhaps i am a mock or setup was not called correctly?", log: .ppa)
			return
		}
		switch dataType {
		case let .userData(userMetadata):
			store.userMetadata = userMetadata
		case let .riskExposureMetadata(riskExposureMetadata):
			store.currentRiskExposureMetadata = riskExposureMetadata
		case let .clientMetadata(clientMetadata):
			store.clientMetadata = clientMetadata
		}

		Analytics.triggerAnalyticsSubmission()
	}

	static func deleteAnalyticsData() {
		store?.currentRiskExposureMetadata = nil
		store?.previousRiskExposureMetadata = nil
		store?.userMetadata = nil
		store?.lastSubmittedPPAData = nil
		store?.lastAppReset = nil
		store?.lastSubmissionAnalytics = nil
		store?.clientMetadata = nil
		Log.info("Deleted all analytics data in the store", log: .ppa)
	}

	static func triggerAnalyticsSubmission() {
		guard let submitter = submitter else {
			Log.warning("I cannot submit analytics data. Perhaps i am a mock or setup was not called correctly?", log: .ppa)
			return
		}
		submitter.triggerSubmitData()
	}

	// MARK: - Private

	private static var store: Store?
	private static var submitter: PPAnalyticsSubmitter?
}
