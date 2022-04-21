//
// 🦠 Corona-Warn-App
//

//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class KIDTypeChunkResourceTests: XCTestCase {
	
	func testGIVEN_Resource_WHEN_Response_200_THEN_ModelIsReturned() throws {
		let testModel = SAP_Internal_Dgc_RevocationChunk()
		let package = SAPDownloadedPackage(
			keysBin: try testModel.serializedData(),
			signature: Data()
		)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["ETag": "42"],
			responseData: try package.zipped().data
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let kidTypeChunkResource = KIDTypeChunkResource(
			kid: "kid",
			hashType: "hashType",
			x: "x",
			y: "y",
			signatureVerifier: MockVerifier()
		)
		restServiceProvider.load(kidTypeChunkResource) { result in
			switch result {
			case let .success(receivedModel):
				XCTAssertEqual(testModel, receivedModel)
			case let .failure(error):
				XCTFail("Test should succeed but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_Response_400_THEN_ClientErrorIsReturned() throws {
		let stack = MockNetworkStack(
			httpStatus: 400
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let kidTypeChunkResource = KIDTypeChunkResource(
			kid: "kid",
			hashType: "hashType",
			x: "x",
			y: "y"
		)
		restServiceProvider.load(kidTypeChunkResource) { result in
			switch result {
			case .success:
				XCTFail("Success is not expected")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.DCC_RL_KTXY_CHUNK_CLIENT_ERROR))
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_Response_500_THEN_ServerErrorIsReturned() throws {
		let stack = MockNetworkStack(
			httpStatus: 500
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let kidTypeChunkResource = KIDTypeChunkResource(
			kid: "kid",
			hashType: "hashType",
			x: "x",
			y: "y"
		)
		restServiceProvider.load(kidTypeChunkResource) { result in
			switch result {
			case .success:
				XCTFail("Success is not expected")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.DCC_RL_KTXY_CHUNK_SERVER_ERROR))
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_SignatureInvalid_THEN_SignatureInvalidIsReturned() throws {
		let testModel = SAP_Internal_Dgc_RevocationKidList()
		
		// Package with invalid signature.
		let package = SAPDownloadedPackage(
			keysBin: try testModel.serializedData(),
			signature: Data()
		)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["ETag": "42"],
			responseData: try package.zipped().data
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let kidTypeChunkResource = KIDTypeChunkResource(
			kid: "kid",
			hashType: "hashType",
			x: "x",
			y: "y"
		)
		restServiceProvider.load(kidTypeChunkResource) { result in
			switch result {
			case .success:
				XCTFail("Success is not expected")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.DCC_RL_KTXY_INVALID_SIGNATURE))
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_NetworkFails_THEN_NetworkErrorIsReturned() throws {
		let stack = MockNetworkStack(
			error: FakeError.fake
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let kidTypeChunkResource = KIDTypeChunkResource(
			kid: "kid",
			hashType: "hashType",
			x: "x",
			y: "y"
		)
		restServiceProvider.load(kidTypeChunkResource) { result in
			switch result {
			case .success:
				XCTFail("Success is not expected")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.DCC_RL_KTXY_CHUNK_NO_NETWORK))
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
}
