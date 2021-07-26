//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import CertLogic

public protocol ValidationRulesAccessing {
    func extractValidationRules(
        from cborData: CBORData
    ) -> Swift.Result<[Rule], RuleValidationError>
    
    func applyValidationRules(
        _ rules: [Rule],
        to certificate: DigitalCovidCertificate,
        filter: FilterParameter,
        externalRules: ExternalParameter
    ) -> Swift.Result<[ValidationResult], RuleValidationError>
}

public struct ValidationRulesAccess: ValidationRulesAccessing {

    public init() {}

    public func extractValidationRules(from cborData: CBORData) -> Swift.Result<[Rule], RuleValidationError> {
        do {
            let cborDecoder = CBORDecoder(input: [UInt8](cborData))
            guard let cbor = try cborDecoder.decodeItem(),
                  case let .array(cborRules) = cbor else {
                return .failure(.CBOR_DECODING_FAILED(nil))
            }

            var rules = [Rule]()
            for cborRule in cborRules {
                guard case let .map(cborRuleMap) = cborRule else {
                    return .failure(.CBOR_DECODING_FAILED(nil))
                }
                let rule = try JSONDecoder().decode(Rule.self, from: JSONSerialization.data(withJSONObject: cborRuleMap.anyMap))
                rules.append(rule)
            }
            return .success(rules)
        } catch {
            return .failure(.CBOR_DECODING_FAILED(error))
        }
    }

    public func applyValidationRules(_ rules: [Rule], to certificate: DigitalCovidCertificate, filter: FilterParameter, externalRules: ExternalParameter) -> Swift.Result<[ValidationResult], RuleValidationError> {
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
            return .success(certLogicEngine.validate(filter: filter, external: externalRules, payload: jsonString))
        } catch {
            return .failure(.JSON_ENCODING_FAILED(error))
        }
    }
}
