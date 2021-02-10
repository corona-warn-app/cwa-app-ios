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
		case .mostRecentSubmission:
			let mostRecentSubmission = "Hallo"
			return DMTextViewCellViewModel(text: mostRecentSubmission)
		case .captureUsageData:
			let data = "Data"
			return DMTextViewCellViewModel(text: data)
		case .forceSubmission:
			return DMButtonCellViewModel(
				text: "Force Analytics Submission",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.submitter.forcedSubmitData(completion: { [weak self] result in
						switch result {
						case .success:
							self?.refreshTableView([TableViewSections.mostRecentSubmission.rawValue, TableViewSections.captureUsageData.rawValue, TableViewSections.forceSubmission.rawValue])
						case let .failure(error):
							let alert = UIAlertController(title: "Data submission error", message: "Error code: \(error)", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
							self?.showAlert?(alert)

							self?.refreshTableView([TableViewSections.mostRecentSubmission.rawValue, TableViewSections.captureUsageData.rawValue, TableViewSections.forceSubmission.rawValue])
						}
					})
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case mostRecentSubmission
		case captureUsageData
		case forceSubmission
	}

	private let store: Store
	private let client: Client
	private let submitter: PPAnalyticsSubmitter
}
#endif
