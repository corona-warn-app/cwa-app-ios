//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import HealthCertificateToolkit
import ZIPFoundation

final class CCLConfigurationResourceTests: CWATestCase {
	
	// MARK: - Success
	
	func testGIVEN_Resource_WHEN_Response_200_THEN_CCLConfigIsReturned() throws {
		// GIVEN
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake()
		))

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["eTag": "\"SomeEtag\""],
			responseData: archiveData
		)

		let expectation = self.expectation(description: "completion handler succeeds")

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		var cclConfigurationResource = CCLConfigurationResource()
		cclConfigurationResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		// We should load fresh configuration
		// WHEN
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(model):
				// CBOR rulesCBORDataFake contains 4 rules
				XCTAssertEqual(model.cclConfigurations.count, 4)
				XCTAssertFalse(model.metaData.loadedFromCache)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_Resource_WHEN_Response_304_THEN_CCLConfigIsReturned() throws {
		// GIVEN
		let expectation = self.expectation(description: "completion handler succeeds")
		let archiveDataCache = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake()
		))
		
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: ["eTag": eTag]
		)

		var cclConfigurationResource = CCLConfigurationResource()
		cclConfigurationResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())

		let cache = KeyValueCacheFake()
		cache[cclConfigurationResource.locator.uniqueIdentifier] = CacheData(
			data: archiveDataCache,
			eTag: eTag,
			date: Date()
		)
		
		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// We should load cached configuration
		// WHEN
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(model):
				// CBOR rulesCBORDataFake contains 4 rules
				XCTAssertEqual(model.cclConfigurations.count, 4)
				XCTAssertTrue(model.metaData.loadedFromCache)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_Resource_WHEN_Response_404_THEN_CCLConfigIsReturned() throws {
		// GIVEN
		let expectation = self.expectation(description: "completion handler succeeds")
		
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: ["eTag": eTag]
		)
		var cclConfigurationResource = CCLConfigurationResource()
		cclConfigurationResource.receiveResource = CBORReceiveResource(signatureVerifier: MockVerifier())
		
		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)
		
		// We should load default configuration
		// WHEN
		restServiceProvider.load(cclConfigurationResource) { result in
			switch result {
			case let .success(model):
				// CBOR default model contains one cclConfiguration
				XCTAssertEqual(model.cclConfigurations.count, 1)
				XCTAssertFalse(model.metaData.loadedFromCache)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
			
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	// We ensure with this test that the default model file is working. This code is duplicated from the CCLConfigurationResource because there is no other way to test it.
	func testGIVEN_DefaultModel_WHEN_Decoding_THEN_CCLConfigIsReturned() throws {
		// GIVEN
		let expectation = self.expectation(description: "completion handler succeeds")

		guard let url = Bundle.main.url(forResource: "ccl-configuration", withExtension: "bin"),
			  let fallbackBin = try? Data(contentsOf: url) else {
				  XCTFail("Creating the default model failed due to loading default bin from disc")
				  return
			  }
		
		// WHEN
		switch CCLConfigurationReceiveModel.make(with: fallbackBin) {
		case .success(let model):
			XCTAssertEqual(model.cclConfigurations.count, 1)
		case .failure(let error):
			XCTFail("Test should not fail with error: \(error)")
		}
		expectation.fulfill()
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	// MARK: - Failures
		
	func testGIVEN_DefaultModel_WHEN_Decoding_THEN_CCLConfigurationAccessErrorCBOR_DECODING_FAILED() throws {
		// GIVEN
		let expectation = self.expectation(description: "completion handler fails")

		let corruptData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.CCLConfigurationCBORDataFake_corrupt()
		))
		
		// WHEN
		switch CCLConfigurationReceiveModel.make(with: corruptData) {
		case .success:
			XCTFail("Test should not succeed.")
		case let .failure(error):
			// Successful test if we can unpack the error to an CCLConfigurationAccessError.CBOR_DECODING_FAILED containing some error we are not interested in.
			guard case let .CBOR_DECODING_CLLCONFIGURATION(accessError) = error,
				  case CCLConfigurationAccessError.CBOR_DECODING_FAILED = accessError else {
					  XCTFail("Received wrong error type")
					  return
				  }
		}
		expectation.fulfill()
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	// Any other error cases do not exist because we always return a config - either the cached one or the default one. If CBOR Decoding will fail for the fresh one, we will return the default one.
}
