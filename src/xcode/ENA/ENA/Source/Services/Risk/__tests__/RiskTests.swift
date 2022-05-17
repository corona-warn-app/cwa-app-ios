////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskTests: CWATestCase {

	func test_When_DateHasHighRiskFromTracing_And_DateHasLowRiskFromCheckin_Then_ResultIsHighRisk() {
		let today = Calendar.utcCalendar.startOfDay(for: Date())

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .low
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .high
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .high)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 1)
	}

	func test_When_DateHasLowRiskFromTracing_And_DateHasHighRiskFromCheckin_Then_ResultIsHighRisk() {
		let today = Calendar.utcCalendar.startOfDay(for: Date())

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .high
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .low
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .high)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 1)
	}

	func test_When_DateHasLowRiskFromTracing_And_DateHasLowRiskFromCheckin_Then_ResultIsLowRisk() {
		let today = Calendar.utcCalendar.startOfDay(for: Date())

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .low
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .low
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .low)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 1)
	}

	func test_When_DateHasHighRiskFromTracing_And_DateHasHighRiskFromCheckin_Then_ResultIsHighRisk() {
		let today = Calendar.utcCalendar.startOfDay(for: Date())

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .high
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .high
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .high)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 1)
	}
	
	func test_RiskChangeWithAllRiskCombinations() {
		
		struct RiskCombination {
			let currentENFRisk: RiskLevel
			let previousENFRisk: RiskLevel
			let currentCheckinRisk: RiskLevel
			let previousCheckinRisk: RiskLevel
			let expectedChange: Risk.RiskLevelChange
			let description: String
		}
		
		let combinations = [
			RiskCombination(currentENFRisk: .low, previousENFRisk: .low, currentCheckinRisk: .low, previousCheckinRisk: .low, expectedChange: .unchanged(.low), description: "1"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .low, currentCheckinRisk: .low, previousCheckinRisk: .high, expectedChange: .decreased, description: "2"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .low, currentCheckinRisk: .high, previousCheckinRisk: .low, expectedChange: .increased, description: "3"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .low, currentCheckinRisk: .high, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "4"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .high, currentCheckinRisk: .low, previousCheckinRisk: .low, expectedChange: .decreased, description: "5"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .high, currentCheckinRisk: .low, previousCheckinRisk: .high, expectedChange: .decreased, description: "6"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .high, currentCheckinRisk: .high, previousCheckinRisk: .low, expectedChange: .unchanged(.high), description: "7"),
			RiskCombination(currentENFRisk: .low, previousENFRisk: .high, currentCheckinRisk: .high, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "8"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .low, currentCheckinRisk: .low, previousCheckinRisk: .low, expectedChange: .increased, description: "9"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .low, currentCheckinRisk: .low, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "10"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .low, currentCheckinRisk: .high, previousCheckinRisk: .low, expectedChange: .increased, description: "11"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .low, currentCheckinRisk: .high, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "12"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .high, currentCheckinRisk: .low, previousCheckinRisk: .low, expectedChange: .unchanged(.high), description: "13"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .high, currentCheckinRisk: .low, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "14"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .high, currentCheckinRisk: .high, previousCheckinRisk: .low, expectedChange: .unchanged(.high), description: "15"),
			RiskCombination(currentENFRisk: .high, previousENFRisk: .high, currentCheckinRisk: .high, previousCheckinRisk: .high, expectedChange: .unchanged(.high), description: "16")
		]
		
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		
		for riskCombination in combinations {
			let risk = Risk(
				enfRiskCalculationResult: makeRiskCalculationResult(
					riskLevel: riskCombination.currentENFRisk,
					riskLevelPerDate: [
						today: riskCombination.currentENFRisk
					]
				),
				previousENFRiskCalculationResult: makeRiskCalculationResult(
					riskLevel: riskCombination.previousENFRisk,
					riskLevelPerDate: [
						today: riskCombination.previousENFRisk
					]
				),
				checkinCalculationResult: CheckinRiskCalculationResult(
					calculationDate: Date(),
					checkinIdsWithRiskPerDate: [:],
					riskLevelPerDate: [
						today: riskCombination.currentCheckinRisk
					]
				),
				previousCheckinCalculationResult: CheckinRiskCalculationResult(
					calculationDate: Date(),
					checkinIdsWithRiskPerDate: [:],
					riskLevelPerDate: [
						today: riskCombination.previousCheckinRisk
					]
				)
			)
			
			XCTAssertEqual(risk.riskLevelChange, riskCombination.expectedChange, riskCombination.description)
		}
		
	}

	func test_When_ResultHasHighRisk_Then_OnlyHighRisksAreCounted() throws {
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let oneDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -1, to: today))
		let threeDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -3, to: today))

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .low,
				oneDayAgo: .low,
				threeDayAgo: .low
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .high
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .high)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 1)
	}

	func test_When_ResultHasLowRisk_Then_OnlyLowRisksAreCounted() throws {
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let oneDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -1, to: today))
		let threeDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -3, to: today))

		let checkinRiskResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [:],
			riskLevelPerDate: [
				today: .low,
				oneDayAgo: .low,
				threeDayAgo: .low
			]
		)

		let tracingRiskResult = makeRiskCalculationResult(
			riskLevelPerDate: [
				today: .low
			]
		)

		let risk = Risk(
			enfRiskCalculationResult: tracingRiskResult,
			checkinCalculationResult: checkinRiskResult
		)

		XCTAssertEqual(risk.level, .low)
		XCTAssertEqual(risk.details.mostRecentDateWithRiskLevel, today)
		XCTAssertEqual(risk.details.numberOfDaysWithRiskLevel, 3)
	}

	private func makeRiskCalculationResult(
		riskLevel: RiskLevel = .low,
		riskLevelPerDate: [Date: RiskLevel]
	) -> ENFRiskCalculationResult {
		
		ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: riskLevelPerDate,
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
}
