////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

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
		let verifier = MockVerifier()
		
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore,
			verifier: verifier
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
	}
	
	func testGIVEN_TraceWarningDownload_WHEN_CheckInDatabaseIsEmpty_THEN_Success() {
		
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
		
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let verifier = MockVerifier()
		
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore,
			verifier: verifier
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
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock()
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
	
	func testGIVEN_TraceWarningDownload_WHEN_DiscoveryIsFailing_THEN_InvalidResponseError() {
		
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
			eventStore: eventStore)
		
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
		
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
		
		let store = MockTestStore()
		let eventStore = MockEventStore()
		
		
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
		
		let store = MockTestStore()
		let eventStore = MockEventStore()
		
		
		let checkInMock = Checkin.mock(checkinStartDate: startAsDate, checkinEndDate: endAsDate)
		eventStore.createCheckin(checkInMock)
		let appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		
		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore)
		
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
