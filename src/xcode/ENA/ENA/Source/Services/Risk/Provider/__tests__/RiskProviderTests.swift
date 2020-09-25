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

	func detectExposure(completion: (ENExposureDetectionSummary?) -> Void) -> CancellationToken {
		let token = CancellationToken(onCancel: {})
		onDetectExposure?(completion)
		return token
	}
}

final class RiskProviderTests: XCTestCase {
	func testExposureDetectionIsExecutedIfLastDetectionIsToOldAndModeIsAutomatic() throws {
		let duration = DateComponents(day: 1)

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .day,
			value: -3,
			to: Date(),
			wrappingComponents: false
		))

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
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

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

		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, complete in
			// just deliver no app configuration (as before)
			// TODO: require a missing app config feels hacky in this context - review!
			complete(.failure(CachedAppConfiguration.CacheError.notModified))
		}

		let sut = RiskProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider,
			appConfigurationProvider: CachedAppConfiguration(client: client, store: store),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active)
		)

		let consumer = RiskConsumer()

		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: false)
		waitForExpectations(timeout: 1.0)
	}

	func testExposureDetectionIsNotExecutedIfTracingHasNotBeenEnabledLongEnough() throws {
		let duration = DateComponents(day: 1)

		let calendar = Calendar.current

		let lastExposureDetectionDate = try XCTUnwrap(calendar.date(
			byAdding: .day,
			value: -3,
			to: Date(),
			wrappingComponents: false
		))

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
		// Tracing was only active for one hour, there is not enough data to calculate risk,
		// and we might get a rate limit error (ex. user reinstalls the app - losing tracing history - and risk is requested again)
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(hours: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration,
			detectionMode: .automatic
		)
		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let expectThatSummaryIsRequested = expectation(description: "expectThatSummaryIsRequested")
		exposureSummaryProvider.onDetectExposure = { completion in
			expectThatSummaryIsRequested.fulfill()
			completion(.init())
		}
		expectThatSummaryIsRequested.isInverted = true

		let sut = RiskProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider,
			appConfigurationProvider: CachedAppConfiguration(client: CachingHTTPClientMock(), store: store),
			exposureManagerState: .init(authorized: true, enabled: true, status: .active)
		)

		let consumer = RiskConsumer()

		sut.observeRisk(consumer)
		let expectThatRiskIsReturned = expectation(description: "expectThatRiskIsReturned")
		sut.requestRisk(userInitiated: false) { risk in
			expectThatRiskIsReturned.fulfill()
			XCTAssertEqual(risk?.level, .unknownInitial, "Tracing was active for < 24 hours but risk is not .unknownInitial")
		}
		waitForExpectations(timeout: 1.0)
	}

	func testThatDetectionIsRequested() throws {
		let duration = DateComponents(day: 1)

		let store = MockTestStore()
		store.summary = nil
		store.tracingStatusHistory = [.init(on: true, date: Date().addingTimeInterval(.init(days: -1)))]

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: duration,
			exposureDetectionInterval: duration
		)

		let exposureSummaryProvider = ExposureSummaryProviderMock()

		let detectionRequested = expectation(description: "expectThatNoSummaryIsRequested")

		exposureSummaryProvider.onDetectExposure = { completion in
			completion(nil)
			detectionRequested.fulfill()
		}

		let client = CachingHTTPClientMock()

		client.onFetchAppConfiguration = { _, complete in
			complete(.success(AppConfigurationFetchingResponse(SAP_ApplicationConfiguration.with {
				$0.exposureConfig = SAP_RiskScoreParameters()
			})))
		}

		let cachedAppConfig = CachedAppConfiguration(client: client, store: store)

		let sut = RiskProvider(
			configuration: config,
			store: store,
			exposureSummaryProvider: exposureSummaryProvider,
			appConfigurationProvider: cachedAppConfig,
			exposureManagerState: .init(authorized: true, enabled: true, status: .active)
		)

		let consumer = RiskConsumer()
		let didCalculateRiskCalled = expectation(
			description: "expect didCalculateRisk to be called"
		)

		consumer.didCalculateRisk = { _ in
			didCalculateRiskCalled.fulfill()
		}

		sut.observeRisk(consumer)
		sut.requestRisk(userInitiated: true)
		wait(for: [detectionRequested, didCalculateRiskCalled], timeout: 1.0, enforceOrder: true)
	}
}
