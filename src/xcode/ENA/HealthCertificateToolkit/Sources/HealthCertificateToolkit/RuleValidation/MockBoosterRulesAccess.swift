//
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic

public struct MockBoosterRulesAccess: BoosterRulesAccessing {
    
    // MARK: - Init

    public init(
        expectedBoosterResult: (Swift.Result<ValidationResult, BoosterNotificationRuleValidationError>)? = nil
    ) {
        self.expectedBoosterResult = expectedBoosterResult
    }
        
    // MARK: - Public
    
    public var expectedBoosterResult: (Swift.Result<ValidationResult, BoosterNotificationRuleValidationError>)?
    
    public func applyBoosterNotificationValidationRules(
        certificates: [DigitalCovidCertificateWithHeader],
        rules: [Rule],
        certLogicEngine: CertLogicEnginable?,
        log: (String) -> Void
    ) -> Swift.Result<ValidationResult, BoosterNotificationRuleValidationError> {
        
        if let expectedResult = expectedBoosterResult {
            return expectedResult
        } else {
            return .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
        }
    }
}
