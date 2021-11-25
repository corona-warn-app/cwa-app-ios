//
// 🦠 Corona-Warn-App
//

import XCTest
import ENASecurity
@testable import ENA

class ValidationDecoratorServiceTests: XCTestCase {

	// Happy scenario success Case
	
	func test_happyScenario_Return_Identity_Document() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(ServiceIdentityDocument.fake())
		])
		let decoratorService = ValidationDecoratorService(restServiceProvider: restServiceProvider)
		
		decoratorService.requestIdentityDocumentOfTheValidationDecorator(urlString: "test") { result in
			switch result {
			case .success(let identityDocument):
				XCTAssertEqual(identityDocument.accessTokenService.id, "test")
			case .failure(let error):
				XCTFail("expected test to succeeds" + error.localizedDescription)
			}
		}
	}
	
	// Validation Failure Cases

	func test_If_Verification_Of_JWKs_Fails_Then_Abort() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(ServiceIdentityDocument.fake(verificationMethod: [
				VerificationMethod(
					id: "https://test.com/AccessTokenSignKey-1",
					type: "JsonWebKey2020",
					controller: "https://test.com/api/identity",
					publicKeyJwk: JSONWebKey.fake(x5c: [], kid: "test", alg: "test", use: "test"),
					verificationMethods: nil
				),
				VerificationMethod(
					id: "https://test.com/AccessTokenServiceKey-1",
					type: "JsonWebKey2020",
					controller: "https://test.com/api/identity",
					publicKeyJwk: JSONWebKey.fake(),
					verificationMethods: nil
				)
			]))
		])
		let decoratorService = ValidationDecoratorService(restServiceProvider: restServiceProvider)
		
		decoratorService.requestIdentityDocumentOfTheValidationDecorator(urlString: "test") { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_EMPTY_X5C, "An error should occur due to empty x5c array")
			}
		}
	}
}
