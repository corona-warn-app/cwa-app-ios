////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class DiaryOverviewViewModel {

	// MARK: - Init

	init(
		diaryStore: DiaryStoringProviding,
		store: Store,
		homeState: HomeState? = nil
	) {
		self.diaryStore = diaryStore
		self.secureStore = store

		$days
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.refreshTableView?()
			}
			.store(in: &subscriptions)

		diaryStore.diaryDaysPublisher.sink { [weak self] in
			self?.days = $0
		}.store(in: &subscriptions)

		homeState?.$riskState
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] updatedRiskState in
				switch updatedRiskState {
				case .risk:
					self?.refreshTableView?()
				default:
					break
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case description
		case days
	}

	@OpenCombine.Published private var days: [DiaryDay] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var refreshTableView: (() -> Void)?

	func day(by indexPath: IndexPath) -> DiaryDay {
		return days[indexPath.row]
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

	func cellModel(for indexPath: IndexPath) -> DiaryOverviewDayCellModel {
		let diaryDay = days[indexPath.row]
		let currentHistoryExposure = historyExposure(by: diaryDay.date)
		return DiaryOverviewDayCellModel(diaryDay, historyExposure: currentHistoryExposure)
	}

	// MARK: - Private

	private let diaryStore: DiaryStoringProviding
	private let secureStore: Store

	private var subscriptions: [AnyCancellable] = []

	private func historyExposure(by date: Date) -> HistoryExposure {
		guard let riskLevelPerDate = secureStore.riskCalculationResult?.riskLevelPerDate[date] else {
			return .none
		}
		return .encounter(riskLevelPerDate)
	}

}
