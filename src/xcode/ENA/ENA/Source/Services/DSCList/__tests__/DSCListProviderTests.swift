////
// 🦠 Corona-Warn-App
//

import XCTest
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

}
