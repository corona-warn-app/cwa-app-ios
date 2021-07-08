//
// 🦠 Corona-Warn-App
//

import CertLogic
import SwiftyJSON
import Foundation

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

public extension ExternalParameter {

    static func fake(
        validationClock: Date = Date(),
        valueSets: [String: [String]] = [:],
        exp: Date = Date(),
        iat: Date = Date(),
        issuerCountryCode: String = "DE",
        kid: String? = nil
    ) -> ExternalParameter {
        ExternalParameter(validationClock: validationClock, valueSets: valueSets, exp: exp, iat: iat, issuerCountryCode: issuerCountryCode, kid: kid)
    }
}

public extension FilterParameter {

    static func fake(
        validationClock: Date = Date(),
        countryCode: String = "DE",
        certificationType: CertificateType = .vaccination,
        region: String? = nil
    ) -> FilterParameter {
        FilterParameter(validationClock: validationClock, countryCode: countryCode, certificationType: certificationType, region: region)
    }
}
