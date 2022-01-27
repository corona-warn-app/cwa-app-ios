//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

public enum CCLConfigurationAccessError: Error {
    case CBOR_DECODING_FAILED(Error?)
    case JSON_ENCODING_FAILED(Error?)
}

public struct CCLConfigurationAccess {
    
    public init() {}

    public func extractCCLConfiguration(from cborData: CBORData) -> Result<[CCLConfiguration], CCLConfigurationAccessError> {
        do {
            let cborDecoder = CBORDecoder(input: [UInt8](cborData))
            guard let cbor = try cborDecoder.decodeItem(),
                  case let .array(cborConfigurations) = cbor else {
                return .failure(.CBOR_DECODING_FAILED(nil))
            }

            var configurations = [CCLConfiguration]()
            for configuration in cborConfigurations {
                guard case let .map(configurationMap) = configuration else {
                    return .failure(.CBOR_DECODING_FAILED(nil))
                }
                let configuration = try JSONDecoder().decode(CCLConfiguration.self, from: JSONSerialization.data(withJSONObject: configurationMap.anyMap))
                configurations.append(configuration)
            }
            return .success(configurations)
        } catch {
            return .failure(.CBOR_DECODING_FAILED(error))
        }
    }
}
