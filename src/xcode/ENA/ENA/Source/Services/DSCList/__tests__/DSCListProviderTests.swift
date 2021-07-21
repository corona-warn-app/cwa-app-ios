////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
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
		let defaultDSCList = readDefaultFile()
		let dscList = provider.dscList.value

		// THEN
		XCTAssertEqual(dscList, defaultDSCList)
	}

	func testGIVEN_Provider_WHEN_UnchangedResponse_THEN_DSCListIsNotUpdated() {
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
		let dscList = provider.dscList.value

		provider.dscList
			.sink { updatedList in
				XCTAssertEqual(dscList, updatedList)
			}
			.store(in: &subscriptions)

		// THEN
		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
		waitForExpectations(timeout: .short)
	}

}
