//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import HealthCertificateToolkit
import ZIPFoundation


final class ValidationOnboardedCountriesResourceTests: CWATestCase {
	
	// MARK: - Success

	func testGIVEN_Resource_WHEN_FetchWithoutCachedData_THEN_FreshDataReturned() throws {
		// GIVEN
		// http code 200
		let expectation = expectation(description: "Expect that we got a completion")
		
		// Create cbor data and the archive, which is needed for the decode call of the CBORReceiveResource
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake
		))
		
		let archiveDataCache = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake2
		))
		
		// This list has to match the one in onboardedCountriesCBORDataFake
		let fetchedCountries = [Country(withCountryCodeFallback: "DE"), Country(withCountryCodeFallback: "FR")]
		// This list has to match the one in onboardedCountriesCBORDataFake2
		let cachedCountries = [Country(withCountryCodeFallback: "IT"), Country(withCountryCodeFallback: "UK")]
		
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			],
			responseData: archiveData
		)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		// Fake some cached data
		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(data: archiveDataCache, eTag: eTag, date: Date())
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				// THEN
				// We expect for http code 200 that we got the fetchedCountries and NOT the cached ones.
				XCTAssertEqual(model.countries, fetchedCountries)
				XCTAssertNotEqual(model.countries, cachedCountries)
			case let .failure(error):
				XCTFail("Load should succeed but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_FetchWithCachedData_THEN_CashedDataReturned() throws {
		// GIVEN
		// http code 304
		let expectation = expectation(description: "Expect that we got a completion")
		
		// Create the archives, which is needed for the decode call of the CBORReceiveResource
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake
		))
		
		let archiveDataCache = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake2
		))
		
		// This list has to match the one in onboardedCountriesCBORDataFake
		let fetchedCountries = [Country(withCountryCodeFallback: "DE"), Country(withCountryCodeFallback: "FR")]
		// This list has to match the one in onboardedCountriesCBORDataFake2
		let cachedCountries = [Country(withCountryCodeFallback: "IT"), Country(withCountryCodeFallback: "UK")]
		
		let eTag = "DummyDataETag"
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: [
				"ETag": eTag
			],
			responseData: archiveData
		)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		// Fake some cached data
		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(data: archiveDataCache, eTag: eTag, date: Date())
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
				
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				// THEN
				// We expect for http code 304 that we got the cachedCountries and NOT the fetchedCountries.
				XCTAssertNotEqual(model.countries, fetchedCountries)
				XCTAssertEqual(model.countries, cachedCountries)
			case let .failure(error):
				XCTFail("Load should succeed but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	// MARK: - Failures
	
	func testGIVEN_Resource_WHEN_EtagIsMissing_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		// Create cbor data and the archive, which is needed for the decode call of the CBORReceiveResource
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake
		))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
				
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_EmptyPackage_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
				
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_WrongSignature_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		// Create cbor data and the archive, which is needed for the decode call of the CBORReceiveResource
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCBORDataFake
		))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
		
		let resource = ValidationOnboardedCountriesResource()
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_EmptyPackage_THEN_ONBOARDED_COUNTRIES_JSON_DECODING_FAILED() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		// Create cbor data and the archive, which is needed for the decode call of the CBORReceiveResource
		let archiveData = try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.onboardedCountriesCorruptCBORDataFake
		))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: archiveData
		)
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
		
		var resource = ValidationOnboardedCountriesResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				// Successful test if we can unpack the error to an .ONBOARDED_COUNTRIES_DECODING_ERROR containing a .CBOR_DECODING_FAILED error.
				guard case let .receivedResourceError(customError) = error,
					  case let .ONBOARDED_COUNTRIES_DECODING_ERROR(decodingError) = customError,
					  case .CBOR_DECODING_FAILED = decodingError else {
						  XCTFail("Received wrong error type")
						  return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_NoNetwork_THEN_ONBOARDED_COUNTRIES_NO_NETWORK() {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a failure")
		
		let fakedError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
		let stack = MockNetworkStack(
			error: fakedError
		)
		
		let resource = ValidationOnboardedCountriesResource()
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
				
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_NO_NETWORK))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_Resource_WHEN_NoCache_THEN_ONBOARDED_COUNTRIES_MISSING_CACHE() {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a failure")
				
		let stack = MockNetworkStack(
			httpStatus: 304,
			responseData: nil
		)
		
		let resource = ValidationOnboardedCountriesResource()
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
				
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_MISSING_CACHE))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
			
	func testGIVEN_Resource_WHEN_HttpError404_THEN_ONBOARDED_COUNTRIES_CLIENT_ERROR() {
		// GIVEN
		// http code 404
		let expectation = expectation(description: "Expect that we got a failure")
		
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: nil
		)
		
		let resource = ValidationOnboardedCountriesResource()
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession
		)
				
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("Load should fail but failed succeeded 😅")
			case let .failure(error):
				// THEN
				XCTAssertEqual(error, .receivedResourceError(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	

	
}
