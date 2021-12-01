//
// 🦠 Corona-Warn-App
//

import XCTest
import ENASecurity
@testable import ENA

class ValidationDecoratorServiceTests: XCTestCase {
	
	// Happy scenario success Case
	
	func test_happyScenario_Return_Identity_Document() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake()
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
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
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(verificationMethod: [
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
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_EMPTY_X5C, "An error should occur due to empty x5c array")
			}
		}
	}
	
	func test_If_AccessTokenService_Not_Found_Then_Abort() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(service: [
			ValidationDecoratorServiceModel(
				id: "test",
				type: "CancellationService",
				serviceEndpoint: "test",
				name: "test"
			),
			ValidationDecoratorServiceModel(
				id: "test",
				type: "ValidationService",
				serviceEndpoint: "test",
				name: "test"
			)
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_NO_ATS, "An error should occur due to not finding the accessTokenService")
			}
		}
	}
	
	func test_If_ValidationService_Not_Found_Then_Abort() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(service: [
			ValidationDecoratorServiceModel(
				id: "test",
				type: "CancellationService",
				serviceEndpoint: "test",
				name: "test"
			),
			ValidationDecoratorServiceModel(
				id: "test",
				type: "AccessTokenService",
				serviceEndpoint: "test",
				name: "test"
			)
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_NO_VS, "An error should occur due to not finding the accessTokenService")
			}
		}
	}
	
	func test_If_AccessTokenSignJwkSet_Not_Found_Then_Abort() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(verificationMethod: [
			VerificationMethod(
				id: "https://test.com/AccessTokenServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/AccessTokenServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/ValidationServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			)
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_NO_ATS_SIGN_KEY, "An error should occur due to not finding the accessTokenSignJwkSet")
			}
		}
	}
	
	func test_If_AccessTokenServiceJwkSet_Not_Found_Then_Abort() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(verificationMethod: [
			VerificationMethod(
				id: "https://test.com/AccessTokenSignKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/wrongPath",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/ValidationServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			)
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_NO_ATS_SVC_KEY, "An error should occur due to not finding the AccessTokenServiceJwkSet")
			}
		}
	}
	
	func test_If_ValidationServiceJwkSet_Not_Found_Then_Abort() {
		let decoratorService = TVDecoratorIdentityDocumentProcessor()
		let serviceIdentityDocument = ServiceIdentityDocument.fake(verificationMethod: [
			VerificationMethod(
				id: "https://test.com/AccessTokenSignKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/AccessTokenServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/wrongPath",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			)
		])
		decoratorService.validateIdentityDocument(serviceIdentityDocument: serviceIdentityDocument) { result in
			switch result {
			case .success:
				XCTFail("expected test to fail")
			case .failure(let error):
				XCTAssertEqual(error, .VD_ID_NO_VS_SVC_KEY, "An error should occur due to not finding the ValidationServiceJwkSet")
			}
		}
	}
	
}
