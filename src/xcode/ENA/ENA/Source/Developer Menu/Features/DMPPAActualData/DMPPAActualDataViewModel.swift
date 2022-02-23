////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMPPAActualDataViewModel {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding,
		coronaTestService: CoronaTestServiceProviding,
		ppacService: PrivacyPreservingAccessControl
	) {
		self.store = store
		self.client = client
		self.appConfiguration = appConfig
		self.submitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfig,
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
	}

	// MARK: - Internal

	var refreshTableView: (IndexSet) -> Void = { _ in }

	var numberOfSections: Int {
		TableViewSections.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		guard TableViewSections.allCases.indices.contains(section) else {
			return 0
		}
		// at the moment we assume one cell per section only
		return 1
	}

	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
		case .actualPPAData:
			let value: String = store.isPrivacyPreservingAnalyticsConsentGiven ? Analytics.getPPADataMessage()?.textFormatString() ?? "" : "User consent for ppa is not given. No data to see."
			return DMKeyValueCellViewModel(key: "Actual PPA data", value: value)
		case .currentENFRisk:
			let value: String
			if let currentENFRisk = submitter.currentENFRiskExposureMetadata {
				value = String(describing: currentENFRisk)
			} else {
				value = "No stored currentENFRiskExposureMetadata"
			}
			return DMKeyValueCellViewModel(key: "Current ENF RiskExposureMetadata", value: value)
		case .previousENFRisk:
			let value: String
			if let previousENFRisk = submitter.previousENFRiskExposureMetadata {
				value = String(describing: previousENFRisk)
			} else {
				value = "No stored previousENFRiskExposureMetadata"
			}
			return DMKeyValueCellViewModel(key: "Previous ENF RiskExposureMetadata", value: value)
		case .currentCheckinRisk:
			let value: String
			if let currentCheckinRisk = submitter.currentCheckinRiskExposureMetadata {
				value = String(describing: currentCheckinRisk)
			} else {
				value = "No stored currentCheckinRiskExposureMetadata"
			}
			return DMKeyValueCellViewModel(key: "Current Checkin RiskExposureMetadata", value: value)
		case .previousCheckinRisk:
			let value: String
			if let previousCheckinRisk = submitter.previousCheckinRiskExposureMetadata {
				value = String(describing: previousCheckinRisk)
			} else {
				value = "No stored previousCheckinRiskExposureMetadata"
			}
			return DMKeyValueCellViewModel(key: "Previous Checkin RiskExposureMetadata", value: value)
		}
	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case actualPPAData
		case currentENFRisk
		case previousENFRisk
		case currentCheckinRisk
		case previousCheckinRisk
	}

	private let store: Store
	private let client: Client
	private let appConfiguration: AppConfigurationProviding
	private let submitter: PPAnalyticsSubmitter
}
#endif
