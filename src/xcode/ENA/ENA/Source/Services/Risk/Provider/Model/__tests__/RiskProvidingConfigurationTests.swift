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
	private let detectionInterval = DateComponents(second: 2)
	private lazy var config = RiskProvidingConfiguration(
		exposureDetectionValidityDuration: validityDuration,
		exposureDetectionInterval: detectionInterval,
		detectionMode: .default
	)

	// MARK: - Calculating exposure valid until Date

	func testExposureDetectionValidUntil_NilLastDetectionDate() {
		// Test the case where the last exposure detection date is nil.
		// We should get .distantPast + validityDuration back
		let now = Date.distantPast
		let until = Calendar.current.date(byAdding: validityDuration, to: now)
		XCTAssertEqual(config.exposureDetectionValidUntil(lastExposureDetectionDate: nil), until)
	}

	func testExposureDetectionValidUntil_NowLastDetectionDate() {
		// Test the case where the last exposure detection right now.
		// We should get .distantPast + validityDuration back
		let now = Date()
		let until = Calendar.current.date(byAdding: validityDuration, to: now)
		XCTAssertEqual(config.exposureDetectionValidUntil(lastExposureDetectionDate: now), until)
	}

	// MARK: - Calculating next exposure detection date

	func testGetNextExposureDetectionDate_NoExposurePerformedInPast() {
		// Test the case where we want to get the next exposure date,
		// when we have not done the exposure detection before
		let dateLastExposure: Date? = nil
		// The expected date for us to get back would be the the distantPast + detectionInterval
		let nextExpectedDate = Calendar.current.date(byAdding: detectionInterval, to: .distantPast)
		let now = Date()
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: dateLastExposure, currentDate: now), nextExpectedDate)
	}

	func testGetNextExposureDetectionDate_FutureLastDetectionDate() {
		// Test the case where the last exposure detection date is in the future.
		// We should
		let now = Date()
		let future = Calendar.current.date(byAdding: DateComponents(day: 10), to: now)
		let until = Calendar.current.date(byAdding: validityDuration, to: now)
		XCTAssertEqual(config.nextExposureDetectionDate(lastExposureDetectionDate: future), until)
	}
}
