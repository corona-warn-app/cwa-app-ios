////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskTests: XCTestCase {

	func test_When_DateHasHighRiskFromTracing_And_DateHasLowRiskFromCheckin_Then_ResultIsHighRisk() {
		let today = Calendar.utcCalendar.startOfDay(for: Date())

		let checkinRiskResult = CheckinRiskCalculationResult(
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

	func test_When_ResultHasHighRisk_Then_OnlyHighRisksAreCounted() throws {
		let today = Calendar.utcCalendar.startOfDay(for: Date())
		let oneDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -1, to: today))
		let threeDayAgo = try XCTUnwrap(Calendar.utcCalendar.date(byAdding: .day, value: -3, to: today))

		let checkinRiskResult = CheckinRiskCalculationResult(
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

	private func makeRiskCalculationResult(riskLevelPerDate: [Date: RiskLevel]) -> ENFRiskCalculationResult {
		ENFRiskCalculationResult(
			riskLevel: .low,
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
