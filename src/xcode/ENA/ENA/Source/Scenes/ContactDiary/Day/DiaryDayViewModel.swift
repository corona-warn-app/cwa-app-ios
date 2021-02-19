////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryDayViewModel {

	// MARK: - Init

	init(
		day: DiaryDay,
		store: DiaryStoringProviding,
		onAddEntryCellTap: @escaping (DiaryDay, DiaryEntryType) -> Void
	) {
		self.day = day
		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap

		store.diaryDaysPublisher
			.sink { [weak self] days in
				guard let day = days.first(where: { $0.dateString == day.dateString }) else { return }

				self?.day = day
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var day: DiaryDay
	@OpenCombine.Published var selectedEntryType: DiaryEntryType = .contactPerson

	var entriesOfSelectedType: [DiaryEntry] {
		day.entries.filter {
			$0.type == selectedEntryType
		}
	}

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .add:
			return 1
		case .entries:
			return entriesOfSelectedType.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func entryCellModel(at indexPath: IndexPath) -> DiaryDayEntryCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return DiaryDayEntryCellModel(
			entry: entriesOfSelectedType[indexPath.row],
			dateString: day.dateString,
			store: store
		)
	}

	func didTapAddEntryCell() {
		onAddEntryCellTap(day, selectedEntryType)
	}

	// MARK: - Private

	private let store: DiaryStoringProviding
	private let onAddEntryCellTap: (DiaryDay, DiaryEntryType) -> Void

	private var subscriptions: [AnyCancellable] = []

}
