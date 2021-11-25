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
		let expectedResult1 = ["Should be contained in the result, Part 1"]
		let expectedResult2 = ["Should be contained in the result, Part 2"]
		let serviceIdentityDocumentProcessor = TVServiceIdentityDocumentProcessor()
		let validationServiceJwkSet = JSONWebKey.fake()
		let serviceIdentityDocument = TicketValidationServiceIdentityDocument.fake(
			id: "sidID",
			verificationMethod: [
				.fake(
					id: "someIdWithRegexValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC",
					publicKeyJwk: .fake(x5c: expectedResult1),
					verificationMethods: ["someIdWithRegexValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC", "wrongVerificationMethod"]
				),
				.fake(
					id: "someOtherIdWithRegexValidationServiceSignKey-090909",
					publicKeyJwk: .fake(x5c: expectedResult2),
					verificationMethods: ["should not be important for this test"]
				)
			]
		)
		
		// WHEN
		serviceIdentityDocumentProcessor.process(
			validationServiceJwkSet: [validationServiceJwkSet],
			serviceIdentityDocument: serviceIdentityDocument,
			completion: { result in
				switch result {
				case let .success(serviceIdentityRequestResult):
					// THEN
					XCTAssertNotNil(serviceIdentityRequestResult)
					XCTAssertEqual(serviceIdentityRequestResult.validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC.count, 1)
					XCTAssertEqual(serviceIdentityRequestResult.validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC.first?.x5c, expectedResult1)
					XCTAssertTrue(serviceIdentityRequestResult.validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM.isEmpty)
					XCTAssertEqual(serviceIdentityRequestResult.validationServiceSignKeyJwkSet.count, 1)
					XCTAssertEqual(serviceIdentityRequestResult.validationServiceSignKeyJwkSet.first?.x5c, expectedResult2)
				case let .failure(error):
					XCTFail("Test should not fail with error: \(error)")
				}
			}
		)
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_JwkSetIsNotAvailable_THEN_VS_ID_EMPTY_X5C_ERROR() throws {
		// GIVEN
		let serviceIdentityDocumentProcessor = TVServiceIdentityDocumentProcessor()
		let validationServiceJwkSet = JSONWebKey.fake()
		let serviceIdentityDocument = TicketValidationServiceIdentityDocument.fake(
			verificationMethod: [
				.fake(
					publicKeyJwk: .fake(x5c: [])
				)
			]
		)
		
		// WHEN
		serviceIdentityDocumentProcessor.process(
			validationServiceJwkSet: [validationServiceJwkSet],
			serviceIdentityDocument: serviceIdentityDocument,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Failure expected.")
				case let .failure(error):
					guard case .VS_ID_EMPTY_X5C = error else {
						XCTFail("VS_ID_EMPTY_X5C error expected. Instead this error received: \(error)")
						return
					}
				}
			}
		)
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoEncryptionKeysFound_THEN_VS_ID_NO_ENC_KEY_ERROR() throws {
		// GIVEN
		let serviceIdentityDocumentProcessor = TVServiceIdentityDocumentProcessor()
		let validationServiceJwkSet = JSONWebKey.fake()
		let serviceIdentityDocument = TicketValidationServiceIdentityDocument.fake(
			verificationMethod: []
		)
		
		// WHEN
		serviceIdentityDocumentProcessor.process(
			validationServiceJwkSet: [validationServiceJwkSet],
			serviceIdentityDocument: serviceIdentityDocument,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Failure expected.")
				case let .failure(error):
					guard case .VS_ID_NO_ENC_KEY = error else {
						XCTFail("VS_ID_NO_ENC_KEY error expected. Instead this error received: \(error)")
						return
					}
				}
			}
		)
	}
	
	func testGIVEN_ServiceIdentityDocumentProcessor_WHEN_Processing_NoSigningKeyFound_THEN_VS_ID_NO_SIGN_KEY_ERROR() throws {
		// GIVEN
		let serviceIdentityDocumentProcessor = TVServiceIdentityDocumentProcessor()
		let validationServiceJwkSet = JSONWebKey.fake()
		let serviceIdentityDocument = TicketValidationServiceIdentityDocument.fake(
			id: "sidID",
			verificationMethod: [
				.fake(
					id: "someIdWithRegexValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC",
					verificationMethods: ["someIdWithRegexValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC", "wrongVerificationMethod"]
				)
			]
		)
		
		// WHEN
		serviceIdentityDocumentProcessor.process(
			validationServiceJwkSet: [validationServiceJwkSet],
			serviceIdentityDocument: serviceIdentityDocument,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Failure expected.")
				case let .failure(error):
					guard case .VS_ID_NO_SIGN_KEY = error else {
						XCTFail("VS_ID_NO_SIGN_KEY error expected. Instead this error received: \(error)")
						return
					}
				}
			}
		)
	}
	

}
