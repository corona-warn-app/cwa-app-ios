////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMPPAnalyticsViewModel {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding
	) {
		self.store = store
		self.client = client
		self.submitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfig)
	}

	// MARK: - Internal

	var refreshTableView: (IndexSet) -> Void = { _ in }
	var showAlert: ((UIAlertController) -> Void)?

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
		case .forceSubmission:
			return DMButtonCellViewModel(
				text: "Force Analytics Submission",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					// it's added for the testers in case of force submission
					if let enfRiskCalculationResult = self?.store.enfRiskCalculationResult {
						Analytics.collect(.riskExposureMetadata(.updateRiskExposureMetadata(enfRiskCalculationResult)))
					}
					Analytics.forcedAnalyticsSubmission(completion: { [weak self] result in
						switch result {
						case .success:
							let alert = UIAlertController(title: "Data submission success", message: nil, preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
							self?.showAlert?(alert)
							self?.refreshTableView([TableViewSections.forceSubmission.rawValue])
						case let .failure(error):
							let alert = UIAlertController(title: "Data submission error", message: "Error code: \(error)", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
							self?.showAlert?(alert)

							self?.refreshTableView([TableViewSections.forceSubmission.rawValue])
						}
					})
				}
			)
		case .generateFakedTestData:
			return DMButtonCellViewModel(
				text: "Generate Fake Data",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					Analytics.collect(.userData(.create(UserMetadata(federalState: .hessen, administrativeUnit: 0, ageGroup: .ageBelow29))))
				}
			)
		case .removeAllAnalyticsData:
			return DMButtonCellViewModel(
				text: "Remove all analytics data",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					Analytics.deleteAnalyticsData()
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case forceSubmission
		case generateFakedTestData
		case removeAllAnalyticsData
	}

	private let store: Store
	private let client: Client
	private let submitter: PPAnalyticsSubmitter
}
#endif
