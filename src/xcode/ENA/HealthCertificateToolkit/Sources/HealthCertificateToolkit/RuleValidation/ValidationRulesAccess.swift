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

public protocol BoosterRulesAccessing {
    func applyBoosterNotificationValidationRules(
    certificates: [DigitalCovidCertificateWithHeader],
    rules: [Rule],
    certLogicEngine: CertLogicEnginable?,
    log: (String) -> Void
    ) -> Swift.Result<ValidationResult, BoosterNotificationRuleValidationError>
}

public struct ValidationRulesAccess: ValidationRulesAccessing, BoosterRulesAccessing {

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

    public func applyBoosterNotificationValidationRules(
        certificates: [DigitalCovidCertificateWithHeader],
        rules: [Rule],
        certLogicEngine: CertLogicEnginable? = nil,
        log: (String) -> Void
    ) -> Swift.Result<ValidationResult, BoosterNotificationRuleValidationError> {

        guard let recentVaccinationCertificateWithHeader = certificates.recentVaccinationCertificate,
              let vaccinationEntry = recentVaccinationCertificateWithHeader.certificate.vaccinationEntries?[0] else {
            return .failure(.NO_VACCINATION_CERTIFICATE)
        }

        let recentVaccinationCertificate = recentVaccinationCertificateWithHeader.certificate

        var recoveryEntries: [RecoveryEntry]?
        if let recoveryEntry = certificates.recentRecoveryCertificate?.certificate.recoveryEntries?[0] {
            recoveryEntries = [recoveryEntry]
        }

        // Prepare payload: the payload shall be the JSON representation of the most recent vaccination certificate.
        // If there is a most recent recovery certificate, payload.r[0] shall be set to r[0] of the JSON representation of the recovery certificate.
        // Note that the result of this is a DGC-like JSON data structure that has ver, nam, v[0] and may have r[0].

        let combinedCertificate = DigitalCovidCertificate(
            version: recentVaccinationCertificate.version,
            name: recentVaccinationCertificate.name,
            dateOfBirth: recentVaccinationCertificate.dateOfBirth,
            vaccinationEntries: [vaccinationEntry],
            testEntries: nil,
            recoveryEntries: recoveryEntries
        )

        do {
            let jsonData = try JSONEncoder().encode(combinedCertificate)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return .failure(.JSON_ENCODING_FAILED(nil))
            }

            return invokeCertLogicForBoosterNotifications(
                rules: rules,
                payload: jsonString,
                vaccinationCertificateWithHeader: recentVaccinationCertificateWithHeader,
                certLogicEngine: certLogicEngine,
                log: log
            )

        } catch {
            return .failure(.JSON_ENCODING_FAILED(error))
        }
    }

    private func invokeCertLogicForBoosterNotifications(
        rules: [Rule],
        payload: String,
        vaccinationCertificateWithHeader: DigitalCovidCertificateWithHeader,
        certLogicEngine: CertLogicEnginable? = nil,
        log: (String) -> Void
    ) -> Swift.Result<ValidationResult, BoosterNotificationRuleValidationError> {

        guard let schemaURL = Bundle.module.url(forResource: "dcc-validation-rule", withExtension: "json"),
              let schemaData = FileManager.default.contents(atPath: schemaURL.path),
              let schemaString = String(data: schemaData, encoding: .utf8) else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }

        // The `Type` attribute of all rules shall be set to `Acceptance` before being passed to CertLogic.
        rules.forEach {
            $0.type = "Acceptance"
        }

        let filterParameter = FilterParameter(
            validationClock: Date(),
            countryCode: "DE",
            certificationType: .vaccination,
            region: nil
        )

        let externalParameter = ExternalParameter(
            validationClock: Date(),
            valueSets: [:],
            exp: vaccinationCertificateWithHeader.header.expirationTime,
            iat: vaccinationCertificateWithHeader.header.issuedAt,
            issuerCountryCode: "DE",
            kid: nil
        )

        let logicEngine = certLogicEngine ?? CertLogicEngine(schema: schemaString, rules: rules)
        let validationResult = logicEngine.validate(
            filter: filterParameter,
            external: externalParameter,
            payload: payload
        )

        validationResult.forEach {
            log("Validation-Result: Rule-Identifier: \(String(describing: $0.rule?.identifier)), Result: \($0.result)")
        }

        for inputRule in rules {
            if let firstPassedRule = (validationResult.first {
                $0.rule?.identifier == inputRule.identifier && $0.result == .passed
            }) {
                return .success(firstPassedRule)
            }
        }
        return .failure(.NO_PASSED_RESULT)
    }
}
