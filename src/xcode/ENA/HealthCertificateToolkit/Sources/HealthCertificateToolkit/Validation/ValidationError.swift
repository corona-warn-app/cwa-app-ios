//
// 🦠 Corona-Warn-App
//

import Foundation

public enum RuleValidationError: Error {
    case CBOR_DECODING_FAILED(Error?)
    case JSON_ENCODING_FAILED(Error?)
    case JSON_VALIDATION_RULE_SCHEMA_NOTFOUND
}

extension RuleValidationError: Equatable {
    public static func == (lhs: RuleValidationError, rhs: RuleValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.CBOR_DECODING_FAILED, .CBOR_DECODING_FAILED):
            return true
        case (.JSON_ENCODING_FAILED, .JSON_ENCODING_FAILED):
            return true
        case (.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND):
            return true
        default:
            return false
        }
    }
}
