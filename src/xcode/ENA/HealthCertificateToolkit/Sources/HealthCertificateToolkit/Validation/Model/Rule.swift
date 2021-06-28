//
// 🦠 Corona-Warn-App
//

import Foundation

public struct Rule: Codable, Equatable {
    public var identifier: String
    public var type: String
    public var country: String
    public var version: String
    public var schemaVersion: String
    public var engine: String
    public var engineVersion: String
    public var certificateType: String
    public var description: [RuleDescription]
    public var validFrom: String
    public var validTo: String
    public var affectedFields: [String]
    public var logic: String
}

public struct RuleDescription: Codable, Equatable {
    public var lang: String
    public var desc: String
}

public extension Rule {

    static func fake(
        identifier: String = "GR-CZ-0001",
        type: String = "Acceptance",
        country: String = "CZ",
        version: String = "1.0.0",
        schemaVersion: String = "1.0.0",
        engine: String = "CERTLOGIC",
        engineVersion: String = "1.0.0",
        certificateType: String = "Test",
        description: [RuleDescription] = [.fake()],
        validFrom: String = "2021-05-27T07:46:40Z",
        validTo: String = "2021-06-01T07:46:40Z",
        affectedFields: [String] = ["dn", "sd"],
        logic: String = ""
    ) -> Rule {
        Rule(identifier: identifier, type: type, country: country, version: version, schemaVersion: schemaVersion, engine: engine, engineVersion: engineVersion, certificateType: certificateType, description: description, validFrom: validFrom, validTo: validTo, affectedFields: affectedFields, logic: logic)
    }
}

public extension RuleDescription {

    static func fake(
        lang: String = "lang",
        desc: String = "desc"
    ) -> RuleDescription {
        Description(lang: lang, desc: desc)
    }
}
