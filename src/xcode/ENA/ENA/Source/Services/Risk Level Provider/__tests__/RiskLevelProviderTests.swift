//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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
import ExposureNotification
@testable import ENA

private final class Summary: ENExposureDetectionSummary {}

private final class RiskLevelProviderStoreMock: RiskLevelProviderStore {
	var previousSummary: ENExposureDetectionSummaryContainer?
	var dateLastExposureDetection: Date?
}

private final class ExposureSummaryProviderMock: ExposureSummaryProvider {
	var onDetectExposure: ((ExposureSummaryProvider.Completion) -> Void)?

	func detectExposure(completion: (ENExposureDetectionSummary?) -> Void) {
		onDetectExposure?(completion)
	}
}

final class RiskLevelProviderTests: XCTestCase {
	func testExposureDetectionIsExecutedIfLastDetectionIsToOldAndModeIsAutomatic() throws {
		var duration = DateComponents()
		duration.day = 1

		let calendar = Calendar.current

		let lastExposureDetectionDate = calendar.date(
			byAdding: .day,
			value: -3,
			to: Date(),
			wrappingComponents: false
		)

		let store = RiskLevelProviderStoreMock()
		store.dateLastExposureDetection = lastExposureDetectionDate

		let config = RiskLevelProvidingConfiguration(
			updateMode: .automatic,
			exposureDetectionValidityDuration: duration
		)

		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let expectThatSummaryIsRequested = expectation(description: "expectThatSummaryIsRequested")
		exposureSummaryProvider.onDetectExposure = { completion in
			store.dateLastExposureDetection = Date()
			expectThatSummaryIsRequested.fulfill()
			completion(ENExposureDetectionSummary())
		}

		let sut = RiskLevelProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider
		)

		let consumer = RiskLevelConsumer()
		let nextExposureDetectionDateDidChangeExpectation = expectation(
			description: "expect willCalculateRiskLevelIn to be called"
		)

		consumer.nextExposureDetectionDateDidChange = { nextDetectionDate in
			let expectedDate = Date()

			XCTAssertTrue(calendar.isDate(expectedDate, equalTo: nextDetectionDate, toGranularity: .minute))
			nextExposureDetectionDateDidChangeExpectation.fulfill()
		}
		sut.observeRiskLevel(consumer)
		sut.requestRiskLevel()
		wait(for: [nextExposureDetectionDateDidChangeExpectation, expectThatSummaryIsRequested], timeout: 1.0)
    }

    func testExample() throws {
		var duration = DateComponents()
		duration.day = 1

		let calendar = Calendar.current

		let lastExposureDetectionDate = calendar.date(
			byAdding: .hour,
			value: -12,
			to: Date(),
			wrappingComponents: false
		)

		let store = RiskLevelProviderStoreMock()
		store.dateLastExposureDetection = lastExposureDetectionDate

		let config = RiskLevelProvidingConfiguration(
			updateMode: .automatic,
			exposureDetectionValidityDuration: duration
		)

		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let expectThatNoSummaryIsRequested = expectation(description: "expectThatNoSummaryIsRequested")
		expectThatNoSummaryIsRequested.isInverted = true
		exposureSummaryProvider.onDetectExposure = { completion in
			expectThatNoSummaryIsRequested.fulfill()
		}

		let sut = RiskLevelProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider
		)

		let consumer = RiskLevelConsumer()
		let nextExposureDetectionDateDidChangeExpectation = expectation(
			description: "expect willCalculateRiskLevelIn to be called"
		)

		consumer.nextExposureDetectionDateDidChange = { nextDetectionDate in
			// swiftlint:disable:next force_unwrapping
			let expectedDate = calendar.date(byAdding: .hour, value: 12, to: Date(), wrappingComponents: false)!
			XCTAssertTrue(calendar.isDate(expectedDate, equalTo: nextDetectionDate, toGranularity: .hour))
			nextExposureDetectionDateDidChangeExpectation.fulfill()
		}
		sut.observeRiskLevel(consumer)
		sut.requestRiskLevel()
		wait(for: [nextExposureDetectionDateDidChangeExpectation, expectThatNoSummaryIsRequested], timeout: 1.0)
    }
}
