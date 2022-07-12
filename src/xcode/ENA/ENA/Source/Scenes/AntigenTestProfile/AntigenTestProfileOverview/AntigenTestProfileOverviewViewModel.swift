//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AntigenTestProfileOverviewViewModel {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		onEntryCellTap: @escaping (AntigenTestProfile) -> Void
	) {
		self.store = store
		self.onEntryCellTap = onEntryCellTap
		
		refreshFromStore()
	}
	
	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var antigenTestProfiles: [AntigenTestProfile] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.entries.rawValue) == 0
	}

	func refreshFromStore() {
		self.antigenTestProfiles = store.antigenTestProfiles
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .add:
			return 1
		case .entries:
			return antigenTestProfiles.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func antigenTestPersonProfileCellModel(at indexPath: IndexPath) -> AntigenTestPersonProfileCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return AntigenTestPersonProfileCellModel(
			antigenTestProfile: antigenTestProfiles[indexPath.row]
		)
	}

	func didTapEntryCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellTap(antigenTestProfiles[indexPath.row])
	}
	
	func markScreenSeen() {
		store.antigenTestProfileInfoScreenShown = true
	}

	// MARK: - Private

	private let store: AntigenTestProfileStoring
	private let onEntryCellTap: (AntigenTestProfile) -> Void

	private var subscriptions: [AnyCancellable] = []

}
