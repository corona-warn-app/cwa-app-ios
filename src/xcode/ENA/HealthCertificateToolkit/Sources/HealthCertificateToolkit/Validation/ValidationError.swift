//
// 🦠 Corona-Warn-App
//

import Foundation

enum RuleValidationError: Error {
    case ONBOARDED_COUNTRIES_SERVER_ERROR
    case HC_CBOR_DECODING_FAILED(Error?)
}
