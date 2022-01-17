////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import HealthCertificateToolkit
import ZIPFoundation

final class DCCRulesResourceTests: CWATestCase {

	/// Successful loading cases

	func testGIVEN_Resource_WHEN_Response_200_THEN_PackageIsReturned() throws {
		// GIVEN
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.rulesCBORDataFake()
		))

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["eTag": "\"SomeEtag\""],
			responseData: archiveData
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		var dccRulesResource = DCCRulesResource(ruleType: .acceptance)
		dccRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		// WHEN
		restServiceProvider.load(dccRulesResource) { result in
			switch result {
			case let .success(validationRules):
				// CBOR rulesCBORDataFake contains 3 rules
				XCTAssertEqual(validationRules.rules.count, 3)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_Resource_WHEN_notModified_304_THEN_CachedPackageIsReturned() throws {
		// GIVEN
		let archiveDataCache = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.rulesCBORDataFake2()
		))

		let expectation = expectation(description: "completion handler succeeds")
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: ["eTag": eTag]
		)

		var resource = DCCRulesResource(ruleType: .acceptance)
		resource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(
			data: archiveDataCache,
			eTag: eTag,
			date: Date()
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(validationRules):
				XCTAssertEqual(validationRules.rules.count, 3)
				guard let firstRule = validationRules.rules.first else {
					XCTFail("Missing first rule")
					return
				}
				XCTAssertEqual(firstRule.identifier, "GR-CZ-0002")
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	/// Failure cases

	func testGIVEN_Resource_WHEN_Corrupt_Response_200_THEN_CBOR_DECODING_FAILED() throws {
		// GIVEN
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.rulesCBORDataFake_corrupt()
		))

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)

		let expectation = self.expectation(description: "completion handler successful")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		var dccRulesResource = DCCRulesResource(ruleType: .acceptance)
		dccRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		// WHEN
		restServiceProvider.load(dccRulesResource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				// Successful test if we can unpack the error to an .ONBOARDED_COUNTRIES_DECODING_ERROR containing a .CBOR_DECODING_FAILED error.
				guard case let .receivedResourceError(customError) = error,
					  case let .RULE_DECODING_ERROR(.acceptance, decodingError) = customError,
					  case .CBOR_DECODING_FAILED = decodingError else {
						  XCTFail("Received wrong error type")
						  return
				}
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_Resource_WHEN_emptyResponse_404_THEN_RULE_CLIENT_ERROR() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 404
		)
		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = DCCRulesResource(isFake: false, ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_CLIENT_ERROR(.acceptance) ))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_200_THEN_RULE_JSON_ARCHIVE_ETAG_ERROR() throws {
		// GIVEN
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.rulesCBORDataFake()
		))

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)

		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		var dccRulesResource = DCCRulesResource(ruleType: .acceptance)
		dccRulesResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		// WHEN
		restServiceProvider.load(dccRulesResource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_JSON_ARCHIVE_ETAG_ERROR(.acceptance)))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_Resource_WHEN_emptyResponse_200_THEN_RULE_JSON_ARCHIVE_FILE_MISSING() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200
		)
		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = DCCRulesResource(isFake: false, ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_JSON_ARCHIVE_FILE_MISSING(.acceptance)))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_Response_200_THEN_RULE_JSON_ARCHIVE_SIGNATURE_INVALID() throws {
		// GIVEN
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.rulesCBORDataFake()
		))

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["eTag": "\"SomeEtag\""],
			responseData: archiveData
		)

		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let dccRulesResource = DCCRulesResource(ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(dccRulesResource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_JSON_ARCHIVE_SIGNATURE_INVALID(.acceptance)))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_Resource_WHEN_NotModified_304_THEN_RULE_MISSING_CACHE() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 304
		)
		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = DCCRulesResource(isFake: false, ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_MISSING_CACHE(.acceptance) ))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_emptyResponse_500_THEN_RULE_SERVER_ERROR() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 500
		)
		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = DCCRulesResource(isFake: false, ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.RULE_SERVER_ERROR(.acceptance) ))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Resource_WHEN_NoNetwork_THEN_NO_NETWORK() {
		// GIVEN
		let fakedError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let stack = MockNetworkStack(
			error: fakedError
		)
		let expectation = self.expectation(description: "completion handler fails")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
		let resource = DCCRulesResource(isFake: false, ruleType: .acceptance)

		// WHEN
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				XCTAssertEqual(error, .receivedResourceError(.NO_NETWORK))
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	// ToDO Missing cases:
	// TECHNICAL_VALIDATION_FAILED
	// VALUE_SET_SERVER_ERROR
	// VALUE_SET_CLIENT_ERROR
	// RULES_VALIDATION_ERROR

}
