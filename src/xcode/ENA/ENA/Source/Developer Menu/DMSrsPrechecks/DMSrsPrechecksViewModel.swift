////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMSRSPrechecksViewModel {
	
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
		case .preChecks:
			return DMSwitchCellViewModel(
				labelText: "Enable pre-checks for SRS",
				isOn: { [store] in
					return store.isSrsPrechecksEnabled
				},
				toggle: { [store] in
					store.isSrsPrechecksEnabled.toggle()
				})
		}
	}

	// MARK: - Private

	private let store: Store

	private enum TableViewSections: Int, CaseIterable {
		case preChecks
	}
}

#endif
