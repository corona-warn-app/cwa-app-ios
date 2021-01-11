//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import Foundation
import XCTest

final class ExposureDetectionExecutorTests: XCTestCase {

	private var dummyAppConfigMetadata: AppConfigMetadata {
		AppConfigMetadata(
			lastAppConfigETag: "ETag",
			lastAppConfigFetch: Date(),
			appConfig: SAP_Internal_V2_ApplicationConfigurationIOS()
		)
	}

	// MARK: - Write Downloaded Package Tests

	func testWriteDownloadedPackage() throws {
		// Test the case where the executor is asked to write the downloaded packages
		// to disk and return the URLs (for later exposure detection use)
		// We expect that the .bin and .sig files are written in the App's temp directory
		// Hourly fetching is enabled
		let todayString = Calendar.gregorianUTC.startOfDay(for: Date()).formatted
		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory

		// Below package is stored but should not be written to disk as hourly fetching is enabled
		try downloadedPackageStore.set(country: "IT", day: todayString, etag: nil, package: .makePackage())
		try downloadedPackageStore.set(country: "IT", hour: 3, day: todayString, etag: nil, package: .makePackage())
		try downloadedPackageStore.set(country: "IT", hour: 4, day: todayString, etag: nil, package: .makePackage())

		let sut = ExposureDetectionExecutor.makeWith(packageStore: downloadedPackageStore)

		let result = sut.exposureDetectionWriteDownloadedPackages(
			country: "IT"
		)
		let writtenPackages = try XCTUnwrap(result, "Written packages was unexpectedly nil!")

		XCTAssertFalse(
			writtenPackages.urls.isEmpty,
			"The package was not saved!"
		)
		XCTAssertTrue(
			writtenPackages.urls.count == 6,
			"There should be three sig/bin combination written!"
		)

		let fileManager = FileManager.default
		for url in writtenPackages.urls {
			XCTAssertTrue(
				url.absoluteString.starts(with: fileManager.temporaryDirectory.absoluteString),
				"The packages were not written in the temporary directory!"
			)
		}
		// Cleanup
		let firstURL = try XCTUnwrap(writtenPackages.urls.first, "Written packages URLs is empty!")
		let parentDir = firstURL.deletingLastPathComponent()
		try fileManager.removeItem(at: parentDir)
	}

	// MARK: - Detect Exposure Windows With Configuration Tests

	func testDetectExposureWindowsWithConfiguration_Success() throws {
		// Test the case where the exector is asked to run an exposure detection
		// We provide a `MockExposureDetector` + a mock exposure window, and expect this to be returned
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let mockExposureWindow = MutableENExposureWindow(calibrationConfidence: .medium, date: Date(), diagnosisReportType: .confirmedTest, infectiousness: .standard, scanInstances: [])
		let sut = ExposureDetectionExecutor.makeWith(
			exposureDetector: MockExposureDetector(
				detectionHandler: (MutableENExposureDetectionSummary(), nil),
				exposureWindowsHandler: ([mockExposureWindow], nil)
			)
		)
		let exposureDetection = ExposureDetection(
			delegate: sut,
			appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS(),
			deviceTimeCheck: DeviceTimeCheck(store: MockTestStore())
		)

		_ = sut.detectExposureWindows(
			exposureDetection,
			detectSummaryWithConfiguration: ENExposureConfiguration(),
			writtenPackages: WrittenPackages(urls: []),
			completion: { result in
				defer { completionExpectation.fulfill() }

				guard case .success(let exposureWindows) = result, let exposureWindow = exposureWindows.first else {
					XCTFail("Completion handler did not return an exposure window!")
					return
				}

				XCTAssertEqual(exposureWindow.calibrationConfidence, mockExposureWindow.calibrationConfidence)
				XCTAssertEqual(exposureWindow.date, mockExposureWindow.date)
				XCTAssertEqual(exposureWindow.diagnosisReportType, mockExposureWindow.diagnosisReportType)
				XCTAssertEqual(exposureWindow.infectiousness, mockExposureWindow.infectiousness)
				XCTAssertEqual(exposureWindow.scanInstances, mockExposureWindow.scanInstances)
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	func testDetectExposureWindowsWithConfiguration_Error() throws {
		// Test the case where the exector is asked to run an exposure detection
		// We provide an `MockExposureDetector` with an error, and expect this to be returned
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let expectedError = ENError(.notAuthorized)
		let sut = ExposureDetectionExecutor.makeWith(exposureDetector: MockExposureDetector(exposureWindowsHandler: (nil, expectedError)))
		let exposureDetection = ExposureDetection(
			delegate: sut,
			appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS(),
			deviceTimeCheck: DeviceTimeCheck(store: MockTestStore())
		)

		_ = sut.detectExposureWindows(
			exposureDetection,
			detectSummaryWithConfiguration: ENExposureConfiguration(),
			writtenPackages: WrittenPackages(urls: []),
			completion: { result in
				defer { completionExpectation.fulfill() }

				guard case .failure(let error) = result else {
					XCTFail("Completion handler indicated succeess though it should have failed!")
					return
				}

				guard let enError = error as? ENError else {
					XCTFail("Completion handler returned incorrect error type. Expected ENErrror, got \(type(of: error))!")
					return
				}

				XCTAssertEqual(enError.code, expectedError.code)
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	func testDetectExposureWindowsWithConfiguration_Error2BadParameter_ClearsCache() throws {
		// Test the case where the exector is asked to run an exposure detection
		// We provide an `MockExposureDetector` with an error, and expect this to be returned
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let expectedError = ENError(.badParameter)

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)
		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)
		let packageStore = DownloadedPackagesSQLLiteStore.inMemory()
		packageStore.open()
		try packageStore.set(country: "DE", day: "SomeDay", etag: nil, package: package)

		let store = MockTestStore()
		store.appConfigMetadata = dummyAppConfigMetadata

		let sut = ExposureDetectionExecutor.makeWith(
			packageStore: packageStore,
			store: store,
			exposureDetector: MockExposureDetector(
				detectionHandler: (nil, expectedError)
			)
		)
		let exposureDetection = ExposureDetection(
			delegate: sut,
			appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS(),
			deviceTimeCheck: DeviceTimeCheck(store: store)
		)

		XCTAssertNotEqual(packageStore.allDays(country: "DE").count, 0)
		XCTAssertNotNil(store.appConfigMetadata)

		_ = sut.detectExposureWindows(
			exposureDetection,
			detectSummaryWithConfiguration: ENExposureConfiguration(),
			writtenPackages: WrittenPackages(urls: []),
			completion: { _ in
				XCTAssertEqual(packageStore.allDays(country: "DE").count, 0)
				XCTAssertNil(store.appConfigMetadata)

				completionExpectation.fulfill()
			}
		)
		waitForExpectations(timeout: 2.0)
	}
}

// MARK: - Private Helper Extensions

private extension ExposureDetectionExecutor {
	/// Create a `ExposureDetectionExecutor` with the specified parameters. Mock defaults are applied unless specified.
	static func makeWith(
		client: Client = ClientMock(),
		packageStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore.inMemory(),
		store: Store = MockTestStore(),
		exposureDetector: MockExposureDetector = MockExposureDetector()
	) -> ExposureDetectionExecutor {
		ExposureDetectionExecutor(
			client: client,
			downloadedPackagesStore: packageStore,
			store: store,
			exposureDetector: exposureDetector
		)
	}
}

private extension DownloadedPackagesSQLLiteStore {
	static var openInMemory: DownloadedPackagesSQLLiteStore {
		let store = DownloadedPackagesSQLLiteStore.inMemory()
		store.open()
		return store
	}
}

private extension Date {
	var formatted: String {
		DateFormatter.packagesDateFormatter.string(from: self)
	}
}

private extension Calendar {
	static var gregorianUTC: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		// swiftlint:disable:next force_unwrapping
		calendar.timeZone = TimeZone(abbreviation: "UTC")!
		return calendar
	}
}

private extension DateFormatter {
	static var packagesDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}()
}
