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
				RegistrationTokenModel(
					registrationToken: fakeToken
				)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: KeyModel(
				key: fakeToken,
				keyType: .teleTan
			)
		)
		serviceProvider.load(teleTanResource) { result in
			expectation.fulfill()
			switch result {
			case .success(let model):
				XCTAssertEqual(model.registrationToken, fakeToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
		}
		waitForExpectations(timeout: .short)
	}


	func testGetRegistrationToken_GUIDSuccess() throws {
		let fakeToken = "SomeToken"
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				RegistrationTokenModel(
					registrationToken: fakeToken
				)
			)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession)
		let teleTanResource = TeleTanResource(
			isFake: false,
			sendModel: KeyModel(
				key: fakeToken,
				keyType: .guid
			)
		)
		serviceProvider.load(teleTanResource) { result in
			expectation.fulfill()
			switch result {
			case .success(let model):
				XCTAssertEqual(model.registrationToken, fakeToken)
			case .failure:
				XCTFail("Encountered Error when receiving registration token!")
			}
		}
		waitForExpectations(timeout: .short)
	}
/*
	func testGIVEN_Client_WHEN_GetRegistrationTokenIsCalledWithBirthdate_THEN_TokenIsReturned() throws {
		// GIVEN
		let expectedToken = "SomeToken"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken))
		)

		let expectation = self.expectation(
			description: "Expect that we got a completion"
		)

		var responseToken: String?

		// WHEN
		HTTPClient.makeWith(mock: stack).getRegistrationToken(
			forKey: "1234567890",
			withType: "GUID",
			dateOfBirthKey: "x987654321"
		) { result in
			switch result {
			case .success(let token):
				responseToken = token
			case .failure:
				XCTFail("Test should not fail.")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: expectationsTimeout)

		// THEN
		XCTAssertEqual(responseToken ?? "FAIL", expectedToken)
	}

	func testGetRegistrationToken_TANAlreadyUsed() throws {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Test should succeed with token returned"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "TELETAN") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .teleTanAlreadyUsed:
					break
				default:
					XCTFail("The error was not .teleTanAlreadyUsed!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_GUIDAlreadyUsed() throws {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .qrAlreadyUsed:
					break
				default:
					XCTFail("The error was not .qrAlreadyUsed!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_MalformedResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned random bytes - the request should have failed!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_MalformedJSONResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "NotregistrationToken":"Hello" }
			""".data(using: .utf8)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: "1234567890", withType: "GUID") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Backend returned 400 - the request should have failed!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetRegistrationToken_VerifyPOSTBodyContent() throws {
		let expectedToken = "SomeToken"
		let key = "1234567890"
		let type = "GUID"

		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected key & key type as JSON!")
				return
			}

			guard content["key"] == key else {
				XCTFail("POST JSON body did not have key value, or it was incorrect!")
				return
			}

			guard content["keyType"] == type else {
				XCTFail("POST JSON body did not have keyType value, or it was incorrect!")
				return
			}
		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken)),
			requestObserver: verifyPostBodyContent
		)

		HTTPClient.makeWith(mock: stack).getRegistrationToken(forKey: key, withType: type) { _ in }
		waitForExpectations(timeout: expectationsTimeout)
	}
 */
}
