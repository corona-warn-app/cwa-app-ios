////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMErrorLogSharingViewModel {
	
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
		case .toggleCensoring:
			return DMSwitchCellViewModel(
				labelText: "ELS Log file shall be censored",
				isOn: {
					let elsLoggingCensoring = UserDefaults.standard.bool(forKey: ErrorLogSubmissionService.keyElsLoggingCensoring)
					return elsLoggingCensoring
				},
				toggle: {
					let elsLoggingCensoring = UserDefaults.standard.bool(forKey: ErrorLogSubmissionService.keyElsLoggingCensoring)
					UserDefaults.standard.setValue(!elsLoggingCensoring, forKey: ErrorLogSubmissionService.keyElsLoggingCensoring)
					Log.info("ELS Log will be censored: \(!elsLoggingCensoring)")
				})
			
		case .toggleActiveStartState:
			return DMSwitchCellViewModel(
				labelText: "ELS shall be active at startup",
				isOn: { [store] in
					return store.elsLoggingActiveAtStartup
				},
				toggle: { [store] in
					store.elsLoggingActiveAtStartup.toggle()
				})
		}
	}

	// MARK: - Private

	private let store: Store

	private enum TableViewSections: Int, CaseIterable {
		case toggleCensoring
		case toggleActiveStartState
	}
}

#endif
