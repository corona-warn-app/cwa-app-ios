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
        let cbor = try rulesCBORDataFake()
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
        let filterParameters = FilterParameter.fake()
        let externalParameters = ExternalParameter.fake()

        let result = ValidationRulesAccess().applyValidationRules(rules, to: certificate, filter: filterParameters, externalRules: externalParameters)

        guard case .success = result else {
            XCTFail("Success expected.")
            return
        }
    }
}
