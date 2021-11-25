//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

// | Attribute | Type | Description |
// |---|---|---|
// | `id` | string | Identifier of the service identity document |
// | `verificationMethod` | array | An array of Verification Method objects (see below.) |
// | `service` | array<br />(optional) | An array of Service objects (see below.) As this parameter is optional, it may be defaulted to an empty array. |

struct TicketValidationServiceIdentityDocument: Codable {
	let id: String
	let verificationMethod: [TicketValidationVerificationMethod]
	let service: [TicketValidationServiceData]?
}


//  | Attribute | Type | Description |
// |---|---|---|
// | `id` | string | Identifier of the service identity document |
// | `type` | string | Type of the verification method |
// | `controller` | string | Controller of the verification method |
// | `publicKeyJwk` | object<br />(optional) | A JWK (see [Data Structure of a JSON Web Key (JWK)]) |
// | `verificationMethods` | string[]<br />(optional) | An array of strings referencing `id` attributes of other verification methods. As this parameter is optional, it may be defaulted to an empty array. |

struct TicketValidationVerificationMethod: Codable {
	let id: String
	let type: String
	let controller: String
    let publicKeyJwk: JSONWebKey?
	let verificationMethods: [String]?
}

// | Attribute | Type | Description |
// |---|---|---|
// | `id` | string | Identifier of the service identity document |
// | `type` | string | Type of the verification method |
// | `serviceEndpoint` | string/url | URL to the service endpoint |
// | `name` | string | Name of the service |

struct TicketValidationServiceData: Codable {
	let id: String
	let type: String
	let serviceEndpoint: String
	let name: String
}
