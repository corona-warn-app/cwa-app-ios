//
// 🦠 Corona-Warn-App
//

import Foundation

public enum RuleValidationError: Error {
    case ONBOARDED_COUNTRIES_SERVER_ERROR
    case RULE_JSON_EXTRACTION_FAILED(Error?)
    case CBOR_DECODING_FAILED(Error?)
}
