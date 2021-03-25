////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinRiskCalculationTests: XCTestCase {

	func test_When_MatchTimeExceedLowRiskRange_Then_HighRiskIsCalculated() {

	}

	func test_When_MatchTimeExceedHighRiskRange_Then_HighRiskIsCalculated() {
		guard let checkin1StartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkin1EndDate = utcFormatter.date(from: "2021-03-05T09:30:00+01:00"),
			  let checkin2StartDate = utcFormatter.date(from: "2021-03-05T13:30:00+01:00"),
			  let checkin2EndDate = utcFormatter.date(from: "2021-03-06T19:30:00+01:00"),
			  let match1StartDate = utcFormatter.date(from: "2021-03-04T10:30:00+01:00"),
			  let match1EndDate = utcFormatter.date(from: "2021-03-06T15:30:00+01:00")else {
			XCTFail("Could not create dates.")
			return
		}

		let config = createAppConfig()
		let appConfigProvider = CachedAppConfigurationMock(with: config)
		let eventStore = MockEventStore()
		let keyValueStore = MockTestStore()
		let checkinSplittingService = CheckinSplittingService()
		let traceWarningMatcher = TraceWarningMatcher(eventStore: eventStore)

		let result1 = eventStore.createCheckin(
			makeDummyCheckin(
				startDate: checkin1StartDate,
				endDate: checkin1EndDate,
				traceLocationGUID: "1"
			)
		)

		let result2 = eventStore.createCheckin(
			makeDummyCheckin(
				startDate: checkin2StartDate,
				endDate: checkin2EndDate,
				traceLocationGUID: "2"
			)
		)

		guard case .success(let checkinId1) = result1 else {
			XCTFail("Success result expected.")
			return
		}

		guard case .success(let checkinId2) = result2 else {
			XCTFail("Success result expected.")
			return
		}

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId1,
				matchStartDate: match1StartDate,
				matchEndDate: match1EndDate,
				transmissionRiskLevel: 2
			)
		)

		eventStore.createTraceTimeIntervalMatch(
			makeDummyMatch(
				checkinId: checkinId2,
				matchStartDate: match1StartDate,
				matchEndDate: match1EndDate,
				transmissionRiskLevel: 2
			)
		)

		let riskCalculation = CheckinRiskCalculation(
			eventStore: eventStore,
			keyValueStore: keyValueStore,
			checkinSplittingService: checkinSplittingService,
			traceWarningMatcher: traceWarningMatcher,
			appConfigProvider: appConfigProvider
		)

		let completionExpectatin = expectation(description: "Completion should be called")
		riskCalculation.calculateRisk {
			completionExpectatin.fulfill()
		}
		waitForExpectations(timeout: .medium)

		guard let checkinRiskCalculationResult = keyValueStore.checkinRiskCalculationResult else {
			XCTFail("checkinRiskCalculationResult should not be nil.")
			return
		}

		let numberOfHighRisks: Int = checkinRiskCalculationResult.riskLevelPerDate.reduce(0) {
			$1.value == .high ? $0 + 1 : $0
		}

		XCTAssertEqual(numberOfHighRisks, 3)
		XCTAssertEqual(checkinRiskCalculationResult.riskLevelPerDate.count, 3)
		XCTAssertEqual(checkinRiskCalculationResult.checkinIdsWithRiskPerDate.count, 3)
	}

	private func createAppConfig() -> SAP_Internal_V2_ApplicationConfigurationIOS {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		var tracingParameters = SAP_Internal_V2_PresenceTracingParameters()
		var transmissionRiskValueMapping = [SAP_Internal_V2_TransmissionRiskValueMapping]()
		var normalizedTimePerCheckInToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var normalizedTimePerDayToRiskLevelMapping = [SAP_Internal_V2_NormalizedTimeToRiskLevelMapping]()
		var riskCalculationParameters = SAP_Internal_V2_PresenceTracingRiskCalculationParameters()

		var riskMapping1 = SAP_Internal_V2_TransmissionRiskValueMapping()
		riskMapping1.transmissionRiskLevel = 1
		riskMapping1.transmissionRiskValue = 1
		transmissionRiskValueMapping.append(riskMapping1)

		var riskMapping2 = SAP_Internal_V2_TransmissionRiskValueMapping()
		riskMapping2.transmissionRiskLevel = 2
		riskMapping2.transmissionRiskValue = 2
		transmissionRiskValueMapping.append(riskMapping2)

		var timeToRiskMappingLow = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var rangeLow = SAP_Internal_V2_Range()
		rangeLow.min = 5
		rangeLow.max = 20
		timeToRiskMappingLow.normalizedTimeRange = rangeLow
		timeToRiskMappingLow.riskLevel = .low

		var timeToRiskMappingHigh = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var rangeHigh = SAP_Internal_V2_Range()
		rangeHigh.minExclusive = true
		rangeHigh.min = 20
		rangeHigh.max = Double.greatestFiniteMagnitude
		timeToRiskMappingHigh.normalizedTimeRange = rangeHigh
		timeToRiskMappingHigh.riskLevel = .high

		normalizedTimePerCheckInToRiskLevelMapping.append(timeToRiskMappingLow)
		normalizedTimePerCheckInToRiskLevelMapping.append(timeToRiskMappingHigh)

		var dayTimeToRiskMappingLow = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var dayRangeLow = SAP_Internal_V2_Range()
		dayRangeLow.min = 20
		dayRangeLow.max = 50
		dayTimeToRiskMappingLow.normalizedTimeRange = dayRangeLow
		dayTimeToRiskMappingLow.riskLevel = .low

		var dayTimeToRiskMappingHigh = SAP_Internal_V2_NormalizedTimeToRiskLevelMapping()
		var dayRangeHigh = SAP_Internal_V2_Range()
		dayRangeHigh.minExclusive = true
		dayRangeHigh.min = 50
		dayRangeHigh.max = Double.greatestFiniteMagnitude
		dayTimeToRiskMappingHigh.normalizedTimeRange = dayRangeHigh
		dayTimeToRiskMappingHigh.riskLevel = .high

		normalizedTimePerDayToRiskLevelMapping.append(dayTimeToRiskMappingLow)
		normalizedTimePerDayToRiskLevelMapping.append(dayTimeToRiskMappingHigh)

		riskCalculationParameters.transmissionRiskValueMapping = transmissionRiskValueMapping
		riskCalculationParameters.normalizedTimePerCheckInToRiskLevelMapping = normalizedTimePerCheckInToRiskLevelMapping
		riskCalculationParameters.normalizedTimePerDayToRiskLevelMapping = normalizedTimePerDayToRiskLevelMapping

		tracingParameters.riskCalculationParameters = riskCalculationParameters
		config.presenceTracingParameters = tracingParameters

		return config
	}

	private func makeDummyCheckin(
		startDate: Date = Date(),
		endDate: Date = Date(),
		traceLocationGUID: String = "0"
	) -> Checkin {
		Checkin(
			id: 0,
			traceLocationGUID: traceLocationGUID,
			traceLocationGUIDHash: traceLocationGUID.data(using: .utf8) ?? Data(),
			traceLocationVersion: 0,
			traceLocationType: .locationTypePermanentCraft,
			traceLocationDescription: "",
			traceLocationAddress: "",
			traceLocationStartDate: Date(),
			traceLocationEndDate: Date(),
			traceLocationDefaultCheckInLengthInMinutes: 0,
			traceLocationSignature: "",
			checkinStartDate: startDate,
			checkinEndDate: endDate,
			checkinCompleted: false,
			createJournalEntry: false
		)
	}

	private func makeDummyMatch(
		checkinId: Int,
		matchStartDate: Date,
		matchEndDate: Date,
		transmissionRiskLevel: Int
	) -> TraceTimeIntervalMatch {
		TraceTimeIntervalMatch(
			id: 0,
			checkinId: checkinId,
			traceWarningPackageId: 0,
			traceLocationGUID: "",
			transmissionRiskLevel: transmissionRiskLevel,
			startIntervalNumber: Int(create10MinutesInterval(from: matchStartDate)),
			endIntervalNumber: Int(create10MinutesInterval(from: matchEndDate))
		)
	}

	private func create10MinutesInterval(from date: Date) -> UInt32 {
		UInt32(date.timeIntervalSince1970 / 600)
	}

	private var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	private lazy var uctCalendar: Calendar = {
		Calendar.utc()
	}()
}
