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

final class ExposureDetectionTransactionTests: XCTestCase {

	func testGivenThatEveryNeedIsSatisfiedTheDetectionFinishes() throws {
		let delegate = ExposureDetectionDelegateMock()

		let summaryResultBeCalled = expectation(description: "summaryResult called")
		delegate.summaryResult = { _, _ in
			summaryResultBeCalled.fulfill()
			return .success(MutableENExposureDetectionSummary(daysSinceLastExposure: 5))
		}

		let startCompletionCalled = expectation(description: "start completion called")
		let detection = ExposureDetection(
			delegate: delegate,
			appConfiguration: SAP_Internal_ApplicationConfiguration()
		)
		detection.start { _ in
			startCompletionCalled.fulfill()
		}

		wait(
			for: [
				summaryResultBeCalled,
				startCompletionCalled
			],
			timeout: 1.0,
			enforceOrder: true
		)
	}
}

final class AppConfigurationProviderFake: AppConfigurationProviding {
	func appConfiguration(forceFetch: Bool, completion: @escaping Completion) {
		completion(.success(SAP_Internal_ApplicationConfiguration()))
	}

	func appConfiguration(completion: @escaping Completion) {
		completion(.success(SAP_Internal_ApplicationConfiguration()))
	}
}

final class MutableENExposureDetectionSummary: ENExposureDetectionSummary {
	init(daysSinceLastExposure: Int = 0, matchedKeyCount: UInt64 = 0, maximumRiskScore: ENRiskScore = .zero) {
		self._daysSinceLastExposure = daysSinceLastExposure
		self._matchedKeyCount = matchedKeyCount
		self._maximumRiskScore = maximumRiskScore
	}

	private var _daysSinceLastExposure: Int
	override var daysSinceLastExposure: Int {
		_daysSinceLastExposure
	}

	private var _matchedKeyCount: UInt64
	override var matchedKeyCount: UInt64 {
		_matchedKeyCount
	}

	private var _maximumRiskScore: ENRiskScore
	override var maximumRiskScore: ENRiskScore { _maximumRiskScore }
}

private final class ExposureDetectionDelegateMock {
	var detectSummaryWithConfigurationWasCalled = false

	// MARK: Types
	struct SummaryError: Error { }

	// MARK: Properties

	var writtenPackages: () -> WrittenPackages? = {
		nil
	}

	var summaryResult: (
		_ configuration: ENExposureConfiguration,
		_ writtenPackages: WrittenPackages
		) -> Result<ENExposureDetectionSummary, Error> = { _, _ in
		.failure(SummaryError())
	}
}

extension ExposureDetectionDelegateMock: ExposureDetectionDelegate {

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages? {
		writtenPackages()
	}

	func exposureDetection(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping (Result<ENExposureDetectionSummary, Error>) -> Void) -> Progress {
		completion(summaryResult(configuration, writtenPackages))

		detectSummaryWithConfigurationWasCalled = true
		return Progress()
	}
}

private extension ENExposureConfiguration {
	class func mock() -> ENExposureConfiguration {
		let config = ENExposureConfiguration()
		config.metadata = ["attenuationDurationThresholds": [50, 70]]
		config.attenuationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
		config.daysSinceLastExposureLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
		config.durationLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
		config.transmissionRiskLevelValues = [1, 2, 3, 4, 5, 6, 7, 8]
		return config
	}
}
