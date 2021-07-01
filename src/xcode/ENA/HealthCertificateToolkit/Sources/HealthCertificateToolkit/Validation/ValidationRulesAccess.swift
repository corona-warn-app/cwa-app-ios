//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import CertLogic

public struct ValidationRulesAccess {

    public init() {}

    public func extractValidationRules(from cborData: CBORData) -> Swift.Result<[Rule], RuleValidationError> {
        do {
            let rules = try CodableCBORDecoder().decode([Rule].self, from: cborData)
            return .success(rules)
        } catch {
            return .failure(.CBOR_DECODING_FAILED(error))
        }
    }
}
