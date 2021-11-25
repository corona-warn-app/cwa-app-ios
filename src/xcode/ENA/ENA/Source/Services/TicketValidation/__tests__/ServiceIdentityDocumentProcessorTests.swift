//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest

class ServiceIdentityDocumentProcessorTests: XCTestCase {
    
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_HappyPath_THEN_Success() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_JwkSetIsNotAvailable_THEN_VS_ID_EMPTY_X5C_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoEncryptionKeysFound_THEN_VS_ID_NO_ENC_KEY_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoSigningKeyFound_THEN_VS_ID_NO_SIGN_KEY_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_DecodingFails_THEN_VS_ID_PARSE_ERR_ERROR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_NetworkFails_THEN_VS_ID_NO_NETWORK() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_ClientFails_THEN_VS_ID_CLIENT_ERR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_ServerFails_THEN_VS_ID_SERVER_ERR() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_DynmaicPinningNoJwkFound_THEN_VS_ID_CERT_PIN_NO_JWK_FOR_KID() throws {
	
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Loading_DynamicPinningCertificateMismatches_THEN_VS_ID_CERT_PIN_MISMATCH() throws {
	
	}
}
