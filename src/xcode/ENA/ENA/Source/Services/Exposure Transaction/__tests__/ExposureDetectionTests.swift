//
// 🦠 Corona-Warn-App
//

import XCTest
import Combine
import ExposureNotification
@testable import ENA

final class ExposureDetectionTransactionTests: XCTestCase {

	func testGivenThatEveryNeedIsSatisfiedTheDetectionFinishes() throws {
		let rootDir = FileManager().temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try FileManager().createDirectory(atPath: rootDir.path, withIntermediateDirectories: true, attributes: nil)
		let url0 = rootDir.appendingPathComponent("1").appendingPathExtension("sig")
		let url1 = rootDir.appendingPathComponent("1").appendingPathExtension("bin")
		try "url0".write(to: url0, atomically: true, encoding: .utf8)
		try "url1".write(to: url1, atomically: true, encoding: .utf8)

		let writtenPackages = WrittenPackages(urls: [url0, url1])

		let writtenPackagesBeCalled = expectation(description: "writtenPackages called")

		let delegate = ExposureDetectionDelegateMock()
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
			appConfiguration: SAP_Internal_ApplicationConfiguration(),
			deviceTimeCheck: DeviceTimeCheck(store: MockTestStore())
		)
		detection.start { _ in
			startCompletionCalled.fulfill()
		}

		wait(
			for: [
				writtenPackagesBeCalled,
				summaryResultBeCalled,
				startCompletionCalled
			],
			timeout: 1.0,
			enforceOrder: true
		)
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
	var deviceTimeCorrect = true
	var deviceTimeIncorrectErrorMessageShown = false

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
