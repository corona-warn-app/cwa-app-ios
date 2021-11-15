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

    func test_when_applyBoosterNotificationValidationRules_then_passedResultReturned() {
        let rules = [Rule.fake(identifier: "5"), Rule.fake(identifier: "1")]

        let certificates = [
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    vaccinationEntries: [.fake()]
                )
            ),
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    recoveryEntries: [.fake()]
                )
            )
        ]

        let firstPassedResult = ValidationResult(rule: Rule.fake(identifier: "1"), result: .passed, validationErrors: nil)
        let secondPassedResult = ValidationResult(rule: Rule.fake(identifier: "5"), result: .passed, validationErrors: nil)

        let certLogicStub = CertLogicEngineStub(validationResult: [
            ValidationResult(rule: nil, result: .open, validationErrors: nil),
            secondPassedResult,
            firstPassedResult
        ])
        let result = ValidationRulesAccess().applyBoosterNotificationValidationRules(
            certificates: certificates,
            rules: rules,
            certLogicEngine: certLogicStub,
            log: { _ in }
        )

        guard case .success(let validationResult) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(validationResult, secondPassedResult)
    }

    func test_when_applyBoosterNotificationValidationRules_then_noPassedResultFailureReturned() {
        let rules = [Rule.fake()]

        let certificates = [
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    vaccinationEntries: [.fake()]
                )
            )
        ]

        let certLogicStub = CertLogicEngineStub(validationResult: [
            ValidationResult(rule: nil, result: .open, validationErrors: nil)
        ])
        let result = ValidationRulesAccess().applyBoosterNotificationValidationRules(
            certificates: certificates,
            rules: rules,
            certLogicEngine: certLogicStub,
            log: { _ in }
        )

        guard case .failure(let error) = result,
              case .NO_PASSED_RESULT = error else {
            XCTFail("NO_PASSED_RESULT error expected.")
            return
        }
    }

    func test_when_applyBoosterNotificationValidationRules_then_noVaccinationFailureReturned() {
        let rules = [Rule.fake()]

        let certificates = [
            DigitalCovidCertificateWithHeader.fake(
                header: CBORWebTokenHeader.fake(
                    expirationTime: Date.distantFuture
                ),
                certificate: DigitalCovidCertificate.fake(
                    testEntries: [.fake()]
                )
            )
        ]

        let certLogicStub = CertLogicEngineStub(validationResult: [
            ValidationResult(rule: nil, result: .passed, validationErrors: nil)
        ])
        let result = ValidationRulesAccess().applyBoosterNotificationValidationRules(
            certificates: certificates,
            rules: rules,
            certLogicEngine: certLogicStub,
            log: { _ in }
        )

        guard case .failure(let error) = result,
              case .NO_VACCINATION_CERTIFICATE = error else {
            XCTFail("NO_VACCINATION_CERTIFICATE error expected.")
            return
        }
    }
}

private class CertLogicEngineStub: CertLogicEnginable {

    // MARK: - Init

    required init(schema: String, rules: [Rule]) {
        self.validationResult = []
    }

    init(validationResult: [ValidationResult]) {
        self.validationResult = validationResult
    }

    // MARK: - Internal

    func validate(filter: FilterParameter, external: ExternalParameter, payload: String) -> [ValidationResult] {
        return validationResult
    }

    // MARK: - Private

    private let validationResult: [ValidationResult]

}
