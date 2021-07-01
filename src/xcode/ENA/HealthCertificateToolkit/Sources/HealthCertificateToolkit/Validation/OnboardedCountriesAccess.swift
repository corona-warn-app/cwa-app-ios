//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

public struct OnboardedCountriesAccess {

    public func extractCountryCodes(from cborData: CBORData) -> Result<[String], RuleValidationError> {
        do {
            let countryCodes = try CodableCBORDecoder().decode([String].self, from: cborData)
            return .success(countryCodes)
        } catch {
            return .failure(.CBOR_DECODING_FAILED(error))
        }
    }
}
