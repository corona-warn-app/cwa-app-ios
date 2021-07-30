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
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_HappyCase_THEN_CountriesAreReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyOnboardedCountriesResponse))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should success with new countries")
		var countries: [Country] = []
				
		// WHEN
		provider.onboardedCountries(completion: { result in
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
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.notModified))
		}
		let store = MockTestStore()
		let cachedOnboardedCountries = HealthCertificateValidationOnboardedCountriesCache(
			onboardedCountries: onboardedCountriesFake,
			lastOnboardedCountriesETag: "FakeETagNotModified"
		)
		store.validationOnboardedCountriesCache = cachedOnboardedCountries
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should success with new countries")
		var countries: [Country] = []
		
		// WHEN
		provider.onboardedCountries(completion: { result in
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
		XCTAssertEqual(countries, store.validationOnboardedCountriesCache?.onboardedCountries)
	}
	
	// MARK: - Failures
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_MissingETag_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERRORIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			let package = SAPDownloadedPackage(
				keysBin: Data(),
				signature: Data()
			)
			let response = PackageDownloadResponse(
				package: package,
				etag: nil
			)
			
			completion(.success(response))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)

		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR)
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_EmptyPackage_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSINGIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			let response = PackageDownloadResponse(
				package: nil,
				etag: "SomeETag"
			)
			
			completion(.success(response))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING)
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_WrongSignature_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALIDIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			let package = SAPDownloadedPackage(
				keysBin: Data(),
				signature: Data()
			)
			let response = PackageDownloadResponse(
				package: package,
				etag: "someETag"
			)
			
			completion(.success(response))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID)
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_CorruptCBOR_THEN_ONBOARDED_COUNTRIES_JSON_DECODING_FAILEDIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			let package = SAPDownloadedPackage(
				keysBin: onboardedCountriesCorruptCBORDataFake,
				signature: Data()
			)
			let response = PackageDownloadResponse(
				package: package,
				etag: "someETag"
			)
			
			completion(.success(response))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_DECODING_FAILED")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_DECODING_ERROR(.CBOR_DECODING_FAILED(nil)))
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_BadNetworkConnection_THEN_ONBOARDED_COUNTRIES_NO_NETWORKIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.noNetworkConnection))
		}
		let store = MockTestStore()
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_NO_NETWORK")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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

	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_NotModified_THEN_ONBOARDED_COUNTRIES_MISSING_CACHEIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.notModified))
		}
		let store = MockTestStore()
		// And now we do not save something cached in the store.
		let provider = HealthCertificateValidationOnboardedCountriesProvider(
			store: store,
			client: client,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_MISSING_CACHE")
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_MISSING_CACHE)
	}
	
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
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		var receivedError: HealthCertificateValidationOnboardedCountriesError?
	
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
		var receivedError: HealthCertificateValidationOnboardedCountriesError?

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
}
