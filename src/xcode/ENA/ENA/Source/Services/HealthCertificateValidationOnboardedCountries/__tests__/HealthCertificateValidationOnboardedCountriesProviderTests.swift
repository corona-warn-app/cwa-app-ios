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
	/*
				
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HTTP40x_THEN_ONBOARDED_COUNTRIES_CLIENT_ERRORIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.serverError(404)))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_CLIENT_ERROR")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		provider.onboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				receivedError = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_CLIENT_ERROR)
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HTTP50x_THEN_ONBOARDED_COUNTRIES_SERVER_ERRORIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.serverError(500)))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_SERVER_ERROR")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		provider.onboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				receivedError = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_SERVER_ERROR)
	}

	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_NoResponse_THEN_ONBOARDED_COUNTRIES_NO_NETWORKIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.noResponse))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_NO_NETWORK")
		var receivedError: ValidationOnboardedCountriesError?

		// WHEN
		provider.onboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed.")
			case let .failure(error):
				receivedError = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_NO_NETWORK)
	}

	private lazy var dummyOnboardedCountriesResponse: PackageDownloadResponse = {
		let fakeData = onboardedCountriesCBORDataFake
				
		let package = SAPDownloadedPackage(
			keysBin: fakeData,
			signature: Data()
		)
		let response = PackageDownloadResponse(
			package: package,
			etag: "FakeEtag"
		)
		return response
	}()
	
	private var onboardedCountriesFake: [Country] {
		guard let countryDE = Country(countryCode: "DE"),
			  let countryFR = Country(countryCode: "FR") else {
			XCTFail("Could not create countries")
			return []
		}
		return [countryDE, countryFR]
	}
	 */
}
