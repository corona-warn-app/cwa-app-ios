//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct ServiceIdentityDocument: Codable {
	let id: String
	let verificationMethod: [VerificationMethod]
	let service: [ValidationDecoratorServiceModel]?
	
	public static func fake(
		id: String = "fake",
		verificationMethod: [VerificationMethod] = [
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
				id: "https://test.com/ServiceProviderKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/CancellationServiceKey-1",
				type: "JsonWebKey2020",
				controller: "https://test.com/api/identity",
				publicKeyJwk: JSONWebKey.fake(),
				verificationMethods: nil
			),
			VerificationMethod(
				id: "https://test.com/StatusServiceKey-1",
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
		],
		service: [DecoratorServiceModel]? = [
			DecoratorServiceModel(
				id: "test",
				type: "CancellationService",
				serviceEndpoint: "test",
				name: "test"
			),
			DecoratorServiceModel(
				id: "test",
				type: "ValidationService",
				serviceEndpoint: "test",
				name: "test"
			),
			DecoratorServiceModel(
				id: "test",
				type: "AccessTokenService",
				serviceEndpoint: "test",
				name: "test"
			)
		]
	) -> ServiceIdentityDocument {
		ServiceIdentityDocument(id: id, verificationMethod: verificationMethod, service: service)
	}
}
