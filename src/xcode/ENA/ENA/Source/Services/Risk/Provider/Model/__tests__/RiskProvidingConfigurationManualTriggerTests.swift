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

import XCTest
@testable import ENA

final class RiskProvidingConfigurationManualTriggerTests: XCTestCase {
	private let calendar = Calendar(identifier: .iso8601)

    func testNoPreviousDetection() {
		let config = _config(
			validity: .init(day: 2),
			interval: .init(day: 1),
			mode: .manual
		)

		XCTAssertEqual(
			config.manualExposureDetectionState(lastExposureDetectionDate: nil),
			.possible
		)
    }

	func testDateInWindow() {
		let config = _config(
			validity: .init(day: 3),
			interval: .init(day: 1),
			mode: .manual
		)

		XCTAssertEqual(
			config.manualExposureDetectionState(
				lastExposureDetectionDate: calendar.date(byAdding: .init(day: -1), to: Date())
			),
			.possible
		)
	}

	// Exposure detections are conducted once per day and the last detection was performed just 12 hours ago.
	// It is expected that the detection state is waiting.
	func testTooEarly() {
		let config = _config(
			validity: .init(day: 3),
			interval: .init(day: 1),
			mode: .manual
		)

		XCTAssertEqual(
			config.manualExposureDetectionState(
				lastExposureDetectionDate: calendar.date(byAdding: .init(hour: -12), to: Date())
			),
			.waiting
		)
	}

	func testOutdated() {
		let config = _config(
			validity: .init(day: 3),
			interval: .init(day: 1),
			mode: .manual
		)

		XCTAssertEqual(
			config.manualExposureDetectionState(
				lastExposureDetectionDate: calendar.date(byAdding: .init(day: -10), to: Date())
			),
			.possible
		)
	}

	func testAutomatic() {
		let config = _config(
			validity: .init(day: 3),
			interval: .init(day: 1),
			mode: .automatic
		)

		XCTAssertNil(
			config.manualExposureDetectionState(
				lastExposureDetectionDate: calendar.date(byAdding: .init(day: -10), to: Date())
			)
		)
	}

}

private func _config(
	validity: DateComponents,
	interval: DateComponents,
	mode: DetectionMode
) -> RiskProvidingConfiguration {
	.init(
		exposureDetectionValidityDuration: validity,
		exposureDetectionInterval: interval,
		detectionMode: mode
	)
}
