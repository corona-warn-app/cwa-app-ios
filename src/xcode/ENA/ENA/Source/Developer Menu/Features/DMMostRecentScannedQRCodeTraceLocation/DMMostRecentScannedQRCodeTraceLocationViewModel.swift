////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMMostRecentScannedQRCodeTraceLocationViewModel {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
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
		case .description:
			let value: String
			if let description = store.recentScannedQRCodeTraceLocation?.description {
				value = String(describing: description)
			} else {
				value = "Could not read description"
			}
			return DMKeyValueCellViewModel(key: "description", value: value)
		case .id:
			let value: String
			if let unwrappedid = store.recentScannedQRCodeTraceLocation?.id,
			   let id = String(data: unwrappedid, encoding: .ascii) {
				value = id
			} else {
				value = "Could not read id"
			}
			return DMKeyValueCellViewModel(key: "id", value: value)
		case .date:
			let value: String
			if let date = store.recentScannedQRCodeTraceLocation?.date {
				value = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
			} else {
				value = "Could not read scanning date"
			}
			return DMKeyValueCellViewModel(key: "scanning date", value: value)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case description
		case id
		case date
	}

	private let store: Store
}
#endif
