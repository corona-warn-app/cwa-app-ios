//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA
import XCTest

final class RiskProvidingConfigurationTests: XCTestCase {
	private let validityDuration = DateComponents(day: 2)
	private let detectionInterval = DateComponents(day: 1)
	private lazy var config = RiskProvidingConfiguration(
		exposureDetectionValidityDuration: validityDuration,
		exposureDetectionInterval: detectionInterval,
		detectionMode: .default
	)

	// MARK: - Calculating next exposure detection date

	func testGetNextExposureDetectionDate_NoExposurePerformedInPast() {
		// Test the case where we want to get the next exposure date,
		// when we have not done the exposure detection before
		let now = Date()
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: nil, currentDate: now), now)
	}

	func testGetNextExposureDetectionDate_in22Hours() throws {
		// Test the case where the last exposure detection date is in the future.
		// This edge case should be handled by just returning now as the next detection date

		let testDate = Date(timeIntervalSince1970: 1466467200.0)  // 21.06.2016
		let twoHoursAgo = Calendar.current.date(byAdding: DateComponents(hour: -2), to: testDate)
		let inTwentyTwoHours = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(hour: 22), to: testDate))
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: twoHoursAgo, currentDate: testDate), inTwentyTwoHours)
	}

	func testGetNextExposureDetectionDate_Success() {
		// Test the case where everything just works and you get a valid next date in the future.
		let now = Date()
		XCTAssertFalse(config.shouldPerformExposureDetection(lastExposureDetectionDate: now, currentDate: now))
	}

	// MARK: - Should perform exposure detection tests

	func testShouldPerformExposureDetection_PastLastDetection() {
		// Test the case when last detection was performed recently
		// There should be no need to do the detection again.
		let lastDetection = Calendar.current.date(byAdding: DateComponents(hour: -1), to: Date()) ?? .distantPast
		XCTAssertFalse(config.shouldPerformExposureDetection(lastExposureDetectionDate: lastDetection))
	}

	func testShouldPerformExposureDetection_LastDetectionNow() {
		// Test the case when last detection was performed at this instant
		// There should be no need to do the detection again
		let now = Date()
		XCTAssertFalse(config.shouldPerformExposureDetection(lastExposureDetectionDate: now, currentDate: now))
	}

	func testShouldPerformExposureDetection_LastDetectionFuture() {
		// Test the case when last detection was performed in the future.
		// This is not valid, and a detection should be performed.
		XCTAssertTrue(config.shouldPerformExposureDetection(lastExposureDetectionDate: Date().addingTimeInterval(10000)))
	}

	func testShouldPerformExposureDetection_LastDetectionDistantPast() {
		// Test the case when last detection was performed in the past
		// Detection is necessary
		XCTAssertTrue(config.shouldPerformExposureDetection(lastExposureDetectionDate: .distantPast))
	}

	func testShouldPerformExposureDetection_NilLastDetection() {
		// Test the case when last detection not performed at all
		// Detection is necessary
		XCTAssertTrue(config.shouldPerformExposureDetection(lastExposureDetectionDate: nil))
	}
	
	func testExposureDetectionValidUntil_Case() {
		// Last exposure detection date was last night
		// Now it is morning, and we start the app again
		let lastEvening = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 6, hour: 22, minute: 0, second: 0)) ?? .distantPast
		let nowMorning = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 7, hour: 7, minute: 0, second: 0)) ?? .distantPast

		XCTAssertFalse(config.shouldPerformExposureDetection(lastExposureDetectionDate: lastEvening, currentDate: nowMorning))
	}

	func testShouldPerformExposureDetection_Success() {
		// Test the case where everything just works and you get a valid next date in the future.
		let now = Date()
		XCTAssertFalse(config.shouldPerformExposureDetection(lastExposureDetectionDate: now, currentDate: now))
	}
}
