////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic

class HealthCertificateValidationOnboardedCountriesProviderTests: XCTestCase {
		
	// MARK: - Success
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HappyCase_THEN_CountriesAreReturned() throws {
		// GIVEN
		
		let expectation = self.expectation(description: "Test should success with new countries")
		let expectedCountries = try ValidationOnboardedCountriesModel(decodeCBOR: HealthCertificateToolkit.onboardedCountriesCBORDataFake)
		let expectedResource = LoadResource(
			result: .success(expectedCountries),
			willLoadResource: { _ in }
		)
		
		let restServiceProvider = RestServiceProviderStub(loadResources: [expectedResource])
		
		restServiceProvider.load(ValidationOnboardedCountriesResource()) { result in
			switch result {
				
			case .success(let model):
				let countries = model.countries
				XCTAssertEqual(countries, expectedCountries.countries)
			case .failure(let error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}
		
		// THEN
		waitForExpectations(timeout: .short)
	}
	
	
	// MARK: - Failures
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_SomeError_THEN_Error() throws {
		// GIVEN
		
		let expectation = self.expectation(description: "Test should success with new countries")
		let expectedCountries = try ValidationOnboardedCountriesModel(decodeCBOR: HealthCertificateToolkit.onboardedCountriesCBORDataFake)
		let expectedResource = LoadResource(
			result: .success(expectedCountries),
			willLoadResource: { _ in }
		)
		
		let restServiceProvider = RestServiceProviderStub(loadResources: [expectedResource])
		
		restServiceProvider.load(ValidationOnboardedCountriesResource()) { result in
			switch result {
				
			case .success(let model):
				let countries = model.countries
				XCTAssertEqual(countries, expectedCountries.countries)
			case .failure(let error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}
		
		// THEN
		waitForExpectations(timeout: .short)
	}
}
