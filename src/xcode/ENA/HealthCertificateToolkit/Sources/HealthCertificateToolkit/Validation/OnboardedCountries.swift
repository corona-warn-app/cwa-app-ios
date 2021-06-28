//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

struct OnboardedCountries {

    let countryCodes: [String]

    init(cborData: CBORData) throws {
        let result =
            cborData.decodeToCBOR()
            .flatMap { $0.extractCountryCodes() }

        switch result {
        case .success(let countryCodes):
            self.countryCodes = countryCodes
        case .failure(let error):
            throw error
        }
    }
}

fileprivate extension CBOR {

    func extractCountryCodes() -> Result<[String], RuleValidationError> {
        guard case let .array(cborCountries) = self else {
            return .failure(.ONBOARDED_COUNTRIES_SERVER_ERROR)
        }

        let countryCodes = cborCountries.compactMap {
            guard case let .utf8String(countryCode) = $0 else {
                return nil
            }
            return countryCode
        } as [String]

        return .success(countryCodes)
    }
}

fileprivate extension CBORData {

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

