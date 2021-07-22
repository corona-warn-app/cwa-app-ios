//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import class CertLogic.ValidationResult
import class CertLogic.Rule

class HealthCertificateValidationResultTests: XCTestCase {
	
	func testGIVEN_ValidationResults_WHEN_OpenModelIsCreated_THEN_ModelIsSetupCorrectly() throws {
		// GIVEN
		let arrivalCountry = try XCTUnwrap(Country(countryCode: "FR"))
		let arrivalDate = Date()
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .open)
		let expectedInvalidationOpenValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .open)
		let validationResults: [ValidationResult] = [
			ValidationResult.fake(result: .passed),
			expectedAcceptanceOpenValidationResult,
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .open),
			expectedInvalidationOpenValidationResult,
			ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .open),
			ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .open)
		]
		
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		// WHEN
		let model = HealthCertificateValidationOpenViewModel(
			arrivalCountry: arrivalCountry,
			arrivalDate: arrivalDate,
			validationResults: validationResults,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// THEN
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		// 12 rows = 5 rows for 5 open validationResults, 7 is texts, images etc.
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 12)
		
		XCTAssertEqual(model.openValidationResults.count, 5)
		XCTAssertEqual(model.openAcceptanceRuleValidationResults.count, 2)
		XCTAssertTrue(model.openAcceptanceRuleValidationResults.contains(expectedAcceptanceOpenValidationResult))
		XCTAssertEqual(model.openInvalidationRuleValidationResults.count, 3)
		XCTAssertTrue(model.openInvalidationRuleValidationResults.contains(expectedInvalidationOpenValidationResult))
	}
	
	func testGIVEN_ValidationResults_WHEN_FailedModelIsCreated_THEN_ModelIsSetupCorrectly() throws {
		// GIVEN
		let arrivalCountry = try XCTUnwrap(Country(countryCode: "FR"))
		let arrivalDate = Date()
		
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .open)
		let expectedInvalidationOpenValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .open)
		let expectedAcceptanceFailedValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .fail)
		let expectedInvalidationFailedValidationResult = ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .fail)
		let validationResults: [ValidationResult] = [
			ValidationResult.fake(result: .passed),
			expectedAcceptanceOpenValidationResult,
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .open),
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .open),
			expectedInvalidationOpenValidationResult,
			expectedAcceptanceFailedValidationResult,
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .fail),
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .fail),
			ValidationResult.fake(rule: Rule.fake(type: "Acceptance"), result: .fail),
			expectedInvalidationFailedValidationResult,
			ValidationResult.fake(rule: Rule.fake(type: "Invalidation"), result: .fail)
		]
		
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		// WHEN
		let model = HealthCertificateValidationFailedViewModel(
			arrivalCountry: arrivalCountry,
			arrivalDate: arrivalDate,
			validationResults: validationResults,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// THEN
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		// 20 rows = 10 rows for 4 open, 6 failed, 10 is texts, images etc.
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 20)
		
		XCTAssertEqual(model.openValidationResults.count, 4)
		XCTAssertEqual(model.openAcceptanceRuleValidationResults.count, 3)
		XCTAssertTrue(model.openAcceptanceRuleValidationResults.contains(expectedAcceptanceOpenValidationResult))
		XCTAssertEqual(model.openInvalidationRuleValidationResults.count, 1)
		XCTAssertTrue(model.openInvalidationRuleValidationResults.contains(expectedInvalidationOpenValidationResult))
		
		XCTAssertEqual(model.failedValidationResults.count, 6)
		XCTAssertEqual(model.failedAcceptanceRuleValidationResults.count, 4)
		XCTAssertTrue(model.failedAcceptanceRuleValidationResults.contains(expectedAcceptanceFailedValidationResult))
		XCTAssertEqual(model.failedInvalidationRuleValidationResults.count, 2)
		XCTAssertTrue(model.failedInvalidationRuleValidationResults.contains(expectedInvalidationFailedValidationResult))
	}
}
