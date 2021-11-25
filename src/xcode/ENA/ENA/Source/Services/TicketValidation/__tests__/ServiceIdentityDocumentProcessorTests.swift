//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import ENASecurity
@testable import ENA

class ServiceIdentityDocumentProcessorTests: XCTestCase {
    
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_HappyPath_THEN_Success() throws {
		
		// GIVEN
		let serviceIdentityDocumentProcessor = ServiceIdentityDocumentProcessor()
		let validationServiceJwkSet = JSONWebKey.fake()
		let serviceIdentityDocument = ServiceIdentityDocument(id: "", verificationMethod: [], service: nil)
		
		// WHEN
		serviceIdentityDocumentProcessor.process(
			validationServiceJwkSet: [validationServiceJwkSet],
			serviceIdentityDocument: serviceIdentityDocument,
			completion: { result in
				switch result {
				case let .success(serviceIdentityRequestResult):
					// THEN
					XCTAssertNotNil(serviceIdentityRequestResult)
				case let .failure(error):
					XCTFail("Test should not fail with error: \(error)")
				}
			}
		)
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_JwkSetIsNotAvailable_THEN_VS_ID_EMPTY_X5C_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoEncryptionKeysFound_THEN_VS_ID_NO_ENC_KEY_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoSigningKeyFound_THEN_VS_ID_NO_SIGN_KEY_ERROR() throws {
	
	}
	

}
