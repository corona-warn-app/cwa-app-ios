////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class TraceWarningPackageDownloadTests: CWATestCase {
	
	func testGIVEN_TraceWarningDownload_WHEN_HappyCase_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload),
					.success(dummyResponseDownload)
				]
			),
			store: store,
			eventStore: eventStore,
			signatureVerifier: MockVerifier()
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
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_CheckInDatabaseIsEmpty_THEN_Success() {
		// GIVEN
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		let eventStore = MockEventStore()
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
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
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_CheckInDatabaseIsNotEmpty_THEN_Success() {
		// GIVEN
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		let eventStore = MockEventStore()
		
		let checkin = Checkin.mock()
		eventStore.createCheckin(checkin)
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery)
				]
			),
			store: store,
			eventStore: eventStore
		)
		
		let successExpectation = expectation(description: "TraceWarningPackage CheckInDatabaseIsNotEmpty_THEN_Success.")
		
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
		XCTAssertEqual(responseCode, .noPackagesAvailable)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_AvailablePackagesOnCDNAreEmpty_THEN_Success() {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(TraceWarningDiscoveryModel(oldest: 12345, latest: 12344))
				]
			),
			store: store,
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
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)	}
	
	func testGIVEN_TraceWarningDownload_WHEN_SinglePackageIsEmpty_THEN_Success() throws {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload),
					.success(emptyResponseDownload)
				]
			),
			store: store,
			eventStore: eventStore
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
		XCTAssertFalse(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	// MARK: - Errors
	
	func testGIVEN_TraceWarningDownload_WHEN_DownloadIsAlreadyInProgress_THEN_DownloadIsRunning() {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(results: [.success(dummyResponseDiscovery)]),
			store: store,
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
		XCTAssertEqual(responseCodeSuccess, .noPackagesAvailable)
		XCTAssertEqual(responseCodeError, .downloadIsRunning)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_DiscoveryIsFailing_THEN_InvalidResponseError() throws {
		// GIVEN
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(results: [.failure(ServiceError<TraceWarningError>.invalidResponse)]),
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
		XCTAssertEqual(responseCodeError, .generalError)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_NoEarliestPackageFound_THEN_NoEarliestRelevantPackageError() {
		// GIVEN
		let eventStore = MockEventStore()
		let loadResource = LoadResource(result: .success(self.dummyResponseDiscovery)) { _ in
			eventStore.deleteAllCheckins()
		}

		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			store: store,
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
		XCTAssertEqual(responseCodeError, .noEarliestRelevantPackage)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_DownloadIsFailing_THEN_InvalidResponseError() {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse),
					.failure(ServiceError<TraceWarningError>.invalidResponse)
				]
			),
			store: store,
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
		XCTAssertEqual(responseCodeError, .invalidResponseError)
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_EtagMissing_THEN_IdenticationError() {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))), // packages with no etag
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))),
					.success(PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data())))
				]
			),
			store: store,
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
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_VerificationFails_THEN_VerificationError() {
		// GIVEN
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(
				results: [
					.success(dummyResponseDiscovery),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload),
					.success(brokenSignatureResponseDownload)
				]
			),
			store: store,
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
		XCTAssertTrue(eventStore.traceWarningPackageMetadatasPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceTimeIntervalMatchesPublisher.value.isEmpty)
		XCTAssertFalse(eventStore.checkinsPublisher.value.isEmpty)
		XCTAssertTrue(eventStore.traceLocationsPublisher.value.isEmpty)
	}
	
	// MARK: - TraceWarningDownload Helper Tests
	
	func testGIVEN_ShouldStartPackageDownload_WHEN_RecentDownloadWasNotSuccessful_THEN_ReturnTrue() {
		// GIVEN
		let store = MockTestStore()
		store.wasRecentTraceWarningDownloadSuccessful = false
		
		// WHEN
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
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
			restServiceProvider: RestServiceProviderStub(),
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
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
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

		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
		)

		XCTAssertEqual(eventStore.checkinsPublisher.value.count, 3)
		
		// WHEN
		let earliestPackage = traceWarningPackageDownload.earliestRelevantPackageId
		
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

		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
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
		eventStore.createTraceWarningPackageMetadata(TraceWarningPackageMetadata(id: earliestPackageIdPlusThree, region: "DE", eTag: "FakeETag"))
		
		let store = MockTestStore()
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			restServiceProvider: RestServiceProviderStub(),
			store: store,
			eventStore: eventStore
		)
		let availables = [earliestPackageId, earliestPackageIdPlusOne, earliestPackageIdPlusTwo, earliestPackageIdPlusThree, earliestPackageIdPlusFour]
		let earliestRelevantPackageId = earliestPackageIdPlusOne
	
		XCTAssertEqual(eventStore.traceWarningPackageMetadatasPublisher.value.count, 3)
		
		// WHEN
		let packagesToDownload = traceWarningPackageDownload.determinePackagesToDownload(availables: availables, earliest: earliestRelevantPackageId)
		
		// THEN
		XCTAssertEqual(packagesToDownload.count, 2)
		XCTAssertFalse(packagesToDownload.contains(where: { $0 == earliestPackageId }))
		XCTAssertFalse(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusOne }))
		XCTAssertTrue(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusTwo }))
		XCTAssertFalse(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusThree }))
		XCTAssertTrue(packagesToDownload.contains(where: { $0 == earliestPackageIdPlusFour }))
	}

	func testGIVEN_CountryAndPackageId_WHEN_HappyCase_THEN_TraceWarningPackageIsReturned() throws {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-traceWarning", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)

		let expectation = expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(package):
				self.assertPackageFormat(for: package)

			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}

		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_CountryAndPackageId_WHEN_EmptyContentHeaderIsSend_THEN_EmptyTraceWarningPackageIsReturned() throws {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "0"],
			responseData: Data()
		)

		let expectation = expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(package):
				XCTAssertNotNil(package)
				XCTAssertTrue(package.isEmpty)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_CountryAndPackageId_WHEN_PackageIsInvalid_THEN_InvalidResponseErrorIsReturned() {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				// THEN
				if case let .receivedResourceError(traceWarningError) = error,
				   traceWarningError == .invalidResponseError {
					XCTAssertTrue(true)
				} else {
					XCTFail("unexpected error case")
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_CountryAndPackageId_WHEN_EmptyResponse_THEN_InvalidResponseErrorIsReturned() {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: nil
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				// THEN
				if case let .receivedResourceError(traceWarningError) = error,
				   traceWarningError == .invalidResponseError {
					XCTAssertTrue(true)
				} else {
					XCTFail("unexpected error case")
				}
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	// MARK: - Private

	private let binFileSize = 50
	private let sigFileSize = 138
	private let expectationsTimeout: TimeInterval = 2

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
	private lazy var dummyResponseDiscovery: TraceWarningDiscoveryModel = {
		let response = TraceWarningDiscoveryModel(
			oldest: (startAsId - 5),
			latest: (endAsId + 5)
		)
		return response
	}()
	
	private lazy var dummyResponseDownload: PackageDownloadResponse = {
		let package = SAPDownloadedPackage(
			keysBin: Data(),
			signature: Data()
		)
		var response = PackageDownloadResponse(
			package: package
		)
		response.metaData.headers["ETag"] = "SomeETag"
		return response
	}()

	private lazy var emptyResponseDownload: PackageDownloadResponse = {
		var response = PackageDownloadResponse(package: nil)
		response.metaData.headers["ETag"] = "SomeETag"
		return response
	}()

	private lazy var brokenSignatureResponseDownload: PackageDownloadResponse = {
		var response = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()))
		response.metaData.headers["ETag"] = "SomeETag"
		return response
	}()

	private func assertPackageFormat(for response: PackageDownloadResponse, isEmpty: Bool = false) {
		// Packages for trace warnings can be empty if special http header is send.
		isEmpty ? XCTAssertTrue(response.isEmpty) : XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}

}
