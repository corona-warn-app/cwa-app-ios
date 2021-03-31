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
		guard let riskLevelPerDate = secureStore.enfRiskCalculationResult?.riskLevelPerDate[date] else {
			return .none
		}
		return .encounter(riskLevelPerDate)
	}

	private func minimumDistinctEncountersWithHighRiskValue(by date: Date) -> Int {
		guard let minimumDistinctEncountersWithHighRisk = secureStore.enfRiskCalculationResult?.minimumDistinctEncountersWithHighRiskPerDate[date] else {
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
				let riskLevel = RiskLevel(rawValue: rawValue)
                return createFakeDataForCheckin(with: riskLevel ?? .low)
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
	
	#if DEBUG
	// needs to be injected here for the ui tests.
	private func createFakeDataForCheckin(with risk: RiskLevel) -> [CheckinWithRisk] {
		
		let fakedCheckin1 = Checkin(
			id: 0,
			traceLocationId: Data(),
			traceLocationIdHash: Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentFoodService,
			traceLocationDescription: "Supermarkt",
			traceLocationAddress: "",
			traceLocationStartDate: nil,
			traceLocationEndDate: nil,
			traceLocationDefaultCheckInLengthInMinutes: nil,
			cryptographicSeed: Data(),
			cnPublicKey: Data(),
			checkinStartDate: Date(),
			checkinEndDate: Date(),
			checkinCompleted: true,
			createJournalEntry: false)
		let highRiskCheckin1 = CheckinWithRisk(checkIn: fakedCheckin1, risk: .low)
		let fakedCheckin2 = Checkin(
			id: 0,
			traceLocationId: Data(),
			traceLocationIdHash: Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentWorkplace,
			traceLocationDescription: "Büro",
			traceLocationAddress: "",
			traceLocationStartDate: nil,
			traceLocationEndDate: nil,
			traceLocationDefaultCheckInLengthInMinutes: nil,
			cryptographicSeed: Data(),
			cnPublicKey: Data(),
			checkinStartDate: Date(),
			checkinEndDate: Date(),
			checkinCompleted: true,
			createJournalEntry: false)
		let highRiskCheckin2 = CheckinWithRisk(checkIn: fakedCheckin2, risk: risk)
		let fakedCheckin3 = Checkin(
			id: 0,
			traceLocationId: Data(),
			traceLocationIdHash: Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentWorkplace,
			traceLocationDescription: "privates Treffen mit Freunden",
			traceLocationAddress: "",
			traceLocationStartDate: nil,
			traceLocationEndDate: nil,
			traceLocationDefaultCheckInLengthInMinutes: nil,
			cryptographicSeed: Data(),
			cnPublicKey: Data(),
			checkinStartDate: Date(),
			checkinEndDate: Date(),
			checkinCompleted: true,
			createJournalEntry: false)
		let highRiskCheckin3 = CheckinWithRisk(checkIn: fakedCheckin3, risk: risk)
		return [highRiskCheckin1, highRiskCheckin2, highRiskCheckin3]
		
	}
	#endif
}
