//
// 🦠 Corona-Warn-App
//

import jsonfunctions

extension CCLConfiguration.Logic {
    
    static func fake(
        jfnDescriptors: [JsonFunctionDefinition] = []
    ) -> CCLConfiguration.Logic {
       return CCLConfiguration.Logic(jfnDescriptors: jfnDescriptors)
    }
}

extension CCLConfiguration {
    
    static func fake(
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
