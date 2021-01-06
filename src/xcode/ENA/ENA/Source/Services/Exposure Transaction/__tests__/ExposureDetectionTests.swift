//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
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

		let exposureWindowResultBeCalled = expectation(description: "exposureWindowResult called")
		delegate.exposureWindowResult = { _, _ in
			exposureWindowResultBeCalled.fulfill()
			return .success([MutableENExposureWindow()])
		}

		let startCompletionCalled = expectation(description: "start completion called")
		let detection = ExposureDetection(
			delegate: delegate,
			appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS(),
			deviceTimeCheck: DeviceTimeCheck(store: MockTestStore())
		)
		detection.start { _ in
			startCompletionCalled.fulfill()
		}

		wait(
			for: [
				writtenPackagesBeCalled,
				exposureWindowResultBeCalled,
				startCompletionCalled
			],
			timeout: .medium,
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

final class MutableENExposureWindow: ENExposureWindow {

	init(
		calibrationConfidence: ENCalibrationConfidence = .lowest,
		date: Date = Date(),
		diagnosisReportType: ENDiagnosisReportType = .unknown,
		infectiousness: ENInfectiousness = .none,
		scanInstances: [ENScanInstance] = []
	) {
		self._calibrationConfidence = calibrationConfidence
		self._date = date
		self._diagnosisReportType = diagnosisReportType
		self._infectiousness = infectiousness
		self._scanInstances = scanInstances
	}

	private var _calibrationConfidence: ENCalibrationConfidence
	override var calibrationConfidence: ENCalibrationConfidence {
		_calibrationConfidence
	}

	private var _date: Date
	override var date: Date {
		_date
	}

	private var _diagnosisReportType: ENDiagnosisReportType
	override var diagnosisReportType: ENDiagnosisReportType {
		_diagnosisReportType
	}

	private var _infectiousness: ENInfectiousness
	override var infectiousness: ENInfectiousness {
		_infectiousness
	}

	private var _scanInstances: [ENScanInstance]
	override var scanInstances: [ENScanInstance] {
		_scanInstances
	}
}

private final class ExposureDetectionDelegateMock {
	var detectExposureWindowsWithConfigurationWasCalled = false
	var deviceTimeCorrect = true
	var deviceTimeIncorrectErrorMessageShown = false

	// MARK: Types
	struct ExposureWindowError: Error { }

	// MARK: Properties

	var writtenPackages: () -> WrittenPackages? = {
		nil
	}

	var exposureWindowResult: (
		_ configuration: ENExposureConfiguration,
		_ writtenPackages: WrittenPackages
		) -> Result<[ENExposureWindow], Error> = { _, _ in
		.failure(ExposureWindowError())
	}
}

extension ExposureDetectionDelegateMock: ExposureDetectionDelegate {

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages? {
		writtenPackages()
	}

	func detectExposureWindows(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping (Result<[ENExposureWindow], Error>) -> Void
	) -> Progress {
		completion(exposureWindowResult(configuration, writtenPackages))

		detectExposureWindowsWithConfigurationWasCalled = true
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
