//
// 🦠 Corona-Warn-App
//

import jsonfunctions
import Foundation
import SwiftCBOR

extension CCLConfiguration.Logic {
    
    public static func fake(
        jfnDescriptors: [JsonFunctionDescriptor] = []
    ) -> CCLConfiguration.Logic {
       return CCLConfiguration.Logic(jfnDescriptors: jfnDescriptors)
    }
}

extension CCLConfiguration {
    
    public static func fake(
        identifier: String = "identifier",
        type: String = "type",
        country: String = "country",
        version: String = "1.0.0",
        schemaVersion: String = "1.0.0",
        engine: String = "Engine",
        engineVersion: String = "1.0.0",
        validFrom: String = "2021-05-27T07:46:40Z",
        validTo: String = "2021-06-01T07:46:40Z",
        logic: Logic = Logic.fake()
    ) -> CCLConfiguration {
        
        return CCLConfiguration(
            identifier: identifier,
            type: type,
            country: country,
            version: version,
            schemaVersion: schemaVersion,
            engine: engine,
            engineVersion: engineVersion,
            validFrom: validFrom,
            validTo: validTo,
            logic: logic
        )
    }
}

public func CCLConfigurationCBORDataFake(
    configs: [CCLConfiguration] = [.fake(), .fake(), .fake(), .fake()]
) throws -> Data {
    return try CodableCBOREncoder().encode(configs)
}

public func CCLConfigurationCBORDataFake_corrupt() throws -> Data {
    let configs = [
        CBOR.null,
        CBOR.unsignedInt(42)
        ]
    return Data(configs.encode())
}
