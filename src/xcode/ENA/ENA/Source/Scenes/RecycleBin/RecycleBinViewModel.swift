//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class RecycleBinViewModel {

	// MARK: - Init

	init(
		store: RecycleBinStoring,
		recycleBin: RecycleBin,
		onOverwrite: @escaping (RecycleBinItem) -> Void
	) {
		self.store = store
		self.recycleBin = recycleBin
		self.onOverwrite = onOverwrite

		store.recycleBinItemsSubject
			.sink { [weak self] recycleBinItems in
				var items = recycleBinItems
				// If we are in Hibernation we filter the Recycle bin items from user and family tests. i.e return only certificates
				if CWAHibernationProvider.shared.isHibernationState {
					items = recycleBinItems.filter({
						if case .certificate = $0.item {
							return true
						}
						return false
					})
				}
				// now we store the sorted filtered items
				self?.recycleBinItems = items
					.sorted {
						$0.recycledAt > $1.recycledAt
					}
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case entries
	}

	@OpenCombine.Published private(set) var recycleBinItems: [RecycleBinItem] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.entries.rawValue) == 0
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return isEmpty ? 0 : 1
		case .entries:
			return recycleBinItems.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func restoreItem(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		let item = recycleBinItems[indexPath.row]

		switch recycleBin.canRestore(item) {
		case .success:
			recycleBin.restore(item)
		case .failure(.testError(.testTypeAlreadyRegistered)):
			onOverwrite(item)
		}
	}

	func removeEntry(at indexPath: IndexPath) {
		recycleBin.remove(recycleBinItems[indexPath.row])
	}

	func removeAll() {
		recycleBin.removeAll()
	}

	// MARK: - Private

	private let store: RecycleBinStoring
	private let recycleBin: RecycleBin
	private let onOverwrite: (RecycleBinItem) -> Void

	private var subscriptions: [AnyCancellable] = []

}
