//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoring & EventProviding,
		onAddEntryCellTap: @escaping () -> Void,
		onEntryCellTap: @escaping (Checkin) -> Void,
		onEntryCellButtonTap: @escaping (Checkin) -> Void
	) {
		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap
		self.onEntryCellTap = onEntryCellTap
		self.onEntryCellButtonTap = onEntryCellButtonTap

		store.checkinsPublisher
			.sink { [weak self] in
				self?.checkins = $0
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var checkins: [Checkin] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.entries.rawValue) == 0
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .add:
			return 1
		case .entries:
			return checkins.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func checkinCellModel(
		at indexPath: IndexPath,
		onUpdate: @escaping () -> Void,
		forceReload: @escaping () -> Void
	) -> CheckinCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return CheckinCellModel(
			checkin: checkins[indexPath.row],
			eventProvider: store,
			onUpdate: onUpdate,
			forceReload: forceReload
		)
	}

	func didTapAddEntryCell() {
		onAddEntryCellTap()
	}

	func didTapEntryCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellTap(checkins[indexPath.row])
	}

	func didTapEntryCellButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellButtonTap(checkins[indexPath.row])
	}

	func removeEntry(at indexPath: IndexPath) {
		store.deleteCheckin(id: checkins[indexPath.row].id)
	}

	func removeAll() {
		store.deleteAllCheckins()
	}

	// MARK: - Private

	private let store: EventStoring & EventProviding
	private let onAddEntryCellTap: () -> Void
	private let onEntryCellTap: (Checkin) -> Void
	private let onEntryCellButtonTap: (Checkin) -> Void

	private var subscriptions: [AnyCancellable] = []

}
