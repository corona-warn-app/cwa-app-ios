//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationsOverviewViewModel {

	// MARK: - Init

	init(
//		store: DiaryStoringProviding,
		onAddEntryCellTap: @escaping () -> Void,
		onEntryCellTap: @escaping (TraceLocation) -> Void,
		onSelfCheckInButtonTap: @escaping (TraceLocation) -> Void
	) {
//		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap
		self.onEntryCellTap = onEntryCellTap
		self.onSelfCheckInButtonTap = onSelfCheckInButtonTap

//		store.diaryDaysPublisher
//			.sink { [weak self] days in
//				guard let day = days.first(where: { $0.dateString == day.dateString }) else { return }
//
//				self?.day = day
//			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var traceLocations: [TraceLocation] = [
		TraceLocation(guid: "", version: 0, type: .type1, description: "", address: "", startDate: Date(), endDate: Date(), defaultCheckInLengthInMinutes: 0, signature: "")
	]

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

	func didTapSelfCheckInButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onSelfCheckInButtonTap(traceLocations[indexPath.row])
	}

	// MARK: - Private

//	private let store: DiaryStoringProviding
	private let onAddEntryCellTap: () -> Void
	private let onEntryCellTap: (TraceLocation) -> Void
	private let onSelfCheckInButtonTap: (TraceLocation) -> Void

	private var subscriptions: [AnyCancellable] = []

}
