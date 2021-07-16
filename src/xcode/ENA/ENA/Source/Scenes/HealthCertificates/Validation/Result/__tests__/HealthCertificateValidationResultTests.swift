////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import class CertLogic.ValidationResult

class HealthCertificateValidationResultTests: XCTestCase {

	func testGIVEN_ValidationResults_WHEN_ModelIsCreated_THEN_OpenIsIncluded() throws {
		// GIVEN
		let arrivalCountry = try XCTUnwrap(Country(countryCode: "FR"))
		let arrivalDate = Date()
		let validationResults: [ValidationResult] = []
		
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
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 7)
		
	}
}
