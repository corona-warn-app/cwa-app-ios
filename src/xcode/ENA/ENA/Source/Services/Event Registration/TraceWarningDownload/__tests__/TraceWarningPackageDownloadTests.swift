////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

class TraceWarningPackageDownloadTests: XCTestCase {
	
	// MARK: - Success
	
	func testGIVEN_TraceWarningDownload_WHEN_HappyCase_THEN_Success() {
		
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
		
		let successExpectation = expectation(description: "TraceWarningPackage download was successful.")
		
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
		
		let successExpectation = expectation(description: "TraceWarningPackage download was successful.")
		
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
		
		let successExpectation = expectation(description: "TraceWarningPackage download was successful.")
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
	
	// MARK: - Private
	
	private lazy var dummyResponseDiscovery: TraceWarningDiscovery = {
		let response = TraceWarningDiscovery(oldest: 12345, latest: 98765, eTag: "FakeEtag")
		return response
	}()
	
	private lazy var dummyResponseDownload: PackageDownloadResponse = {
		let package = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let response = PackageDownloadResponse(package: package, etag: "FakeEtag")
		return response
	}()
}
