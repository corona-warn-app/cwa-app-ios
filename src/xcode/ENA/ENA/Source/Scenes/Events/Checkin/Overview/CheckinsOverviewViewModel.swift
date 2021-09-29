//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class CheckinsOverviewViewModel {

	// MARK: - Init

	init(
		store: EventStoringProviding,
		eventCheckoutService: EventCheckoutService,
		onEntryCellTap: @escaping (Checkin) -> Void
	) {
		self.store = store
		self.eventCheckoutService = eventCheckoutService
		self.onEntryCellTap = onEntryCellTap

		store.checkinsPublisher
			.sink { [weak self] in
				self?.update(from: $0)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published var triggerReload: Bool = false

	var onUpdate: (() -> Void)?

	var checkinCellModels: [CheckinCellModel] = []

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

		eventCheckoutService.checkout(
			checkin: checkinCellModels[indexPath.row].checkin,
			manually: true
		)
	}

	func removeEntry(at indexPath: IndexPath) {
		store.deleteCheckin(id: checkinCellModels[indexPath.row].checkin.id)
	}

	func removeAll() {
		store.deleteAllCheckins()
	}

	func checkoutOverdueCheckins() {
		eventCheckoutService.checkoutOverdueCheckins()
	}

	// MARK: - Private

	private let store: EventStoringProviding
	private let eventCheckoutService: EventCheckoutService
	private let onEntryCellTap: (Checkin) -> Void

	private var subscriptions: [AnyCancellable] = []

	private func update(from checkins: [Checkin]) {
		if checkins.map({ $0.id }) != checkinCellModels.map({ $0.checkin.id }) {
			checkinCellModels.forEach {
				$0.invalidateTimer()
			}

			checkinCellModels = checkins.map { checkin in
				CheckinCellModel(
					checkin: checkin,
					eventCheckoutService: eventCheckoutService,
					onUpdate: { [weak self] in
						self?.onUpdate?()
					}
				)
			}

			triggerReload = true
		} else {
			checkinCellModels.forEach { cellModel in
				guard let checkin = checkins.first(where: { $0.id == cellModel.checkin.id }) else {
					return
				}

				cellModel.update(with: checkin)
			}
		}
	}

}
