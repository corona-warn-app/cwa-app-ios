//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class RetryingTests: XCTestCase {

	func testGIVEN_RetryingResource_WHEN_RetryIsDoneWithSuccessAtTheEnd_THEN_SuccesAtLastRetry() throws {

		let loadExpectation = expectation(description: "Retrying is done.")
		loadExpectation.expectedFulfillmentCount = 3

		var retryCount = 3
		let defaultDummyModel = DummyResourceModel(dummyValue: "RetryModel")
		let defaultDummyData = try JSONEncoder().encode( defaultDummyModel )

		let url = try XCTUnwrap(URL(string: "https://example.com"))

		// Prepare responses
		let failingResponse = HTTPURLResponse(
			url: url,
			statusCode: 500,
			httpVersion: nil,
			headerFields: nil
		)
		let successfulResponse = HTTPURLResponse(
			url: url,
			statusCode: 200,
			httpVersion: nil,
			headerFields: nil
		)

		// Call fullfill on every request and decrease the retryCount
		let mockSession = MockUrlSession(
			data: nil,
			nextResponse: nil,
			error: nil
		) { _ in
			loadExpectation.fulfill()
			retryCount -= 1
		}

		// Return success with our model as soon we arrive the last retry. otherwise, return always a failure
		mockSession.onPrepareResponse = {
			if retryCount > 0 {
				mockSession.data = nil
				mockSession.nextResponse = failingResponse
			} else {
				mockSession.data = defaultDummyData
				mockSession.nextResponse = successfulResponse
			}
		}

		// Return nil and http code 500. In this case the service would ignore caching behavior and look up for default values.
		let stack = MockNetworkStack(
			mockSession: mockSession
		)

		let standardService = StandardRestService(session: stack.urlSession)

		let resource = ResourceFake(retryingCount: 3)

		standardService.load(resource, { result in

			switch result {

			case .success(let model):
				XCTAssertEqual(model, defaultDummyModel)
			case .failure(let error):
				XCTFail("Test should not fail but received error: \(error)")
			}
		})

		waitForExpectations(timeout: .short)
	}

	func testGIVEN_RetryingResourceWithoutDefaultModel_WHEN_RetryIsDoneWithoutSuccess_THEN_FailureAtLastRetry() throws {
		let loadExpectation = expectation(description: "Retrying is done.")
		loadExpectation.expectedFulfillmentCount = 3

		var retryCount = 3

		let url = try XCTUnwrap(URL(string: "https://example.com"))

		// Prepare responses
		let failingResponse = HTTPURLResponse(
			url: url,
			statusCode: 500,
			httpVersion: nil,
			headerFields: nil
		)

		// Call fullfill on every request and decrease the retryCount
		let mockSession = MockUrlSession(
			data: nil,
			nextResponse: nil,
			error: nil
		) { _ in
			loadExpectation.fulfill()
			retryCount -= 1
		}

		// Return success with our model as soon we arrive the last retry. otherwise, return always a failure
		mockSession.onPrepareResponse = {
			mockSession.data = nil
			mockSession.nextResponse = failingResponse
		}

		// Return nil and http code 500. In this case the service would ignore caching behavior and look up for default values.
		let stack = MockNetworkStack(
			mockSession: mockSession
		)

		let standardService = StandardRestService(session: stack.urlSession)

		let resource = ResourceFake(retryingCount: 3)

		standardService.load(resource, { result in

			switch result {

			case .success:
				XCTFail("Test should not succeed")
			case .failure(let error):
				XCTAssertEqual(error, ServiceError.unexpectedServerError(500))
			}
		})

		waitForExpectations(timeout: .short)
	}

	func testGIVEN_RetryingResourceWithDefaultModel_WHEN_RetryIsDoneWithoutSuccess_THEN_DefaultModelIsReturnedAfterLastRetry() throws {

		let loadExpectation = expectation(description: "Retrying is done.")
		loadExpectation.expectedFulfillmentCount = 3

		var retryCount = 3

		// Call fullfill on every request and decrease the retryCount
		let mockSession = MockUrlSession(
			data: nil,
			nextResponse: nil,
			error: nil
		) { _ in
			loadExpectation.fulfill()
			retryCount -= 1
		}

		let url = try XCTUnwrap(URL(string: "https://example.com"))

		// Prepare responses
		let failingResponse = HTTPURLResponse(
			url: url,
			statusCode: 500,
			httpVersion: nil,
			headerFields: nil
		)

		// Return success with our model as soon we arrive the last retry. otherwise, return always a failure
		mockSession.onPrepareResponse = {
			mockSession.data = nil
			mockSession.nextResponse = failingResponse
		}

		// Return nil and http code 500. In this case the service would ignore caching behavior and look up for default values.
		let stack = MockNetworkStack(
			mockSession: mockSession
		)

		let standardService = StandardRestService(session: stack.urlSession)

		let defaultModel = DummyResourceModel(dummyValue: "DefaultModel")
		let resource = ResourceFake(
			defaultModel: defaultModel,
			retryingCount: 3
		)

		standardService.load(resource, { result in

			switch result {

			case .success(let model):
				XCTAssertEqual(model, defaultModel)
			case .failure(let error):
				XCTFail("Test should not fail but received error: \(error)")
			}
			loadExpectation.fulfill()
		})

		waitForExpectations(timeout: .short)
	}
}
