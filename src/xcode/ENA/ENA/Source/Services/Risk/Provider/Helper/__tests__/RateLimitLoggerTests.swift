////
// 🦠 Corona-Warn-App
//

import os.log
import ExposureNotification

import XCTest
@testable import ENA

// swiftlint:disable:next type_body_length
class RateLimitLoggerTests: CWATestCase {

	func testDescription () {
		let logger = RateLimitLogger(store: MockTestStore())

		let failure = ExposureDetection.DidEndPrematurelyReason.wrongDeviceTime
		let error = ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ExposureDetectionError.isAlreadyRunning, Date())
		let enError1 = ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.unknown), Date())
		let enError11 = ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.internal), Date())
		let enError12 = ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.insufficientMemory), Date())
		let enError13 = ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.rateLimited), Date())

		XCTAssertEqual(logger.description(reason: failure), "failure")
		XCTAssertEqual(logger.description(reason: error), "error")
		XCTAssertEqual(logger.description(reason: enError1), "ENError 1")
		XCTAssertEqual(logger.description(reason: enError11), "ENError 11")
		XCTAssertEqual(logger.description(reason: enError12), "ENError 12")
		XCTAssertEqual(logger.description(reason: enError13), "ENError 13")
	}

	func test_WhenEnoughTimeHasPassed_ThenNoRateLimit() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking = logger.logBlocking(configuration: config)

		XCTAssertFalse(blocking, "Soft rate limit should not block exposure detection")
		XCTAssertNil(logger.previousErrorCode, "No previous error code expected")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_WhenNotEnoughTimeHasPassed_ThenRateLimit() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .second,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking = logger.logBlocking(configuration: config)

		XCTAssertTrue(blocking, "Soft rate limit should block the exposure detection")
		XCTAssertNil(logger.previousErrorCode, "No previous error code expected")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_thatSoftRateLimitBlocksSecondRiskCheck() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		_ = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking = logger.logBlocking(configuration: config)

		XCTAssertTrue(blocking, "Soft rate limit shall block second exposure detection")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}
		
	func test_GoodcaseScenario() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()
		let result: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])

		let blocking = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		logger.logEffect(result: result, blocking: blocking)

		XCTAssertFalse(blocking, "Soft rate limit should not block exposure detection")
		XCTAssertNil(logger.previousErrorCode, "No error code expected")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_BadcaseScenarioWithENError() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()
		let result: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.unknown), Date()))

		let blocking = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		logger.logEffect(result: result, blocking: blocking)

		XCTAssertFalse(blocking, "Soft rate limit should not block exposure detection")
		XCTAssertEqual(logger.previousErrorCode, ENError.unknown, "Should remember error code")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_thatOtherErrorsDontOverwritePreviousSuccess() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()
		let result0: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.wrongDeviceTime)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ExposureDetectionError.isAlreadyRunning, Date()))

		let blocking = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		logger.logEffect(result: result0, blocking: blocking)
		XCTAssertNil(logger.previousErrorCode, "Should remember success")
		logger.logEffect(result: result1, blocking: blocking)
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		logger.logEffect(result: result2, blocking: blocking)
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_thatOtherErrorsDontOverwritePreviousENError() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()
		let result0: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.insufficientMemory), Date()))
		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.wrongDeviceTime)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ExposureDetectionError.isAlreadyRunning, Date()))

		let blocking = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		logger.logEffect(result: result0, blocking: blocking)
		XCTAssertEqual(logger.previousErrorCode, ENError.insufficientMemory, "Should remember error code")
		logger.logEffect(result: result1, blocking: blocking)
		XCTAssertEqual(logger.previousErrorCode, ENError.insufficientMemory, "Should not overwrite error code")
		logger.logEffect(result: result2, blocking: blocking)
		XCTAssertEqual(logger.previousErrorCode, ENError.insufficientMemory, "Should not overwrite error code")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}
	
	func test_interleavedRiskChecksWithError13() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit would have prevented this ENError 13"),
			MockLogger.Item(type: "Info", message: "Previous call to ENF was successful")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.rateLimited), Date()))
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit blocks second exposure detection")
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_separateRiskChecksWithError13() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit would NOT have prevented this ENError 13"),
			MockLogger.Item(type: "Info", message: "Previous call to ENF was successful")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let firstExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -10,
			to: Date(),
			wrappingComponents: false
		))
		let secondExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = firstExposureDetectionDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = secondExposureDetectionDate
		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)

		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.rateLimited), Date()))
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertFalse(blocking2, "Soft rate limit does not block second exposure detection")
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_interleavedRiskChecksBlockingTooMuchSuccess() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Warning", message: "Soft rate limit is too strict - it would have blocked this successful exposure detection")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit blocks second exposure detection")
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_interleavedRiskChecksBlockingTooMuchENError() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Warning", message: "Soft rate limit is too strict - it would have blocked this exposure detection with ENError 12")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.insufficientMemory), Date()))
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit blocks second exposure detection")
		XCTAssertEqual(logger.previousErrorCode?.rawValue, 12, "Should remember ENError code")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_interleavedRiskChecksBlockingTooMuchError() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Warning", message: "Soft rate limit is too strict - it would have blocked this exposure detection with error")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ExposureDetectionError.isAlreadyRunning, Date()))
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit blocks second exposure detection")
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_interleavedRiskChecksBlockingTooMuchFailure() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Warning", message: "Soft rate limit is too strict - it would have blocked this exposure detection with failure")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()

		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .success([MutableENExposureWindow()])
		logger.logEffect(result: result1, blocking: blocking1)
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.wrongDeviceTime)
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit blocks second exposure detection")
		XCTAssertNil(logger.previousErrorCode, "Should not overwrite success")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}

	func test_ENError13_After_ENError() throws {
		let expectedLogMessages = [
			MockLogger.Item(type: "Debug", message: "Soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Info", message: "Soft rate limit would have prevented this ENError 13"),
			MockLogger.Item(type: "Info", message: "Previous ENError code = 11")
		]
		let mock = MockLogger()
		let store = MockTestStore()
		let calendar = Calendar.current
		let previousReferenceDate = try XCTUnwrap(calendar.date(
			byAdding: .hour,
			value: -5,
			to: Date(),
			wrappingComponents: false
		))
		store.referenceDateForRateLimitLogger = previousReferenceDate
		let logger = RateLimitLogger(store: store, logger: mock)
		let config = makeRiskConfigHighFrequency()

		let blocking1 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		let result1: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.internal), Date()))
		logger.logEffect(result: result1, blocking: blocking1)

		let blocking2 = logger.logBlocking(configuration: config)
		store.referenceDateForRateLimitLogger = Date()
		// Note: according to Apple, ENError does not count against their rate limit.
		// See https://github.com/corona-warn-app/cwa-app-ios/pull/3284#issuecomment-890104094
		// Still we test here also this edge case.
		let result2: Result<[ENExposureWindow], ExposureDetection.DidEndPrematurelyReason> = .failure(ExposureDetection.DidEndPrematurelyReason.noExposureWindows(ENError(.rateLimited), Date()))
		logger.logEffect(result: result2, blocking: blocking2)

		XCTAssertTrue(blocking2, "Soft rate limit shall block exposure detection shortly after ENError")
		XCTAssertEqual(mock.data, expectedLogMessages)
	}
}

private func makeRiskConfigHighFrequency() -> RiskProvidingConfiguration {
	let exposureChecksPerDay = 6
	let validityDuration = DateComponents(day: 1)
	return RiskProvidingConfiguration(
		exposureDetectionValidityDuration: validityDuration,
		exposureDetectionInterval: DateComponents(hour: 24 / exposureChecksPerDay),
		detectionMode: .automatic
	)
}
