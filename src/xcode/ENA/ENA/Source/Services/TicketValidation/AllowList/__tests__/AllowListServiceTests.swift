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
	
	func test_FetchingAllowList_Failure() {
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<AllowListResource.CustomError>.transportationError(errorFake))
			]
		)
		let store = MockTestStore()
		let service = AllowListService(restServiceProvider: restServiceProvider, store: store)
		
		service.fetchAllowList { result in
			switch result {
			case .success:
				XCTFail("expected to fail fetching the allowlist")
			case .failure(let error):
				XCTAssertEqual(error, .REST_SERVICE_ERROR(.transportationError(errorFake)), "should have the same error type")
			}
		}
	}
	
	func test_ServiceIdentityAllowList_MatchFound() {
		let testString = "www.testServiceIdentity.com"
		let allowListMatchObject = Data(hex: testString.sha256())
		let allowListService = AllowListService(restServiceProvider: RestServiceProviderStub.fake(), store: MockTestStore())
		let result = allowListService.checkServiceIdentityAgainstServiceProviderAllowlist(
			serviceProviderAllowlist: [allowListMatchObject],
			serviceIdentity: testString
		)
		
		switch result {
		case .failure(let error):
			XCTFail("expected to find service identity match in the allowlist \(error.localizedDescription)")
		default:
			break
		}
	}
	
	func test_ServiceIdentityAllowList_NoMatch_then_SP_ALLOWLIST_NO_MATCH() {
		let testString = "www.testServiceIdentity.com"
		let allowListMatchObject = Data(hex: "wrongString".sha256())
		let allowListService = AllowListService(restServiceProvider: RestServiceProviderStub.fake(), store: MockTestStore())
		let result = allowListService.checkServiceIdentityAgainstServiceProviderAllowlist(
			serviceProviderAllowlist: [allowListMatchObject],
			serviceIdentity: testString
		)
		
		switch result {
		case .failure(let error):
			XCTAssertEqual(error, .SP_ALLOWLIST_NO_MATCH)
		default:
			XCTFail("Expected SP_ALLOWLIST_NO_MATCH when Validating Service identity Against AllowList")
		}
	}
	
	
}
