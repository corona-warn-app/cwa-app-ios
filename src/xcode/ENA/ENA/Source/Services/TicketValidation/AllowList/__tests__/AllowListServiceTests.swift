//
// 🦠 Corona-Warn-App
//

import XCTest
import ENASecurity
@testable import ENA

class AllowListServiceTests: XCTestCase {

	func test_FetchingAllowList_Success() {
		let restServiceProvider = RestServiceProviderStub(results: [.success(SAP_Internal_Dgc_ValidationServiceAllowlist())])
		let store = MockTestStore()
		let service = AllowListService(restServiceProvider: restServiceProvider, store: store)
		
		service.fetchAllowList { result in
			switch result {
			case .success(let allowList):
				XCTAssertTrue(allowList.validationServiceAllowList.isEmpty)
			case .failure:
				XCTFail("expected to fetch the list")
			}
		}
	}
	
}
