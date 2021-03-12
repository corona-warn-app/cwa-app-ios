////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMTraceWarningDownloadTriggerViewModel {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding
	) {
		self.store = store
		self.client = client
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
		case .callDiscovery:
			return DMButtonCellViewModel(
				text: "http discovery",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.client.traceWarningPackageDiscovery(country: "DE", completion: { result in
						
					})
				}
			)
		case .callDownload:
			return DMButtonCellViewModel(
				text: "http download",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.client.traceWarningPackageDownload(country: "DE", completion: { result in
						
					})
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case callDiscovery
		case callDownload
	}

	private let store: Store
	private let client: Client
}
#endif
