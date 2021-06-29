//
// 🦠 Corona-Warn-App
//

import SwiftCBOR
import CertLogic
import XCTest
import SwiftyJSON
@testable import HealthCertificateToolkit

class ValidationRulesTests: XCTestCase {

    func test_CreateValidationRules() throws {
        let rules = [
            Rule.fake(),
            Rule.fake(),
            Rule.fake()
        ]

        let cbor = try CodableCBOREncoder().encode(rules)
        let validationRules = try ValidationRules(cborData: cbor)

        XCTAssertEqual(validationRules.rules, rules)
    }
}
