//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
@testable import ENA

extension TicketValidationServiceIdentityDocument {
	
	static func fake(
		id: String = "fakeID",
		verificationMethod: [TicketValidationVerificationMethod] = [.fake()],
		service: [TicketValidationServiceData]? = [.fake()]
	) -> TicketValidationServiceIdentityDocument {
		return TicketValidationServiceIdentityDocument(
			id: id,
			verificationMethod: verificationMethod,
			service: service
		)
	}
}

extension TicketValidationVerificationMethod {
	
	static func fake(
		id: String = "someIdWithRegexValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC$",
		type: String = "",
		controller: String = "",
		publicKeyJwk: JSONWebKey? = JSONWebKey.fake(),
		verificationMethods: [String] = ["", ""]
	) -> TicketValidationVerificationMethod {
		return TicketValidationVerificationMethod(
			id: id,
			type: type,
			controller: controller,
			publicKeyJwk: publicKeyJwk,
			verificationMethods: verificationMethods
		)
	}
}

extension TicketValidationServiceData {
	
	static func fake(
		id: String = "",
		type: String = "",
		serviceEndpoint: String = "",
		name: String = ""
	) -> TicketValidationServiceData {
		return TicketValidationServiceData(
			id: id,
			type: type,
			serviceEndpoint: serviceEndpoint,
			name: name
		)
	}
}
