//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

// The Transaction Context is a data structure that describes the different attributes that processed by the individual [Process Flow] steps and has the following attributes:
//
// | Attribute | Type | Description |
// |---|---|---|
// | `initializationData` | object | The Initialization Data as per [Data Structure of the Initialization Data] |
// | `accessTokenService` | Service | The service object for the Access Token Service (as per [Data Structure of a Service]) |
// | `accessTokenServiceJwkSet` | JWK[] | The set of JWKs for checking the server certificate of the Access Token Service (as per [Data Structure of a JSON Web Key (JWK)] |
// | `accessTokenSignJwkSet` | JWK[] | The set of JWKs for verifying the signature of JWTs from the Access Token Service (as per [Data Structure of a JSON Web Key (JWK)] |
// | `validationService` | Service | The service object of the Validation Service (as per [Data Structure of a Service]) |
// | `validationServiceJwkSet` | JWK[] | The set of JWKs for checking the server certificate of the Validation Service (as per [Data Structure of a JSON Web Key (JWK)] |
// | `validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC` | JWK[] | The set of JWKs that can be used for encrypting data with RSAOAEPWithSHA256AESCBC (as per [Data Structure of a JSON Web Key (JWK)]) |
// | `validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM` | JWK[] | The set of JWKs that can be used for encrypting data with RSAOAEPWithSHA256AESGCM (as per [Data Structure of a JSON Web Key (JWK)]) |
// | `validationServiceSignKeyJwkSet` | JWK[] | The set of JWKs for verifying the signature of JWTs from the Verification Service (as per [Data Structure of a JSON Web Key (JWK)]) |
// | `ecPublicKey` | Public Key | The (EC) Public Key of the locally generated key pair. |
// | `ecPrivateKey` | Private Key | The (EC) Private Key of the locally generated key pair. |
// | `ecPublicKeyBase64` | string | The base64-encoded string representation of `ecPublicKey` (ready for transport to the Access Token Service). |
// | `accessToken` | string | The string representation of the JWT token from the Access Token Service. |
// | `accessTokenPayload` | object | The payload of the Access Token (as per [Data Structure of the Access Token]) |
// | `nonceBase64` | string | A base64-encoded string with a nonce from the Access Token Service. |
// | `dccBarcodeData` | string | The selected DCC represented as string for the QR code (i.e. starting with `HC1:...`) |
// | `encryptedDCCBase64` | string | The base64-encoded encrypted DCC |
// | `encryptionKeyBase64` | string | The base64-encoded encryption key |
// | `signatureBase64` | string | The base64-encoded signature |
// | `signatureAlgorithm` | string | The signature algorithm |
// | `resultToken` | string | The string representation of the JWT token from the Validation Service. |
// | `resultTokenPayload` | object | The payload of the Result Token (as per [Data Structure of the Result Token]) |

struct TicketValidationTransactionContext {
	
	let initializationData: TicketValidationInitializationData
	let accessTokenService: TicketValidationValidationServiceData
	let accessTokenServiceJwkSet: [JSONWebKey]
	let accessTokenSignJwkSet: [JSONWebKey]
	let validationService: TicketValidationValidationServiceData
	let validationServiceJwkSet: [JSONWebKey]
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: [JSONWebKey]
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: [JSONWebKey]
	let validationServiceSignKeyJwkSet: [JSONWebKey]
	let ecPublicKey: Data
	let ecPrivateKey: Data
	let ecPublicKeyBase64: String
	let accessToken: String
	let accessTokenPayload: TicketValidationAccessToken
	let nonceBase64: String
	let dccBarcodeData: String
	let encryptedDCCBase64: String
	let encryptionKeyBase64: String
	let signatureBase64: String
	let signatureAlgorithm: String
	let resultToken: String
	let resultTokenPayload: TicketValidationResult
}
