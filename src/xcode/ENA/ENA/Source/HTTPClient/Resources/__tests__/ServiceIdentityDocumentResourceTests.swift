//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import ENASecurity

final class ServiceIdentityDocumentResourceTests: CWATestCase {

	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_THEN_Success() throws {
		let expectedServiceIdentityDocument = TicketValidationServiceIdentityDocument.fake()
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				expectedServiceIdentityDocument
			)
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let serviceIdentityDocument):
				XCTAssertEqual(serviceIdentityDocument, expectedServiceIdentityDocument)
			case .failure(let error):
				XCTFail("Success expected. Instead error received: \(error)")
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_DecodingFails_THEN_VS_ID_PARSE_ERR_ERROR() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(
				"Not TicketValidationServiceIdentityDocument"
			)
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_PARSE_ERR) = error else {
					XCTFail("VS_ID_PARSE_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_NetworkFails_THEN_VS_ID_NO_NETWORK() throws {
		let stack = MockNetworkStack(
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_NO_NETWORK) = error else {
					XCTFail("VS_ID_NO_NETWORK error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_ClientFails_THEN_VS_ID_CLIENT_ERR() throws {
		let stack = MockNetworkStack(
			httpStatus: 403
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_CLIENT_ERR) = error else {
					XCTFail("VS_ID_CLIENT_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_ServerFails_THEN_VS_ID_SERVER_ERR() throws {
		let stack = MockNetworkStack(
			httpStatus: 503
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_SERVER_ERR) = error else {
					XCTFail("VS_ID_CLIENT_ERR error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_DynmaicPinningNoHostMatchFound_THEN_VS_ID_CERT_PIN_HOST_MISMATCH() throws {

		let trustErrorStub = EvaluateTrustErrorStub(
			error: TrustEvaluationError.CERT_PIN_HOST_MISMATCH
		)
		let sessionDelegate = CoronaWarnURLSessionDelegate(evaluateTrust: trustErrorStub)
		let stack = MockNetworkStack(
			sessionDelegate: sessionDelegate,
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_CERT_PIN_HOST_MISMATCH) = error else {
					XCTFail("VS_ID_CERT_PIN_HOST_MISMATCH error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_ServiceIdentityDocumentResource_WHEN_Loading_DynamicPinningCertificateMismatches_THEN_VS_ID_CERT_PIN_MISMATCH() throws {
		
		let trustErrorStub = EvaluateTrustErrorStub(
			error: TrustEvaluationError.CERT_PIN_MISMATCH
		)
		let sessionDelegate = CoronaWarnURLSessionDelegate(evaluateTrust: trustErrorStub)
		let stack = MockNetworkStack(
			sessionDelegate: sessionDelegate,
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		)
		
		let restServiceProvider = RestServiceProvider(session: stack.urlSession)

		let fakeURL = try XCTUnwrap(URL(string: "some"))
		let resource = ServiceIdentityDocumentResource(endpointUrl: fakeURL)

		let expectation = expectation(description: "Expect that we got a completion")
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .receivedResourceError(.VS_ID_CERT_PIN_MISMATCH) = error else {
					XCTFail("VS_ID_CERT_PIN_MISMATCH error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
}

struct EvaluateTrustErrorStub: EvaluateTrust {

	init(error: Error) {
		trustEvaluationError = error
	}
	
	// MARK: - Protocol EvaluateTrust
	
	// We don't need to implement, trustEvaluationError will be used by the delegate to read the error.
	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {}
	
	var trustEvaluationError: Error?
}
