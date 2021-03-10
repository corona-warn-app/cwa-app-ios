//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoring & EventProviding,
		onAddEntryCellTap: @escaping () -> Void,
		onEntryCellTap: @escaping (TraceLocation) -> Void,
		onEntryCellButtonTap: @escaping (TraceLocation) -> Void
	) {
		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap
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

	func traceLocationCellModel(at indexPath: IndexPath) -> TraceLocationCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return TraceLocationCellModel()
	}

	func didTapAddEntryCell() {
		onAddEntryCellTap()
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

	// MARK: - Private

	private let store: EventStoring & EventProviding
	private let onAddEntryCellTap: () -> Void
	private let onEntryCellTap: (TraceLocation) -> Void
	private let onEntryCellButtonTap: (TraceLocation) -> Void

	private var subscriptions: [AnyCancellable] = []

}
