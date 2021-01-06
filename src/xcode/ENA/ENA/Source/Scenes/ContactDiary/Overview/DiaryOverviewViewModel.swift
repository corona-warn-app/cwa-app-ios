////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class DiaryOverviewViewModel {

	// MARK: - Init

	init(store: DiaryStoringProviding) {
		self.store = store

		store.diaryDaysPublisher.sink { [weak self] in
			self?.days = $0
		}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case days
	}

	@OpenCombine.Published private(set) var days: [DiaryDay] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .description:
			return 1
		case .days:
			return days.count
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let store: DiaryStoringProviding

	private var subscriptions: [AnyCancellable] = []

}
