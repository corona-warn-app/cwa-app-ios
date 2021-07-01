//
// 🦠 Corona-Warn-App
//

import Foundation

public enum RuleValidationError: Error {
    case CBOR_DECODING_FAILED(Error?)
}
