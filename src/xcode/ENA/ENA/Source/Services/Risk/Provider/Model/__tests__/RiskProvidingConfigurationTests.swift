//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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

	// MARK: - Calculating exposure valid until Date

	func testExposureDetectionValidUntil_Now() {
		// Test the case where the last exposure detection was exactly two days ago.
		// We should get now back
		let now = Date()
		let twoDaysPast = Calendar.current.date(byAdding: DateComponents(day: -2), to: now)
		XCTAssertEqual(config.exposureDetectionValidUntil(lastExposureDetectionDate: twoDaysPast), now)
	}

	func testExposureDetectionValidUntil_NilLastDetectionDate() {
		// Test the case where the last exposure detection date is nil.
		// We should get .distantPast + validityDuration back
		let now = Date.distantPast
		let until = Calendar.current.date(byAdding: validityDuration, to: now)
		XCTAssertEqual(config.exposureDetectionValidUntil(lastExposureDetectionDate: nil), until)
	}

	func testExposureDetectionValidUntil_NowLastDetectionDate() {
		// Test the case where the last exposure detection was right now.
		// We should get .distantPast + validityDuration back
		let now = Date()
		let until = Calendar.current.date(byAdding: validityDuration, to: now)
		XCTAssertEqual(config.exposureDetectionValidUntil(lastExposureDetectionDate: now), until)
	}

	// MARK: - Calculating next exposure detection date

	func testGetNextExposureDetectionDate_NoExposurePerformedInPast() {
		// Test the case where we want to get the next exposure date,
		// when we have not done the exposure detection before
		// The expected date for us to get back would be the the distantPast + detectionInterval
		let nextExpectedDate = Calendar.current.date(byAdding: detectionInterval, to: .distantPast)
		let now = Date()
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: nil, currentDate: now), nextExpectedDate)
	}

	func testGetNextExposureDetectionDate_FutureLastDetectionDate() {
		// Test the case where the last exposure detection date is in the future.
		// This edge case should be handled by just returning now as the next detection date
		let now = Date()
		let future = Calendar.current.date(byAdding: DateComponents(day: 10), to: now)
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: future, currentDate: now), now)
	}

	// MARK: - Calculating exposure valid bool

	func testExposureDetectionIsValid_PastLastDetection() {
		// Test the case when last detection was performed less than validityDuration ago
		let lastDetection = Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()) ?? .distantPast
		XCTAssertTrue(config.exposureDetectionIsValid(lastExposureDetectionDate: lastDetection))
	}

	func testExposureDetectionIsValid_LastDetectionNow() {
		// Test the case when last detection was performed at this instant
		// It should be valid
		let now = Date()
		XCTAssertTrue(config.exposureDetectionIsValid(lastExposureDetectionDate: now, currentDate: now))
	}

	func testExposureDetectionIsValid_LastDetectionFuture() {
		// Test the case when last detection was performed in the future.
		// This is invalid.
		XCTAssertFalse(config.exposureDetectionIsValid(lastExposureDetectionDate: Date().addingTimeInterval(10000)))
	}

	func testExposureDetectionIsValid_LastDetectionDistantPast() {
		// Test the case when last detection was performed in the past
		XCTAssertFalse(config.exposureDetectionIsValid(lastExposureDetectionDate: .distantPast))
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
}
