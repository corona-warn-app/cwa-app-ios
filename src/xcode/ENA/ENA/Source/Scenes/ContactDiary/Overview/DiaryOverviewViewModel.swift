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
		eventStore: EventStoringProviding,
		homeState: HomeState? = nil
	) {
		self.diaryStore = diaryStore
		self.secureStore = store
		self.eventStore = eventStore

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

	@OpenCombine.Published private(set) var days: [DiaryDay] = []

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
		let currentHistoryExposure = historyExposure(by: diaryDay.utcMidnightDate)
		let minimumDistinctEncountersWithHighRisk = minimumDistinctEncountersWithHighRiskValue(by: diaryDay.utcMidnightDate)
		let checkinsWithRisk = checkinsWithRiskFor(day: diaryDay.utcMidnightDate)

		return DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: currentHistoryExposure,
			minimumDistinctEncountersWithHighRisk: minimumDistinctEncountersWithHighRisk,
			checkinsWithRisk: checkinsWithRisk
		)
	}

	// MARK: - Private

	private let diaryStore: DiaryStoringProviding
	private let secureStore: Store
	private let eventStore: EventStoringProviding

	private var subscriptions: [AnyCancellable] = []

	private func historyExposure(by date: Date) -> HistoryExposure {
		guard let riskLevelPerDate = secureStore.riskCalculationResult?.riskLevelPerDate[date] else {
			return .none
		}
		return .encounter(riskLevelPerDate)
	}

	private func minimumDistinctEncountersWithHighRiskValue(by date: Date) -> Int {
		guard let minimumDistinctEncountersWithHighRisk = secureStore.riskCalculationResult?.minimumDistinctEncountersWithHighRiskPerDate[date] else {
			return -1
		}
		return minimumDistinctEncountersWithHighRisk
	}
	
	private func checkinsWithRiskFor(day: Date) -> [CheckinWithRisk] {
		#if DEBUG
		// ui test data for launch argument "-checkinRiskLevel"
		if isUITesting {
			if let checkinRisk = UserDefaults.standard.string(forKey: "checkinRiskLevel") {
				let rawValue = checkinRisk == "high" ? 2 : 1
				let riskLevel = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel(rawValue: rawValue)
				let fakedCheckin = Checkin(
					id: 0,
					traceLocationGUID: "",
					traceLocationGUIDHash: Data(),
					traceLocationVersion: 0,
					traceLocationType: .locationTypePermanentFoodService,
					traceLocationDescription: "Supermarkt",
					traceLocationAddress: "",
					traceLocationStartDate: nil,
					traceLocationEndDate: nil,
					traceLocationDefaultCheckInLengthInMinutes: nil,
					traceLocationSignature: "",
					checkinStartDate: Date(),
					checkinEndDate: Date(),
					checkinCompleted: true,
					createJournalEntry: false)
				let highRiskCheckin = CheckinWithRisk(checkIn: fakedCheckin, risk: riskLevel ?? .high)
				return [highRiskCheckin]
				
			}
		}
		#endif
		
		guard let result = secureStore.checkinRiskCalculationResult else {
			return []
		}

		let checkinIdsWithRisk = result.checkinIdsWithRiskPerDate.filter({
			$0.key == day
		}).flatMap { $0.value }

		var checkinsWithRisk: [CheckinWithRisk] = []
		
		checkinIdsWithRisk.forEach { checkinIdWithRisk in
			for checkin in eventStore.checkinsPublisher.value where checkinIdWithRisk.checkinId == checkin.id {
				checkinsWithRisk.append(CheckinWithRisk(checkIn: checkin, risk: checkinIdWithRisk.riskLevel))
			}
		}
		
		return checkinsWithRisk
	}
}
