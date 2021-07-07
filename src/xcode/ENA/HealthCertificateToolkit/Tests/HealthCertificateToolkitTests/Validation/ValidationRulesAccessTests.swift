//
// 🦠 Corona-Warn-App
//

import SwiftCBOR
import CertLogic
import XCTest
import SwiftyJSON
@testable import HealthCertificateToolkit

class ValidationRulesAccessTests: XCTestCase {

    func test_CreateValidationRules() throws {
        let rules = [
            Rule.fake(),
            Rule.fake(),
            Rule.fake()
        ]

        let cbor = try CodableCBOREncoder().encode(rules)
        let result = ValidationRulesAccess().extractValidationRules(from: cbor)

        guard case let .success(validationRules) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(validationRules.count, 3)
    }

    func test_ApplyValidationRules() {
        let rules = [
            Rule.fake(),
            Rule.fake(),
            Rule.fake()
        ]

        let certificate = DigitalCovidCertificate.fake()
        let externalParameters = ExternalParameter.fake()

        let result = ValidationRulesAccess().applyValidationRules(rules, to: certificate, externalRules: externalParameters)

        guard case .success = result else {
            XCTFail("Success expected.")
            return
        }
    }
}
