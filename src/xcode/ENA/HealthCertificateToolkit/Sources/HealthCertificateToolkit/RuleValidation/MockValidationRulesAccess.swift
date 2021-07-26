//
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

public struct MockValidationRulesAccess: ValidationRulesAccessing {
    
    // MARK: - Init
    
    public init() {}
        
    // MARK: - Public
    
    public var expectedAcceptanceExtractionResult: (Swift.Result<[Rule], RuleValidationError>)?
    public var expectedInvalidationExtractionResult: (Swift.Result<[Rule], RuleValidationError>)?
    public var expectedValidationResult: (Swift.Result<[ValidationResult], RuleValidationError>)?
    
    public func extractValidationRules(
        from cborData: CBORData
    ) -> Swift.Result<[Rule], RuleValidationError> {
        
        if let expectedExtractionResult = expectedAcceptanceExtractionResult {
            return expectedExtractionResult
        } else if let expectedExtractionResult = expectedInvalidationExtractionResult {
            return expectedExtractionResult
        } else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }
    }
    
    public func applyValidationRules(
        _ rules: [Rule],
        to certificate: DigitalCovidCertificate,
        filter: FilterParameter,
        externalRules: ExternalParameter
    ) -> Swift.Result<[ValidationResult], RuleValidationError> {
        
        guard let expectedValidationResult = expectedValidationResult else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }
        
        return expectedValidationResult
    }
}
