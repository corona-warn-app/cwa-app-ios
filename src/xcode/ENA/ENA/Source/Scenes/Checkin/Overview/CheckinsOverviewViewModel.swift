//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CheckinsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoringProviding,
		onAddEntryCellTap: @escaping () -> Void,
		onEntryCellTap: @escaping (Checkin) -> Void
	) {
		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap
		self.onEntryCellTap = onEntryCellTap

		store.checkinsPublisher
			.map { $0.sorted { $0.checkinStartDate < $1.checkinStartDate } }
			.sink { [weak self] checkins in
				guard let self = self else { return }

				if checkins.map({ $0.id }) != self.checkinCellModels.map({ $0.checkin.id }) {
					self.checkinCellModels = checkins.map { checkin in
						CheckinCellModel(
							checkin: checkin,
							eventProvider: store,
							onUpdate: {
								self.onUpdate?()
							}
						)
					}

					self.shouldReload = true
				} else {
					self.checkinCellModels.forEach { cellModel in
						guard let checkin = checkins.first(where: { $0.id == cellModel.checkin.id }) else {
							return
						}

						cellModel.update(with: checkin)
					}
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var shouldReload: Bool = false

	var onUpdate: (() -> Void)?

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
			return checkinCellModels.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.entries.rawValue
	}

	func checkinCellModel(
		at indexPath: IndexPath
	) -> CheckinCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return checkinCellModels[indexPath.row]
	}

	func didTapAddEntryCell() {
		onAddEntryCellTap()
	}

	func didTapEntryCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		onEntryCellTap(checkinCellModels[indexPath.row].checkin)
	}

	func didTapEntryCellButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("didTapEntryCell can only be called from the entries section")
		}

		let checkin = checkinCellModels[indexPath.row].checkin
		let updatedChecking = Checkin(
			id: checkin.id,
			traceLocationGUID: checkin.traceLocationGUID,
			traceLocationVersion: checkin.traceLocationVersion,
			traceLocationType: checkin.traceLocationType,
			traceLocationDescription: checkin.traceLocationDescription,
			traceLocationAddress: checkin.traceLocationAddress,
			traceLocationStartDate: checkin.traceLocationStartDate,
			traceLocationEndDate: checkin.traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: checkin.traceLocationDefaultCheckInLengthInMinutes,
			traceLocationSignature: checkin.traceLocationSignature,
			checkinStartDate: checkin.checkinStartDate,
			checkinEndDate: Date(),
			targetCheckinEndDate: checkin.targetCheckinEndDate,
			createJournalEntry: checkin.createJournalEntry
		)

		store.updateCheckin(updatedChecking)
	}

	func removeEntry(at indexPath: IndexPath) {
		store.deleteCheckin(id: checkinCellModels[indexPath.row].checkin.id)
	}

	func removeAll() {
		store.deleteAllCheckins()
	}

	// MARK: - Private

	private var checkinCellModels: [CheckinCellModel] = []

	private let store: EventStoringProviding
	private let onAddEntryCellTap: () -> Void
	private let onEntryCellTap: (Checkin) -> Void

	private var subscriptions: [AnyCancellable] = []

}
