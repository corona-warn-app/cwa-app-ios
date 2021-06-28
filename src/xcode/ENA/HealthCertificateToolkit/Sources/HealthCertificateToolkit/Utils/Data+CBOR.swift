//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

extension CBORData {

    func decodeToCBOR() -> Result<CBOR, RuleValidationError> {
        do {
            let cborDecoder = CBORDecoder(input: [UInt8](self))
            guard let cbor = try cborDecoder.decodeItem() else {
                return .failure(.HC_CBOR_DECODING_FAILED(nil))
            }
            return .success(cbor)
        } catch {
            return .failure(.HC_CBOR_DECODING_FAILED(error))
        }
    }
}
