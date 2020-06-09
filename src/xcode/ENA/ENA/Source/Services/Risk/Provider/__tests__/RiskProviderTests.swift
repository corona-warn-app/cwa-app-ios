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

private final class ExposureSummaryProviderMock: ExposureSummaryProvider {
	var onDetectExposure: ((ExposureSummaryProvider.Completion) -> Void)?

	func detectExposure(completion: (ENExposureDetectionSummary?) -> Void) {
		onDetectExposure?(completion)
	}
}

final class RiskProviderTests: XCTestCase {
	// swiftlint:disable:next function_body_length
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

		let store = MockTestStore()
		store.summary = SummaryMetadata(
			summary: CodableExposureDetectionSummary(
				daysSinceLastExposure: 0,
				matchedKeyCount: 0,
				maximumRiskScore: 0,
				attenuationDurations: [],
				maximumRiskScoreFullRange: 0
			),
			// swiftlint:disable:next force_unwrapping
			date: lastExposureDetectionDate!
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)
		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let expectThatSummaryIsRequested = expectation(description: "expectThatSummaryIsRequested")
		exposureSummaryProvider.onDetectExposure = { completion in
			store.summary = SummaryMetadata(detectionSummary: .init(), date: Date())
			expectThatSummaryIsRequested.fulfill()
			completion(.init())
		}

		let sut = RiskProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider,
			appConfigurationProvider: CachedAppConfiguration(client: ClientMock(submissionError: nil)),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active)
		)

		let consumer = RiskConsumer()
		let nextExposureDetectionDateDidChangeExpectation = expectation(
			description: "expect willCalculateRiskLevelIn to be called"
		)
		let expectedDate = Date()
//		XCTAssertTrue(calendar.isDate(expectedDate, equalTo: sut.nextExposureDetectionDate(), toGranularity: .minute))

		consumer.nextExposureDetectionDateDidChange = { nextDetectionDate in
//			let expectedDate = Date()
//
//			XCTAssertTrue(calendar.isDate(expectedDate, equalTo: nextDetectionDate, toGranularity: .minute))
			nextExposureDetectionDateDidChangeExpectation.fulfill()
		}
		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: false)
		waitForExpectations(timeout: 1.0)
//		wait(for: [nextExposureDetectionDateDidChangeExpectation, expectThatSummaryIsRequested], timeout: 10.0)
    }

	// swiftlint:disable:next function_body_length
    func testExample() throws {
		var duration = DateComponents()
		duration.day = 1

		let calendar = Calendar.current

		let lastExposureDetectionDate = calendar.date(
			byAdding: .hour,
			value: -12,
			to: Date(),
			wrappingComponents: false
			// swiftlint:disable:next force_unwrapping
		)!

		let store = MockTestStore()
		store.summary = SummaryMetadata(
			summary: CodableExposureDetectionSummary(
				daysSinceLastExposure: 0,
				matchedKeyCount: 0,
				maximumRiskScore: 0,
				attenuationDurations: [],
				maximumRiskScoreFullRange: 0
			),
			date: lastExposureDetectionDate
		)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let expectThatNoSummaryIsRequested = expectation(description: "expectThatNoSummaryIsRequested")
		expectThatNoSummaryIsRequested.isInverted = true
		exposureSummaryProvider.onDetectExposure = { completion in
			expectThatNoSummaryIsRequested.fulfill()
		}

		let sut = RiskProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider,
			appConfigurationProvider: CachedAppConfiguration(client: ClientMock(submissionError: nil)),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active)
		)

		let consumer = RiskConsumer()
		let nextExposureDetectionDateDidChangeExpectation = expectation(
			description: "expect willCalculateRiskLevelIn to be called"
		)
		let expectedDate = calendar.date(byAdding: .hour, value: 12, to: Date(), wrappingComponents: false)!

//		XCTAssertTrue(calendar.isDate(sut.nextExposureDetectionDate(), equalTo: expectedDate, toGranularity: .hour))

		consumer.nextExposureDetectionDateDidChange = { nextDetectionDate in
			// swiftlint:disable:next force_unwrapping
//			let expectedDate = calendar.date(byAdding: .hour, value: 12, to: Date(), wrappingComponents: false)!
//			print("expected: \(expectedDate)")
//			print("nextDetectionDate: \(nextDetectionDate)")

//			XCTAssertTrue(calendar.isDate(expectedDate, equalTo: nextDetectionDate, toGranularity: .hour))
			nextExposureDetectionDateDidChangeExpectation.fulfill()
		}
		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: false)
		wait(for: [nextExposureDetectionDateDidChangeExpectation, expectThatNoSummaryIsRequested], timeout: 1.0)
    }
}
