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

@testable import ENA
import ExposureNotification
import Foundation
import XCTest

final class ExposureDetectionExecutorTests: XCTestCase {

	// MARK: - Determine Available Data Tests

	func testDetermineAvailableData_Success() throws {
		// Test the case where the exector is asked to download the days and hours,
		// and the client returns valid data. Returned DaysAndHours should be non-nil
		let testDaysAndHours = DaysAndHours(days: ["Hello"], hours: [23])
		let sut = ExposureDetectionExecutor.makeWith(client: ClientMock(availableDaysAndHours: testDaysAndHours))
		let successExpectation = expectation(description: "Expect that the completion handler is called!")

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			determineAvailableData: { daysAndHours in
				defer { successExpectation.fulfill() }

				XCTAssertEqual(daysAndHours?.days, testDaysAndHours.days)
				XCTAssertEqual(daysAndHours?.hours, [23])
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	func testDetermineAvailableData_Failure() throws {
		// Test the case where the exector is asked to download the days and hours,
		// but the client retuns an error. Returned DaysAndHours should be nil
		let sut = ExposureDetectionExecutor.makeWith(client: ClientMock(urlRequestFailure: .serverError(500)))
		let successExpectation = expectation(description: "Expect that the completion handler is called!")

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			determineAvailableData: { daysAndHours in
				defer { successExpectation.fulfill() }

				XCTAssertNil(daysAndHours)
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	// MARK: - Download Delta Tests

	func testDownloadDelta_GetDeltaSuccess() throws {
		// Test the case where the exector is asked to download the latest DaysAndHours delta,
		// and the server has new data. We expect that:
		// 1 - the request is successful and we get some DaysAndHours back.
		// 2 - only the delta is returned (days/hours the store was missing when compared to remote)
		let cal = Calendar(identifier: .gregorian)
		let startOfToday = cal.startOfDay(for: Date())
		let todayString = startOfToday.formatted
		let yesterdayString = try XCTUnwrap(cal.date(byAdding: DateComponents(day: -1), to: startOfToday)?.formatted)

		let remoteDaysAndHours: DaysAndHours = DaysAndHours(days: [yesterdayString, todayString], hours: [])
		let localDaysAndHours: DaysAndHours = DaysAndHours(days: [yesterdayString], hours: [])

		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory
		downloadedPackageStore.set(day: localDaysAndHours.days[0], package: try .makePackage())

		let sut = ExposureDetectionExecutor.makeWith(packageStore: downloadedPackageStore)

		let missingDaysAndHours = sut.exposureDetection(
			ExposureDetection(delegate: sut),
			downloadDeltaFor: remoteDaysAndHours)

		XCTAssertEqual(missingDaysAndHours.days, [todayString])
	}

	func testDownloadDelta_TestStoreIsPruned() throws {
		// Test the case where the exector is asked to download the latest DaysAndHours delta,
		// and the server has new data. We expect that the downloaded package store is pruned of old entries
		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory
		downloadedPackageStore.set(day: Date.distantPast.formatted, package: try SAPDownloadedPackage.makePackage())

		let sut = ExposureDetectionExecutor.makeWith(packageStore: downloadedPackageStore)

		_ = sut.exposureDetection(
			ExposureDetection(delegate: sut),
			downloadDeltaFor: DaysAndHours(days: ["Hello"], hours: [])
		)
		XCTAssert(downloadedPackageStore.allDays().isEmpty, "The store should be empty after being pruned!")
	}

	// MARK: - Store Delta Tests

	func testStoreDelta_Success() throws {
		// Test the case where the exector is asked to store the latest DaysAndHours delta,
		// and the server has new data. We expect that the package store contains this new data.
		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory
		let testDaysAndHours = DaysAndHours(days: ["2020-01-01"], hours: [])
		let testPackage = try SAPDownloadedPackage.makePackage()
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")

		let sut = ExposureDetectionExecutor.makeWith(
			client: ClientMock(
				availableDaysAndHours: testDaysAndHours,
				downloadedPackage: testPackage),
			packageStore: downloadedPackageStore
		)

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			downloadAndStore: testDaysAndHours) { error in
				defer { completionExpectation.fulfill() }
				XCTAssertNil(error)

				guard let storedPackage = downloadedPackageStore.package(for: "2020-01-01") else {
					// We can't XCUnwrap here as completion handler closure cannot throw
					XCTFail("Package store did not contain downloaded delta package!")
					return
				}
				XCTAssertEqual(storedPackage.bin, testPackage.bin)
				XCTAssertEqual(storedPackage.signature, testPackage.signature)
		}
		waitForExpectations(timeout: 2.0)
	}

	// MARK: - Download Configuration Tests

	func testDownloadConfiguration_Success() throws {
		// Test the case where the exector is asked to download the exposure configuration
		// Our mock client will return a mock configuration - We expect that this is returned
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url)
		)
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let client = HTTPClient.makeWith(mock: stack)
		let sut = ExposureDetectionExecutor.makeWith(client: client)

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			downloadConfiguration: { configuration in
				defer { completionExpectation.fulfill() }

				if configuration == nil {
					XCTFail("A good client response did not produce a ENExposureConfiguration!")
				}
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	func testDownloadConfiguration_ClientError() throws {
		// Test the case where the exector is asked to download the exposure configuration
		// Our mock client will return an error response - We expect that nil is returned
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let client = HTTPClient.makeWith(mock: stack)
		let sut = ExposureDetectionExecutor.makeWith(client: client)

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			downloadConfiguration: { configuration in
				defer { completionExpectation.fulfill() }

				if configuration != nil {
					XCTFail("A bad client response should not produce a ENExposureConfiguration!")
				}
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	// MARK: - Write Downloaded Package Tests

	func testWriteDownloadedPackage_NoHourlyFetching() throws {
		// Test the case where the exector is asked to write the downloaded packages
		// to disk and return the URLs (for later exposure detection use)
		// We expect that the .bin and .sig files are written in the App's temp directory
		// Hourly fetching is disabled

		let todayString = Calendar.gregorianUTC.startOfDay(for: Date()).formatted
		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory
		try downloadedPackageStore.set(day: todayString, package: .makePackage())
		// Below package is stored but should not be written to disk as hourly fetching is disabled
		try downloadedPackageStore.set(hour: 3, day: todayString, package: .makePackage())
		let store = MockTestStore()
		store.hourlyFetchingEnabled = false

		let sut = ExposureDetectionExecutor.makeWith(
			packageStore: downloadedPackageStore,
			store: store
		)

		let result = sut.exposureDetectionWriteDownloadedPackages(
			ExposureDetection(delegate: sut)
		)
		let writtenPackages = try XCTUnwrap(result, "Written packages was unexpectedly nil!")

		XCTAssertFalse(
			writtenPackages.urls.isEmpty,
			"The package was not saved!"
		)
		XCTAssertTrue(
			writtenPackages.urls.count == 2,
			"Hourly fetching disabled - there should only be one sig/bin combination written!"
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

	func testWriteDownloadedPackage_HourlyFetchingEnabled() throws {
		// Test the case where the exector is asked to write the downloaded packages
		// to disk and return the URLs (for later exposure detection use)
		// We expect that the .bin and .sig files are written in the App's temp directory
		// Hourly fetching is enabled
		let todayString = Calendar.gregorianUTC.startOfDay(for: Date()).formatted
		let downloadedPackageStore = DownloadedPackagesSQLLiteStore.openInMemory
		// Below package is stored but should not be written to disk as hourly fetching is enabled
		try downloadedPackageStore.set(day: todayString, package: .makePackage())
		try downloadedPackageStore.set(hour: 3, day: todayString, package: .makePackage())
		try downloadedPackageStore.set(hour: 4, day: todayString, package: .makePackage())
		let sut = ExposureDetectionExecutor.makeWith(packageStore: downloadedPackageStore)

		let result = sut.exposureDetectionWriteDownloadedPackages(
			ExposureDetection(delegate: sut)
		)
		let writtenPackages = try XCTUnwrap(result, "Written packages was unexpectedly nil!")

		XCTAssertFalse(
			writtenPackages.urls.isEmpty,
			"The package was not saved!"
		)
		XCTAssertTrue(
			writtenPackages.urls.count == 4,
			"Hourly fetching enabled - there should be two sig/bin combination written!"
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

	// MARK: - Detect Summary With Configuration Tests

	func testDetectSummaryWithConfiguration_Success() throws {
		// Test the case where the exector is asked to run an exposure detection
		// We provide a `MockExposureDetector` + a mock detection summary, and expect this to be returned
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let mockSummary = MutableENExposureDetectionSummary(daysSinceLastExposure: 2, matchedKeyCount: 2, maximumRiskScore: 255)
		let sut = ExposureDetectionExecutor.makeWith(exposureDetector: MockExposureDetector((mockSummary, nil)))

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
			detectSummaryWithConfiguration: ENExposureConfiguration(),
			writtenPackages: WrittenPackages(urls: []),
			completion: { result in
				defer { completionExpectation.fulfill() }

				guard case .success(let summary) = result else {
					XCTFail("Completion handler did return a detection summary!")
					return
				}

				XCTAssertEqual(summary.daysSinceLastExposure, mockSummary.daysSinceLastExposure)
				XCTAssertEqual(summary.matchedKeyCount, mockSummary.matchedKeyCount)
				XCTAssertEqual(summary.maximumRiskScore, mockSummary.maximumRiskScore)
			}
		)
		waitForExpectations(timeout: 2.0)
	}

	func testDetectSummaryWithConfiguration_Error() throws {
		// Test the case where the exector is asked to run an exposure detection
		// We provide an `MockExposureDetector` with an error, and expect this to be returned
		let completionExpectation = expectation(description: "Expect that the completion handler is called.")
		let expectedError = ENError(.notAuthorized)
		let sut = ExposureDetectionExecutor.makeWith(exposureDetector: MockExposureDetector((nil, expectedError)))

		sut.exposureDetection(
			ExposureDetection(delegate: sut),
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
