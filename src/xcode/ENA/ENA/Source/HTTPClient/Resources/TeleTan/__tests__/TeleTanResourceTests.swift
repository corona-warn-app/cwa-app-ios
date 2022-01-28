//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class TeleTanResourceTests: CWATestCase {

	func testGetRegistrationToken_TeleTANSuccess() throws {
		let fakeToken = "SomeToken"
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationTockenReceiveModel(
					registrationToken: fakeToken
				)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: fakeToken,
				keyType: .teleTan
			)
		)
		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success(let model):
				XCTAssertEqual(model.registrationToken, fakeToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}


	func testGetRegistrationToken_GUIDSuccess() throws {
		let fakeToken = "SomeToken"
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationTockenReceiveModel(
					registrationToken: fakeToken
				)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: fakeToken,
				keyType: .guid
			)
		)
		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success(let model):
				XCTAssertEqual(model.registrationToken, fakeToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Client_WHEN_GetRegistrationTokenIsCalledWithBirthdate_THEN_TokenIsReturned() throws {
		let fakeToken = "SomeToken"
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationTockenReceiveModel(
					registrationToken: fakeToken
				)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: fakeToken,
				keyType: .guid,
				keyDob: "x987654321"
			)
		)
		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success(let model):
				XCTAssertEqual(model.registrationToken, fakeToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetRegistrationToken_TANAlreadyUsed() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: "some value",
				keyType: .teleTan
			)
		)
		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success:
				XCTFail("TAN already used - should not succeed")
			case .failure(let error):
				guard case let .receivedResourceError(customError) = error,
					  .teleTanAlreadyUsed == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testGetRegistrationToken_GUIDAlreadyUsed() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: "some value",
				keyType: .guid
			)
		)
		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success:
				XCTFail("TAN already used - should not succeed")
			case .failure(let error):
				guard case let .receivedResourceError(customError) = error,
					  .qrAlreadyUsed == customError else {
						  XCTFail("unexpected error case")
						  return
					  }
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testGetRegistrationToken_MalformedResponse() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: "1234567890",
				keyType: .guid
			)
		)

		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case let .decoding(decodingError) = resourceError,
					  case .JSON_DECODING = decodingError else {
						 
					XCTFail("unexpected error case")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetRegistrationToken_MalformedJSONResponse() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "NotregistrationToken":"Hello" }
			""".data(using: .utf8)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: "1234567890",
				keyType: .guid
			)
		)

		serviceProvider.load(teleTanResource) { result in
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				// Successful test if we can extract the resourceError to an decoding error, regardless what JSON decoding error exactly it is.
				guard case let .resourceError(resourceError) = error,
					  case let .decoding(decodingError) = resourceError,
					  case let .JSON_DECODING(someError) = decodingError,
					  case _ = someError else {
						 
					XCTFail("unexpected error case")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGetRegistrationToken_VerifyPOSTBodyContent() throws {
		let testKey = "1234567890"

		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected key & key type as JSON!")
				return
			}

			guard content["key"] == testKey else {
				XCTFail("POST JSON body did not have key value, or it was incorrect!")
				return
			}

			guard content["keyType"] == KeyType.guid.rawValue else {
				XCTFail("POST JSON body did not have keyType value, or it was incorrect!")
				return
			}
		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationTockenReceiveModel(
					registrationToken: "SomeToken"
				)
			),
			requestObserver: verifyPostBodyContent
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: TeleTanSendModel(
				key: testKey,
				keyType: .guid
			)
		)
		serviceProvider.load(teleTanResource) { _ in }

		waitForExpectations(timeout: .short)
	}

}
