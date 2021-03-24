////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class TraceWarningPackageDownloadTests: XCTestCase {
	
	// MARK: - Success
	
	func testGIVEN_TraceWarningDownload_WHEN_HappyCase_THEN_Success() throws {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDiscovery))
		}
		
		client.onTraceWarningDownload = { [weak self] _, _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDownload))
		}
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore,
			verifier: MockVerifier()
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage HappyCase_THEN_Success.")
		
		// WHEN
		var responseCode: TraceWarningSuccess?
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			
			case let .success(success):
				responseCode = success
				successExpectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail but did with error: \(error)")
			}
			
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCode, .success)
		let someTimeAgo = Calendar.current.date(byAdding: .second, value: -20, to: Date())
		let someTimeAgoTimeRange = try XCTUnwrap(someTimeAgo)...Date()
		XCTAssertTrue(someTimeAgoTimeRange.contains(try XCTUnwrap(store.lastTraceWarningPackageDownloadDate)))
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_CheckInDatabaseIsEmpty_THEN_Success() {
		
		// GIVEN
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: MockEventStore()
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage CheckInDatabaseIsEmpty_THEN_Success.")
		
		// WHEN
		var responseCode: TraceWarningSuccess?
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			
			case let .success(success):
				responseCode = success
				successExpectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail but did with error: \(error)")
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCode, .noCheckins)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_AvailablePackagesOnCDNAreEmpty_THEN_Success() {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { _, completion in
			let emptyAvailablePackagesResponse = TraceWarningDiscovery(oldest: 12345, latest: 12344, eTag: "FakeEtag")
			completion(.success(emptyAvailablePackagesResponse))
		}
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: MockTestStore(),
			eventStore: eventStore
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage AvailablePackagesOnCDNAreEmpty_THEN_Success.")
		
		// WHEN
		var responseCode: TraceWarningSuccess?
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			
			case let .success(success):
				responseCode = success
				successExpectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail but did with error: \(error)")
			}
			
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCode, .emptyAvailablePackages)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_SinglePackageIsEmpty_THEN_Success() throws {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDiscovery))
		}
		
		client.onTraceWarningDownload = { _, _, completion in
			let emptyPackage = PackageDownloadResponse(package: nil, etag: "FakeEtag")
			completion(.success(emptyPackage))
		}
		
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: MockTestStore(),
			eventStore: eventStore,
			verifier: MockVerifier()
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage SinglePackageIsEmpty_THEN_Success.")
		
		// WHEN
		var responseCode: TraceWarningSuccess?
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			
			case let .success(success):
				responseCode = success
				successExpectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail but did with error: \(error)")
			}
			
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCode, .emptySinglePackage)
	}
	
	// MARK: - Errors
	
	func testGIVEN_TraceWarningDownload_WHEN_DownloadIsAlreadyInProgress_THEN_DownloadIsRunning() {
		
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: eventStore
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage DownloadIsAlreadyInProgress_THEN_DownloadIsRunning.")
		successExpectation.expectedFulfillmentCount = 2
		var responseCodeSuccess: TraceWarningSuccess?
		var responseCodeError: TraceWarningError?
		
		// WHEN
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				let seconds = 1.0
				DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
					responseCodeSuccess = success
					successExpectation.fulfill()
				}
			case let .failure(error):
				XCTFail("Test should not fail but did with error: \(error)")
			}
		})
		
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				XCTFail("Test should not success but did with success: \(success)")
			case let .failure(error):
				responseCodeError = error
				successExpectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCodeSuccess, .success)
		XCTAssertEqual(responseCodeError, .downloadIsRunning)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_DiscoveryIsFailing_THEN_InvalidResponseError() throws {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { _, completion in
			completion(.failure(.invalidResponseError(404)))
		}
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore
		)
		
		let expect = expectation(description: "TraceWarningPackage DiscoveryIsFailing_THEN_InvalidResponseError.")
		var responseCodeError: TraceWarningError?
		
		// WHEN
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				XCTFail("Test should not success but did with success: \(success)")
			case let .failure(error):
				responseCodeError = error
				expect.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCodeError, .invalidResponseError(404))
		let someTimeAgo = Calendar.current.date(byAdding: .second, value: -20, to: Date())
		let someTimeAgoTimeRange = try XCTUnwrap(someTimeAgo)...Date()
		XCTAssertFalse(someTimeAgoTimeRange.contains(try XCTUnwrap(store.lastTraceWarningPackageDownloadDate)))
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_DownloadIsFailing_THEN_InvalidResponseError() {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDiscovery))
		}
		
		client.onTraceWarningDownload = { _, _, completion in
			completion(.failure(.invalidResponseError(999)))
		}
		
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: MockTestStore(),
			eventStore: eventStore
		)
		
		let expect = expectation(description: "TraceWarningPackage DownloadIsFailing_THEN_InvalidResponseError.")
		var responseCodeError: TraceWarningError?
		
		// WHEN
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				XCTFail("Test should not success but did with success: \(success)")
			case let .failure(error):
				responseCodeError = error
				expect.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCodeError, .invalidResponseError(999))
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_EtagMissing_THEN_IdenticationError() {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDiscovery))
		}
		client.onTraceWarningDownload = { _, _, completion in
			let package = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			let response = PackageDownloadResponse(package: package, etag: nil)
			completion(.success(response))
		}
		
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: MockTestStore(),
			eventStore: eventStore
		)
		
		let expect = expectation(description: "TraceWarningPackage EtagMissing_THEN_IdenticationError.")
		var responseCodeError: TraceWarningError?
		
		// WHEN
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				XCTFail("Test should not success but did with success: \(success)")
			case let .failure(error):
				responseCodeError = error
				expect.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCodeError, .identicationError)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_VerificationFails_THEN_VerificationError() {
		
		// GIVEN
		let client = ClientMock()
		client.onTraceWarningDiscovery = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyResponseDiscovery))
		}
		client.onTraceWarningDownload = { _, _, completion in
			let package = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			let response = PackageDownloadResponse(package: package, etag: "FakeEtag")
			completion(.success(response))
		}
		
		let eventStore = MockEventStore()
		
		
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: MockTestStore(),
			eventStore: eventStore
		)
		
		let expect = expectation(description: "TraceWarningPackage VerificationFails_THEN_VerificationError.")
		var responseCodeError: TraceWarningError?
		
		// WHEN
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfig, completion: { result in
			switch result {
			case let .success(success):
				XCTFail("Test should not success but did with success: \(success)")
			case let .failure(error):
				responseCodeError = error
				expect.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(responseCodeError, .verificationError)
	}
	
	// MARK: - TraceWarningDownload Helper Tests
	
	func testGIVEN_ShouldStartPackageDownload_WHEN_RecentDownloadWasNotSuccessful_THEN_ReturnTrue() {
		
		// GIVEN
		let store = MockTestStore()
		store.wasRecentTraceWarningDownloadSuccessful = false
		
		// WHEN
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: store,
			eventStore: MockEventStore()
		)
		
		// THEN
		let result = traceWarningPackageDownload.shouldStartPackageDownload(for: "DE")
		XCTAssertTrue(result)
	}
	
	func testGIVEN_ShouldStartPackageDownload_WHEN_LastHourIsInDatabaseAndRecentDownloadWasSuccessful_THEN_ReturnFalse() {
		
		// GIVEN
		let store = MockTestStore()
		store.wasRecentTraceWarningDownloadSuccessful = true
		
		let eventStore = MockEventStore()
		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			XCTFail("Could not create lastHourDate.")
			return
		}
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: lastHourDate.unixTimestampInHours, region: "DE", eTag: "FakeETag"))
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: store,
			eventStore: eventStore
		)
		
		// WHEN
		let result = traceWarningPackageDownload.shouldStartPackageDownload(for: "DE")
	
		// THEN
		XCTAssertFalse(result)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_RevokeMetadatas_THEN_IsRevoked() {
		
		// GIVEN
		let eventStore = MockEventStore()
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: 0, region: "DE", eTag: "123"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: 1, region: "DE", eTag: "456"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: 2, region: "DE", eTag: "789"))
		let revokedPackages = [
			SAP_Internal_V2_TraceWarningPackageMetadata.with { $0.etag = "123" },
			SAP_Internal_V2_TraceWarningPackageMetadata.with { $0.etag = "654" },
			SAP_Internal_V2_TraceWarningPackageMetadata.with { $0.etag = "987" }
		]
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: eventStore
		)
	
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 3)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.eTag == "123" }))
		
		// WHEN
		traceWarningPackageDownload.removeRevokedTraceWarningMetadataPackages(revokedPackages)
		
		// THEN
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 2)
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.eTag == "123" }))
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_EarliestRelevantPackage_THEN_CorrectIdIsReturned() {
		
		// GIVEN
		let eventStore = MockEventStore()
		let earliestPackageId = 44440
		let earliestPackageIdPlusOne = 44441
		let earliestPackageIdPlusTwo = 44442
		eventStore.createCheckin(Checkin.mock(checkinStartDate: earliestPackageId.dateFromUnixTimestampInHours ?? Date()))
		eventStore.createCheckin(Checkin.mock(checkinStartDate: earliestPackageIdPlusOne.dateFromUnixTimestampInHours ?? Date()))
		eventStore.createCheckin(Checkin.mock(checkinStartDate: earliestPackageIdPlusTwo.dateFromUnixTimestampInHours ?? Date()))
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: eventStore
		)
	
		XCTAssertEqual(eventStore.checkinsPublisher.value.count, 3)
		
		// WHEN
		let earliestPackage = traceWarningPackageDownload.earliestRelevantPackage
		
		// THEN
		XCTAssertEqual(earliestPackage, earliestPackageId)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_CleanUpOutdatedMetadata_THEN_IsRevoked() {
		
		// GIVEN
		let eventStore = MockEventStore()
		
		let earliestPackageId = 44440
		let earliestPackageIdPlusOne = 44441
		let earliestPackageIdPlusTwo = 44442
		let earliestPackageIdPlusThree = 44443
		let earliestPackageIdPlusFour = 44444

		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageId, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusOne, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusTwo, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusThree, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusFour, region: "DE", eTag: "FakeETag"))
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: eventStore
		)
	
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 5)
		
		// WHEN
		traceWarningPackageDownload.cleanUpOutdatedMetadata(oldest: earliestPackageId, earliest: earliestPackageIdPlusThree)
		
		// THEN
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 2)
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == earliestPackageId }))
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == earliestPackageIdPlusOne }))
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == earliestPackageIdPlusTwo }))
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == earliestPackageIdPlusThree }))
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.contains(where: { $0.id == earliestPackageIdPlusFour }))
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_DeterminePackagesToDownload_THEN_PackagesNotInDatabaseIsReturned() {
		
		// GIVEN
		let eventStore = MockEventStore()
		let earliestPackageId = 44440
		let earliestPackageIdPlusOne = 44441
		let earliestPackageIdPlusTwo = 44442
		let earliestPackageIdPlusThree = 44443
		let earliestPackageIdPlusFour = 44444

		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageId, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusOne, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusTwo, region: "DE", eTag: "FakeETag"))
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusThree, region: "DE", eTag: "FakeETag"))
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: ClientMock(),
			store: MockTestStore(),
			eventStore: eventStore
		)
		let availables = [earliestPackageIdPlusTwo, earliestPackageIdPlusThree, earliestPackageIdPlusFour]
		let earliestRelevantPackageId = earliestPackageIdPlusThree
	
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 4)
		
		// WHEN
		let packagesToDownload = traceWarningPackageDownload.determinePackagesToDownload(availables: availables, earliest: earliestRelevantPackageId)
		
		// THEN
		XCTAssertEqual(packagesToDownload.count, 1)
		XCTAssertFalse(packagesToDownload.contains(where: { $0 == earliestPackageId }))
		XCTAssertFalse(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusThree }))
		XCTAssertTrue(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusFour }))
	}

	
	// MARK: - Private
	
	// Mar 24 2021 09:00:00 == 1616400000
	private var startAsDate: Date {
		return Date(timeIntervalSince1970: 1616400000)
	}
	
	// Mar 24 2021 11:00:00 == 1616407200
	private var endAsDate: Date {
		return Date(timeIntervalSince1970: 1616407200)
	}
	
	// Mar 24 2021 09:00:00 == 449000
	private var startAsId: Int {
		return startAsDate.unixTimestampInHours
	}
	
	// Mar 24 2021 11:00:00 == 449002
	private var endAsId: Int {
		return endAsDate.unixTimestampInHours
	}
	
	// Set oldest little less then startAsId and set latest little more then endAsId
	private lazy var dummyResponseDiscovery: TraceWarningDiscovery = {
		let response = TraceWarningDiscovery(
			oldest: (startAsId - 5),
			latest: (endAsId + 5),
			eTag: "FakeEtag"
		)
		return response
	}()
	
	private lazy var dummyResponseDownload: PackageDownloadResponse = {
		let package = SAPDownloadedPackage(
			keysBin: Data(),
			signature: Data()
		)
		let response = PackageDownloadResponse(
			package: package,
			etag: "FakeEtag"
		)
		return response
	}()
}
