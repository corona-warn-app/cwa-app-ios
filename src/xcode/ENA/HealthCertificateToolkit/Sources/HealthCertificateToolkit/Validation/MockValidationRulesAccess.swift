//
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

public struct MockValidationRulesAccess: ValidationRulesAccessing {
    
    // MARK: - Init
    
    public init() {}
        
    // MARK: - Public
    
    public var expectedExtractionResult: (Swift.Result<[Rule], RuleValidationError>)?
    public var expectedValidationResult: (Swift.Result<[ValidationResult], RuleValidationError>)?
    
    public func extractValidationRules(
        from cborData: CBORData
    ) -> Swift.Result<[Rule], RuleValidationError> {
        
        guard let expectedExtractionResult = expectedExtractionResult else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }
        return expectedExtractionResult
    }
    
    public func applyValidationRules(
        _ rules: [Rule],
        to certificate: DigitalCovidCertificate,
        externalRules: ExternalParameter
    ) -> Swift.Result<[ValidationResult], RuleValidationError> {
        
        guard let expectedValidationResult = expectedValidationResult else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }
        
        return expectedValidationResult
    }
}
