////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
import HealthCertificateToolkit
@testable import ENA

class DSCListProviderTests: XCTestCase {

	// MARK: - Helper

	func readDefaultFile() -> SAP_Internal_Dgc_DscList {
		guard
			let url = Bundle.main.url(forResource: "default_dsc_list", withExtension: "bin"),
			let data = try? Data(contentsOf: url),
			let dscList = try? SAP_Internal_Dgc_DscList(serializedData: data)
		else {
			fatalError("Failed to read default DSCList bin file - set empty fallback")
		}
		return dscList
	}

	func convert(dscList: SAP_Internal_Dgc_DscList) -> [DCCSigningCertificate] {
		return dscList.certificates.map { listItem in
			DCCSigningCertificate(kid: listItem.kid, data: listItem.data)
		}
	}

	// MARK: - Tests

	func testWHEN_DefaultFileIsMissing_THEN_Failed() throws {
		let url = Bundle.main.url(forResource: "default_dsc_list", withExtension: "bin")

		// THEN
		XCTAssertNotNil(url, "missing default DSCList file")
	}

	func testGIVEN_Provider_WHEN_getDSCList_THEN_isEqualToDefault() {
		// GIVEN
		let provider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		// WHEN
		let defaultDSCList = convert(dscList: readDefaultFile())
		let dscList = provider.signingCertificates.value

		// THEN
		XCTAssertEqual(dscList, defaultDSCList)
	}

	func testGIVEN_Provider_WHEN_UnchangedResponse_THEN_FetchAgainOnNotification() {
		let fetchedFromClientExpectation = expectation(description: "DSC list fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 2

		let client = CachingHTTPClientMock()
		client.onFetchLocalDSCList = { _, completeWith in
			// fake notModified 304 response
			completeWith(.failure(URLSessionError.notModified))
			fetchedFromClientExpectation.fulfill()
		}

		let provider = DSCListProvider(
			client: client,
			store: MockTestStore()
		)
		var subscriptions = Set<AnyCancellable>()

		// WHEN
		let dscList = provider.signingCertificates.value

		provider.signingCertificates
			.sink { updatedList in
				XCTAssertEqual(dscList, updatedList)
			}
			.store(in: &subscriptions)

		// THEN
		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_provider_WHEN_NotificationAfterInterval_THEN_DSCListGotUpdated() {
		// GIVEN
		let fetchedFromClientExpectation = expectation(description: "DSC list fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 2

		let client = CachingHTTPClientMock()
		var count  = 1
		client.onFetchLocalDSCList = { _, completeWith in
			completeWith(.success(DSCListResponse(dscList: SAP_Internal_Dgc_DscList(), eTag: String(count))))
			count += 1
			fetchedFromClientExpectation.fulfill()
		}

		let provider = DSCListProvider(
			client: client,
			store: MockTestStore(),
			interval: 1.0
		)
		// WHEN
		let waitExpectation = expectation(description: "Wait for 2 seconds")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			waitExpectation.fulfill()
		}
		wait(for: [waitExpectation], timeout: .medium)

		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
		wait(for: [fetchedFromClientExpectation], timeout: .short)
		XCTAssertEqual(provider.metaData.eTag, "2")
	}

}
