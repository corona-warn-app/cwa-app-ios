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

		let availableDataToBeCalled = expectation(description: "availableData called")
 		delegate.availableData = {
			availableDataToBeCalled.fulfill()
			return .init(days: ["2020-05-01"], hours: [])
		}

		let downloadDeltaToBeCalled = expectation(description: "downloadDelta called")
		delegate.downloadDelta = { _ in
			downloadDeltaToBeCalled.fulfill()
			return .init(days: ["2020-05-01"], hours: [])
		}

		let downloadAndStoreToBeCalled = expectation(description: "downloadAndStore called")
		delegate.downloadAndStore = { _ in
			downloadAndStoreToBeCalled.fulfill()
			return nil
		}

		let rootDir = FileManager().temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try FileManager().createDirectory(atPath: rootDir.path, withIntermediateDirectories: true, attributes: nil)
		let url0 = rootDir.appendingPathComponent("1").appendingPathExtension("sig")
		let url1 = rootDir.appendingPathComponent("1").appendingPathExtension("bin")
		try "url0".write(to: url0, atomically: true, encoding: .utf8)
		try "url1".write(to: url1, atomically: true, encoding: .utf8)

		let writtenPackages = WrittenPackages(urls: [url0, url1])

		let writtenPackagesBeCalled = expectation(description: "writtenPackages called")
		delegate.writtenPackages = {
			writtenPackagesBeCalled.fulfill()
			return writtenPackages
		}


		let summaryResultBeCalled = expectation(description: "summaryResult called")
		delegate.summaryResult = { _, _ in
			summaryResultBeCalled.fulfill()
			return .success(MutableENExposureDetectionSummary(daysSinceLastExposure: 5))
		}

		let startCompletionCalled = expectation(description: "start completion called")
		let detection = ExposureDetection(
			delegate: delegate,
			appConfiguration: SAP_ApplicationConfiguration()
		)
		detection.start { _ in
			startCompletionCalled.fulfill()
		}

		wait(
			for: [
				availableDataToBeCalled,
				downloadDeltaToBeCalled,
				downloadAndStoreToBeCalled,
				writtenPackagesBeCalled,
				summaryResultBeCalled,
				startCompletionCalled
			],
			timeout: 1.0,
			enforceOrder: true
		)
	}

	func test_When_NoRemoteDataAvailable_Then_FailureNoDaysAndHoursIsCalled() {
		let delegate = ExposureDetectionDelegateMock()

		delegate.availableData = {
			return nil
		}

		let packageDownloader = CountryKeypackageDownloader(delegate: delegate)

		let detection = ExposureDetection(
			delegate: delegate,
			countryKeypackageDownloader: packageDownloader,
			appConfiguration: SAP_ApplicationConfiguration()
		)

		let expectationNoDaysAndHours = expectation(description: "completion with NoDaysAndHours error called.")

		packageDownloader.downloadKeypackages(for: "DE") { result in
			switch result {
			case .failure(let error):
				switch error {
				case .noDaysAndHours:
					expectationNoDaysAndHours.fulfill()
				default:
					XCTFail("noDaysAndHours error expteced.")
				}
			case .success:
				XCTFail("downloadKeypackages should failt due to missing data.")
			}
		}

		let expectationDetectionCompletion = expectation(description: "Detection completion was called.")
		detection.start { _ in
			expectationDetectionCompletion.fulfill()
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_PackageDownloaderFails_Then_NoRiskCaculationIsTriggered() {
		let delegate = ExposureDetectionDelegateMock()

		delegate.writtenPackages = {
			XCTFail("Package write call not expected after failing download.")
			return WrittenPackages(urls: [])
		}

		delegate.summaryResult = { _, _ in
			XCTFail("Configuration call not expected after failing download.")
			return .failure(NSError())
		}

		let packageDownloader = CountryKeypackageDownloaderFailing()

		let detection = ExposureDetection(
			delegate: delegate,
			countryKeypackageDownloader: packageDownloader,
			appConfiguration: SAP_ApplicationConfiguration()
		)

		let expectationFailureResult = expectation(description: "Detection should fail.")

		detection.start { result in
			switch result {
			case .failure:
				XCTAssertFalse(delegate.detectSummaryWithConfigurationWasCalled)
				expectationFailureResult.fulfill()
			case .success:
				XCTFail("Success is not expected.")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_SavingPackageToFileSystemFails_Then_NoRiskCaculationIsTriggered() {
		let delegate = ExposureDetectionDelegateMock()
		
		delegate.writtenPackages = {
			return nil
		}

		delegate.summaryResult = { _, _ in
			XCTFail("Configuration call not expected after failing download.")
			return .failure(NSError())
		}

		let packageDownloader = CountryKeypackageDownloaderFake()

		let detection = ExposureDetection(
			delegate: delegate,
			countryKeypackageDownloader: packageDownloader,
			appConfiguration: SAP_ApplicationConfiguration()
		)

		let expectationFailureResult = expectation(description: "Detection should fail.")

		detection.start { result in
			switch result {
			case .failure:
				XCTAssertFalse(delegate.detectSummaryWithConfigurationWasCalled)
				expectationFailureResult.fulfill()
			case .success:
				XCTFail("Success is not expected.")
			}
		}

		waitForExpectations(timeout: 1.0)
	}
}

final class AppConfigurationProviderFake: AppConfigurationProviding {
	func appConfiguration(forceFetch: Bool, completion: @escaping Completion) {
		completion(.success(SAP_ApplicationConfiguration()))
	}

	func appConfiguration(completion: @escaping Completion) {
		completion(.success(SAP_ApplicationConfiguration()))
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

private final class CountryKeypackageDownloaderFailing: CountryKeypackageDownloading {
	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion) {
		completion(Result.failure(.noSupportedCountries))
	}
}

private final class CountryKeypackageDownloaderFake: CountryKeypackageDownloading {
	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion) {
		completion(Result.success(()))
	}
}

private final class ExposureDetectionDelegateMock {
	var detectSummaryWithConfigurationWasCalled = false
	var deviceTimeCorrect = true
	var deviceTimeIncorrectErrorMessageShown = false

	// MARK: Types
	struct SummaryError: Error { }
	typealias DownloadAndStoreHandler = (_ delta: DaysAndHours) -> ExposureDetection.DidEndPrematurelyReason?

	// MARK: Properties

	var availableData: () -> DaysAndHours? = {
		nil
	}

	var downloadDelta: (_ available: DaysAndHours) -> DaysAndHours = { _ in
		DaysAndHours(days: [], hours: [])
	}

	var downloadAndStore: DownloadAndStoreHandler = { _ in nil }

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

	func exposureDetection(country: Country.ID, determineAvailableData completion: @escaping (DaysAndHours?, Country.ID) -> Void) {
		completion(availableData(), country)
	}

	func exposureDetection(country: Country.ID, downloadDeltaFor remote: DaysAndHours) -> DaysAndHours {
		downloadDelta(remote)
	}

	func exposureDetection(country: Country.ID, downloadAndStore delta: DaysAndHours, completion: @escaping (ExposureDetection.DidEndPrematurelyReason?) -> Void) {
		completion(downloadAndStore(delta))

	}

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
	
	func isDeviceTimeCorrect() -> Bool {
		return deviceTimeCorrect
	}
	
	func hasDeviceTimeErrorBeenShown() -> Bool {
		return deviceTimeIncorrectErrorMessageShown
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
