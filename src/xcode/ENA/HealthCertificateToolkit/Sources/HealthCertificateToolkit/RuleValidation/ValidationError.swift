//
// 🦠 Corona-Warn-App
//

import Foundation

public enum RuleValidationError: Error {
    case CBOR_DECODING_FAILED(Error?)
    case JSON_ENCODING_FAILED(Error?)
    case JSON_VALIDATION_RULE_SCHEMA_NOTFOUND
}

public enum BoosterNotificationRuleValidationError: Error {
    case CBOR_DECODING_FAILED(Error?)
    case JSON_ENCODING_FAILED(Error?)
    case JSON_VALIDATION_RULE_SCHEMA_NOTFOUND
    case NO_VACCINATION_CERTIFICATE
    case NO_PASSED_RESULT
}
