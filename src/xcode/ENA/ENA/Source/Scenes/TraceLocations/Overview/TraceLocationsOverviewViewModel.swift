//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoringProviding,
		onEntryCellTap: @escaping (TraceLocation) -> Void,
		onEntryCellButtonTap: @escaping (TraceLocation) -> Void
	) {
		self.store = store
		self.onEntryCellTap = onEntryCellTap
		self.onEntryCellButtonTap = onEntryCellButtonTap

		store.traceLocationsPublisher
			.sink { [weak self] in
				self?.traceLocations = $0
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var traceLocations: [TraceLocation] = []

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
			return traceLocations.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func traceLocationCellModel(at indexPath: IndexPath, onUpdate: @escaping () -> Void) -> TraceLocationCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return TraceLocationCellModel(
			traceLocation: traceLocations[indexPath.row],
			eventProvider: store,
			onUpdate: onUpdate
		)
	}

	func didTapEntryCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellTap(traceLocations[indexPath.row])
	}

	func didTapEntryCellButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellButtonTap(traceLocations[indexPath.row])
	}

	func removeEntry(at indexPath: IndexPath) {
		store.deleteTraceLocation(id: traceLocations[indexPath.row].id)
	}

	func removeAll() {
		store.deleteAllTraceLocations()
	}

	// MARK: - Private

	private let store: EventStoringProviding
	private let onEntryCellTap: (TraceLocation) -> Void
	private let onEntryCellButtonTap: (TraceLocation) -> Void

	private var subscriptions: [AnyCancellable] = []

}
