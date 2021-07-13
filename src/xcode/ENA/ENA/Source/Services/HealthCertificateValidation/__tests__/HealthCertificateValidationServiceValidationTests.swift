////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic

class HealthCertificateValidationServiceValidationTests: XCTestCase {
			
}

extension HealthCertificateValidationOnboardedCountriesError: Equatable {
	public static func == (lhs: HealthCertificateValidationOnboardedCountriesError, rhs: HealthCertificateValidationOnboardedCountriesError) -> Bool {
		switch (lhs, rhs) {
		case let (.ONBOARDED_COUNTRIES_DECODING_ERROR(lhsRuleValidationError), .ONBOARDED_COUNTRIES_DECODING_ERROR(rhsRuleValidationError)):
			return lhsRuleValidationError == rhsRuleValidationError
		default:
			return lhs.localizedDescription == rhs.localizedDescription
		}
	}
}

extension RuleValidationError: Equatable {
	public static func == (lhs: RuleValidationError, rhs: RuleValidationError) -> Bool {
		switch (lhs, rhs) {
		case (.CBOR_DECODING_FAILED, .CBOR_DECODING_FAILED):
			return true
		case (.JSON_ENCODING_FAILED, .JSON_ENCODING_FAILED):
			return true
		case (.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND):
			return true
		default:
			return false
		}
	}
}
