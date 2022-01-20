//
// 🦠 Corona-Warn-App
//

import CertLogic
import SwiftyJSON
import Foundation
import SwiftCBOR

public extension Rule {

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
        affectedString: [String] = ["v.0.dn", "v.0.sd"],
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

public extension ValidationResult {
    
    static func fake(
        rule: Rule = Rule.fake(),
        result: CertLogic.Result = .passed,
        validationErrors: [Error] = []
    ) -> ValidationResult {
        ValidationResult(rule: rule, result: result, validationErrors: validationErrors)
    }
}

public var onboardedCountriesCBORDataFake_DE_FR: Data {
    let cborCountries = CBOR.array(
        [
            CBOR.utf8String("DE"),
            CBOR.utf8String("FR")
        ]
    )
    return Data(cborCountries.encode())
}

public var onboardedCountriesCBORDataFake_IT_UK: Data {
    let cborCountries = CBOR.array(
        [
            CBOR.utf8String("IT"),
            CBOR.utf8String("UK")
        ]
    )
    return Data(cborCountries.encode())
}

public var onboardedCountriesCBORDataFake_Corrupt: Data {
    let cborCountries = CBOR.array(
        [
            CBOR.null,
            CBOR.unsignedInt(42)
        ]
    )
    return Data(cborCountries.encode())
}

public func rulesCBORDataFake_corrupt() throws -> Data {
    let rules = CBOR.array(
        [
            CBOR.null,
            CBOR.unsignedInt(42)
        ]
    )
    return Data(rules.encode())
}

public func rulesCBORDataFake() throws -> Data {
    let rules = [
        Rule.fake(),
        Rule.fake(),
        Rule.fake()
    ]

    return try CodableCBOREncoder().encode(rules)
}

public func rulesCBORDataFake2() throws -> Data {
    let rules = [
        Rule.fake(
            identifier: "GR-CZ-0002",
            type: "Acceptance",
            version: "1.0.0",
            schemaVersion: "1.0.0",
            engine: "CERTLOGIC",
            engineVersion: "1.0.0",
            certificateType: "Test",
            description: [.fake()],
            validFrom: "2021-05-27T07:46:40Z",
            validTo: "2021-06-01T07:46:40Z",
            affectedString: ["v.0.dn", "v.0.sd"],
            logic: JSON(""),
            countryCode: "DE",
            region: nil,
            hash: nil
        ),
        Rule.fake(),
        Rule.fake()
    ]

    return try CodableCBOREncoder().encode(rules)
}
