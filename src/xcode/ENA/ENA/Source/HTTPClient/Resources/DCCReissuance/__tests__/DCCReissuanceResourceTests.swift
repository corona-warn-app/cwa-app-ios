//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import ENASecurity

final class DCCReissuanceResourceTests: CWATestCase {

	// MARK: - Success

	func testGIVEN_Resource_WHEN_Response_200_THEN_ModelIsReturned() throws {
		// GIVEN

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let relation = DCCReissuanceRelation(index: 0, action: "yes")
		let certficate = DCCReissuanceCertificate(certificate: "one", relations: [relation])
		let model = DCCReissuanceReceiveModel([certficate])

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(model)
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let dccReissuanceResource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)
		restServiceProvider.load(dccReissuanceResource) { result in
			switch result {
			case let .success(model):
				XCTAssertEqual(model.first?.certificate, "one")
				XCTAssertEqual(model.first?.relations.first?.index, 0)
				XCTAssertEqual(model.first?.relations.first?.action, "yes")
			case let .failure(error):
				XCTFail("Test should succeed but failed with error: \(error)")
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)

	}

	// MARK: - Failures

	func testGIVEN_Resource_WHEN_Response_Body_Is_Malformed_THEN_DCC_RI_PARSE_ERR() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode("Hello")
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_PARSE_ERR) = error else {
					XCTFail("DCC_RI_PARSE_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_TransportationError_THEN_DCC_RI_NO_NETWORK() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_NO_NETWORK) = error else {
					XCTFail("DCC_RI_NO_NETWORK error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_400_THEN_DCC_RI_400() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode("{\"errorCode\":\"RI400-1200\",\"message\":\"certificates not acceptable for action\"}")
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_400) = error else {
					XCTFail("DCC_RI_400 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_401_THEN_DCC_RI_401() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 401
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_401) = error else {
					XCTFail("DCC_RI_401 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_403_THEN_DCC_RI_403() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 403
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_403) = error else {
					XCTFail("DCC_RI_403 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_406_THEN_DCC_RI_406() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 406
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_406) = error else {
					XCTFail("DCC_RI_406 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_429_THEN_DCC_RI_429() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 429
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_429) = error else {
					XCTFail("DCC_RI_429 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_500_THEN_DCC_RI_500() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 500
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_500) = error else {
					XCTFail("DCC_RI_500 error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_456_THEN_DCC_RI_CLIENT_ERR() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 456
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_CLIENT_ERR) = error else {
					XCTFail("DCC_RI_CLIENT_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_505_THEN_DCC_RI_SERVER_ERR() throws {
		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			httpStatus: 505
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let sendModel = DCCReissuanceSendModel(
			certificates: [
				"one"
			]
		)

		let resource = DCCReissuanceResource(
			sendModel: sendModel,
			trustEvaluation: .fake()
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.DCC_RI_SERVER_ERR) = error else {
					XCTFail("DCC_RI_SERVER_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
}
