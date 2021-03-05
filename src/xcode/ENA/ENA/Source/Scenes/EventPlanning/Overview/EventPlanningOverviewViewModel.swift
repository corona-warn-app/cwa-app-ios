//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class EventPlanningOverviewViewModel {

	// MARK: - Init

	init(
//		store: DiaryStoringProviding
	) {
//		self.store = store
//
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

//	@OpenCombine.Published private(set) var day: DiaryDay

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
			return 1 // entriesOfSelectedType.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func eventCellModel(at indexPath: IndexPath) -> EventCellModel {
		guard indexPath.section == Section.entries.rawValue else {
			fatalError("Entry cell models have to used in the entries section")
		}

		return EventCellModel()
	}

	// MARK: - Private

//	private let store: DiaryStoringProviding

	private var subscriptions: [AnyCancellable] = []

}
