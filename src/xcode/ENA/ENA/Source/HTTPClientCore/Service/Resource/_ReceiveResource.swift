//
// 🦠 Corona-Warn-App
//

import HealthCertificateToolkit
import Foundation
/**
 Errors for decoding cases when we get a specialized error from the decoding
 */
enum ModelDecodingError: Error {
	case STRING_DECODING
	case PROTOBUF_DECODING(Error)
	case JSON_DECODING(Error)
	case CBOR_DECODING
	case CBOR_DECODING_VALIDATION_RULES(RuleValidationError)
	case CBOR_DECODING_ONBOARDED_COUNTRIES(RuleValidationError)
	case CBOR_DECODING_CLLCONFIGURATION(CCLConfigurationAccessError)
}

/**
A ReceiveResource knows how to decode the data of the http response body. At the end, we receive a concrete object (for example an JSON Object or a protbuf).
The resource only knows of which type ReceiveModel is and implements the concrete encode function to get at the end a concrete object of the http response body's data.
*/
protocol ReceiveResource {
	associatedtype ReceiveModel
	func decode(_ data: Data?, headers: [AnyHashable: Any]) -> Result<ReceiveModel, ResourceError>
}
