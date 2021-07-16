////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import class CertLogic.ValidationResult
import class CertLogic.Rule

class HealthCertificateValidationResultTests: XCTestCase {
	
	func testGIVEN_ValidationResults_WHEN_OpenModelIsCreated_THEN_modelIsSetupCorrectly() throws {
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
}
