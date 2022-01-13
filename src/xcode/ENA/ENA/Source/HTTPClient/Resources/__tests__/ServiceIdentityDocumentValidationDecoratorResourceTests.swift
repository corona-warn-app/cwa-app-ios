//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ServiceIdentityDocumentValidationDecoratorResourceTests: XCTestCase {
	
	func test_If_RestService_Got_ClientError_Then_Abort() {
		let expectation = expectation(description: "Expect that we got a completion")
		
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data()
		)
		
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		guard let url = URL(string: "https://www.test.com") else {
			XCTFail("Failed to create URL")
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("client error is expected!")
			case .failure(let error):
				guard case let .receivedResourceError(resourceError) = error,
					  .VD_ID_CLIENT_ERR == resourceError else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_If_RestService_Got_ServerError_Then_Abort() {
		let expectation = expectation(description: "Expect that we got a completion")
		
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)
		
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		guard let url = URL(string: "https://www.test.com") else {
			XCTFail("Failed to create URL")
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("server error is expected!")
			case .failure(let error):
				guard case let .receivedResourceError(resourceError) = error,
					  .VD_ID_SERVER_ERR == resourceError else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_If_RestService_Got_Invalid_JSON_Then_Abort() {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
				{ "Wrongexample":"Hello" }
				""".data(using: .utf8)
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		guard let url = URL(string: "https://www.test.com") else {
			XCTFail("Failed to create URL")
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				guard case let .receivedResourceError(resourceError) = error,
					  resourceError == .VD_ID_PARSE_ERR else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func test_If_NoNetwork_Then_Abort() throws {
		let expectation = expectation(description: "Expect that we got a completion")
		let errorFake = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
	
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				ServiceIdentityDocument(
					id: "TEST",
					verificationMethod: [],
					service: []
				)
			),
			error: errorFake
		)
		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		guard let url = URL(string: "https://www.test.com") else {
			XCTFail("Failed to create URL")
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				guard case let .receivedResourceError(resourceError) = error,
					  resourceError == .VD_ID_NO_NETWORK else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
}
