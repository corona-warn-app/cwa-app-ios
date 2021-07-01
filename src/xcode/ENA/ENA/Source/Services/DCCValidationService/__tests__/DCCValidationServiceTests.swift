////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest
import SwiftCBOR
import HealthCertificateToolkit

class DCCValidationServiceTests: XCTestCase {
	
	// MARK:- Success
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HappyCase_THEN_CountriesAreReturned() {
		// GIVEN
		let client = ClientMock()
		client.onGetDCCOnboardedCountries = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyOnboardedCountriesResponse))
		}
		let store = MockTestStore()
		let validationService = DCCValidationService(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should success with new countries")
		var countries: [Country] = []
				
		// WHEN
		validationService.onboardedCountries(completion: { result in
			switch result {
			case let .success(countriesResponse):
				countries = countriesResponse
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})
		
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(countries.count, 2)
		XCTAssertTrue(countries.contains(onboardedCountriesFake[0]))
		XCTAssertTrue(countries.contains(onboardedCountriesFake[1]))
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HTTPNotModified_THEN_CachedCountriesAreReturned() {
		// GIVEN
		let client = ClientMock()
		client.onGetDCCOnboardedCountries = { _, completion in
			completion(.failure(.notModified))
		}
		let store = MockTestStore()
		let cachedOnboardedCountries = OnboardedCountriesCache(
			onboardedCountries: onboardedCountriesFake,
			lastOnboardedCountriesETag: "FakeETagNotModified"
		)
		store.onboardedCountriesCache = cachedOnboardedCountries
		let validationService = DCCValidationService(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should success with new countries")
		var countries: [Country] = []
		
		// WHEN
		validationService.onboardedCountries(completion: { result in
			switch result {
			case let .success(countriesResponse):
				countries = countriesResponse
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})
		
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(countries, store.onboardedCountriesCache?.onboardedCountries)
	}
	
	// MARK:- Failures
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_MissingETag_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALIDIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_EmptyPackage_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSINGIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_EmptySAPPackage_THEN_ONBOARDED_COUNTRIES_JSON_EXTRACTION_FAILEDIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_WrongSignature_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALIDIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_CorruptCBOR_THEN_ONBOARDED_COUNTRIES_JSON_DECODING_FAILEDIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_BadNetworkConnection_THEN_ONBOARDED_COUNTRIES_NO_NETWORKIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_NotModified_THEN_ONBOARDED_COUNTRIES_MISSING_CACHEIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HTTP40x_THEN_ONBOARDED_COUNTRIES_CLIENT_ERRORIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HTTP50x_THEN_ONBOARDED_COUNTRIES_SERVER_ERRORIsReturned() {
		// GIVEN
	
	
		// WHEN
	
	
		// THEN
	
	
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
}
