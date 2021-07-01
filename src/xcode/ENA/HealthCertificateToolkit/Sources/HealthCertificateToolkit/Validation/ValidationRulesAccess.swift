//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import CertLogic

public struct ValidationRulesAccess {

    public init() {}

    public func extractValidationRules(from cborData: CBORData) -> Swift.Result<[Rule], RuleValidationError> {
        do {
            let rules = try CodableCBORDecoder().decode([Rule].self, from: cborData)
            return .success(rules)
        } catch {
            return .failure(.CBOR_DECODING_FAILED(error))
        }
    }

    public func applyValidationRules(_ rules: [Rule], to certificate: DigitalCovidCertificate, externalRules: ExternalParameter) -> Swift.Result<[ValidationResult], RuleValidationError> {
        do {
            let jsonData = try JSONEncoder().encode(certificate)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(.JSON_ENCODING_FAILED(nil))
            }

            guard let schemaURL = Bundle.module.url(forResource: "dcc-validation-rule", withExtension: "json"),
                  let schemaData = FileManager.default.contents(atPath: schemaURL.path),
                  let schemaString = String(data: schemaData, encoding: .utf8) else {
                return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
            }
            
            let certLogicEngine = CertLogicEngine(schema: schemaString, rules: rules)
            return .success(certLogicEngine.validate(external: externalRules, payload: jsonString))
        } catch {
            return .failure(.JSON_ENCODING_FAILED(error))
        }
    }
}
