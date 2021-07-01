//
// 🦠 Corona-Warn-App
//

import CertLogic
import SwiftyJSON

extension Rule {

    static func fake(
        identifier: String = "GR-CZ-0001",
        type: String = "Acceptance",
        version: String = "1.0.0",
        schemaVersion: String = "1.0.0",
        engine: String = "CERTLOGIC",
        engineVersion: String = "1.0.0",
        certificateType: String = "Test",
        description: [Description] = [.fake()],
        validFrom: String = "2021-05-27T07:46:40Z",
        validTo: String = "2021-06-01T07:46:40Z",
        affectedString: [String] = ["dn", "sd"],
        logic: JSON = JSON(""),
        countryCode: String = "CZ",
        region: String? = nil,
        hash: String? = nil
    ) -> Rule {
        Rule(identifier: identifier, type: type, version: version, schemaVersion: schemaVersion, engine: engine, engineVersion: engineVersion, certificateType: certificateType, description: description, validFrom: validFrom, validTo: validTo, affectedString: affectedString, logic: logic, countryCode: countryCode)
    }
}

public extension Description {

    static func fake(
        lang: String = "lang",
        desc: String = "desc"
    ) -> Description {
        Description(lang: lang, desc: desc)
    }
}
