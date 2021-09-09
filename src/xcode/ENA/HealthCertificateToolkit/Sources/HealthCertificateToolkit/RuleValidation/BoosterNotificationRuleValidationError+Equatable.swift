//
// 🦠 Corona-Warn-App
//

import Foundation

public enum BoosterNotificationRuleValidationError: Error {
    case CBOR_DECODING_FAILED(Error?)
    case JSON_ENCODING_FAILED(Error?)
    case JSON_VALIDATION_RULE_SCHEMA_NOTFOUND
    case NO_VACCINATION_CERTIFICATE
    case NO_PASSED_RESULT
}

extension BoosterNotificationRuleValidationError: Equatable {
    public static func == (lhs: BoosterNotificationRuleValidationError, rhs: BoosterNotificationRuleValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.CBOR_DECODING_FAILED(let lhsError), .CBOR_DECODING_FAILED(let rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.JSON_ENCODING_FAILED(let lhsError), .JSON_ENCODING_FAILED(let rhsError)):
            return lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND):
            return true
        case (.NO_VACCINATION_CERTIFICATE, .NO_VACCINATION_CERTIFICATE):
            return true
        case (.NO_PASSED_RESULT, .NO_PASSED_RESULT):
            return true
        default:
            return false
        }
    }
}
