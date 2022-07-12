//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class DayKeyPackageDownloadTest: CWATestCase {

	private lazy var dummyResponse: [String: PackageDownloadResponse] = {
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage)
		return ["2020-10-04": dummyResponse, "2020-10-01": dummyResponse]
	}()
	
	func test_When_NoCachedDayPackages_Then_AllServerDayPackagesAreDownloaded() {
		let store = MockTestStore()
		store.lastKeyPackageDownloadDate = .distantPast

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-01", "2020-10-02", "2020-10-03"])
		])

		let countryId = "IT"
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-01", "2020-10-02", "2020-10-03"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				XCTAssertGreaterThan(store.lastKeyPackageDownloadDate, Date.distantPast)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_CachedDayPackagesAvailable_Then_OnlyServerDeltaPackagesAreDownloaded() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		try packagesStore.addFetchedDays(dummyResponse, country: countryId)

		let client = ClientMock()
		client.downloadedPackage = try XCTUnwrap(dummyResponse.values.first)

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02", "2020-10-01", "2020-10-03", "2020-10-04"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_ExpiredCachedDayPackagesAvailable_Then_ExpiredPackagesAreDeleted() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		try packagesStore.addFetchedDays(dummyResponse, country: countryId)

		let client = ClientMock()
		client.downloadedPackage = try XCTUnwrap(dummyResponse.values.first)

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02", "2020-10-03", "2020-10-04"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-02", "2020-10-03", "2020-10-04"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_ExpectNewDayPackagesIsFalse_Then_NoPackageDownloadIsTriggeredAndSuccessIsCalled() throws {
		let store = MockTestStore()
		store.wasRecentDayKeyDownloadSuccessful = true
		store.lastKeyPackageDownloadDate = .distantPast

		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			fatalError("Could not create yesterdays date.")
		}
		let yesterdayKeyString = DateFormatter.packagesDayDateFormatter.string(from: yesterdayDate)
		let countryId = "IT"

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage)

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		try packagesStore.addFetchedDays(["2020-10-04": dummyResponse, yesterdayKeyString: dummyResponse], country: countryId)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: RestServiceProviderStub(),
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				successExpectation.fulfill()
				XCTAssertEqual(store.lastKeyPackageDownloadDate, Date.distantPast)
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_DayPackagesDownloadIsRunning_Then_downloadIsRunningErrorReturned() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		try packagesStore.addFetchedDays(dummyResponse, country: countryId)

		let client = ClientMock()
		client.downloadedPackage = try XCTUnwrap(dummyResponse.values.first)

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02", "2020-10-03", "2020-10-04"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store,
			countryIds: ["IT"]
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { _ in }
		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .downloadIsRunning)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_DayPackagesDownloadFailes_Then_uncompletedPackagesErrorReturned() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()

		let client = ClientMock()
		client.fetchPackageRequestFailure = .noResponse

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02"]),
			.failure(ServiceError<Error>.invalidResponseType)
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .uncompletedPackages)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_AvailableServerDayDataFetchFailes_Then_uncompletedPackagesErrorReturned() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()

		let client = ClientMock()
		client.availablePackageRequestFailure = .noResponse

		// fake invalid response error on day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<Error>.invalidResponseType)
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .uncompletedPackages)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_PersistDayPackagesToDatabaseFails_Then_unableToWriteDiagnosisKeysErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: DownloadedPackagesSQLLiteStore.StoreError.sqliteError(.unknown(42)))

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .unableToWriteDiagnosisKeys)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_PersistDayPackagesToDatabaseFailsBecauseOfDiskSpace_Then_noDiskSpaceErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: DownloadedPackagesSQLLiteStore.StoreError.sqliteError(.sqlite_full))

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-02"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .noDiskSpace)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: .medium)
	}

	func test_When_NoNewPackagesFoundOnServer_Then_StatusChangesFrom_Idle_To_CheckingForNewPackages_To_Idle() throws {
		let store = MockTestStore()
		store.wasRecentDayKeyDownloadSuccessful = true

		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			fatalError("Could not create yesterdays date.")
		}
		let yesterdayKeyString = DateFormatter.packagesDayDateFormatter.string(from: yesterdayDate)
		let countryId = "IT"

		let packagesStore: DownloadedPackagesSQLLiteStoreV3 = .inMemory()
		packagesStore.open()

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage)
		try packagesStore.addFetchedDays([yesterdayKeyString: dummyResponse], country: countryId)

		let client = ClientMock()
		client.downloadedPackage = dummyResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: RestServiceProviderStub(),
			store: store,
			countryIds: ["IT"]
		)

		let statusDidChangeExpectation = expectation(description: "Status statusDidChange called twice. 1. dheckingForNewPackages, 2. idle")
		statusDidChangeExpectation.expectedFulfillmentCount = 2
		var numberOfStatusChanges = 0

		keyPackageDownload.statusDidChange = { status in
			if numberOfStatusChanges == 0 {
				XCTAssertEqual(status, .checkingForNewPackages)
			} else if numberOfStatusChanges == 1 {
				XCTAssertEqual(status, .idle)
			}

			numberOfStatusChanges += 1
			statusDidChangeExpectation.fulfill()
		}

		keyPackageDownload.startDayPackagesDownload { _ in }

		waitForExpectations(timeout: .medium)
	}

	func test_When_NewPackagesFoundOnServer_Then_StatusChangesFrom_Idle_To_Downloading_To_CheckingForNewPackages_To_Idle() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStoreV3 = .inMemory()
		packagesStore.open()

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage)

		let client = ClientMock()
		client.downloadedPackage = dummyResponse

		// fake successful day package download
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(["2020-10-01", "2020-10-02", "2020-10-03"])
		])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			restService: restServiceProvider,
			store: store,
			countryIds: ["IT"]
		)

		let statusDidChangeExpectation = expectation(description: "Status statusDidChange called three times. 1. dheckingForNewPackages, 2. downloading, 3. idle")
		statusDidChangeExpectation.expectedFulfillmentCount = 3
		var numberOfStatusChanges = 0

		keyPackageDownload.statusDidChange = { status in
			if numberOfStatusChanges == 0 {
				XCTAssertEqual(status, .checkingForNewPackages)
			} else if numberOfStatusChanges == 1 {
				XCTAssertEqual(status, .downloading)
			} else if numberOfStatusChanges == 2 {
				XCTAssertEqual(status, .idle)
			}

			numberOfStatusChanges += 1
			statusDidChangeExpectation.fulfill()
		}

		keyPackageDownload.startDayPackagesDownload { _ in }

		waitForExpectations(timeout: .medium)
	}
}
