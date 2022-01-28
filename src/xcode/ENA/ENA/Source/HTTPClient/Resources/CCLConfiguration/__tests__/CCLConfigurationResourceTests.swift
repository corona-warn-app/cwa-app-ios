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

		let restServiceProvider = RestServiceProvider(session: stack.urlSession)
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
	
	
}
