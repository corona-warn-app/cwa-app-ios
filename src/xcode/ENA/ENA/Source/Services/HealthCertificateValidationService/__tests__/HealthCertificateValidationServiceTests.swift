////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class HealthCertificateValidationServiceTests: XCTestCase {
	
	// MARK: - Success - OnboardedCountries
	
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
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
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.notModified))
		}
		let store = MockTestStore()
		let cachedOnboardedCountries = ValidationOnboardedCountriesCache(
			onboardedCountries: onboardedCountriesFake,
			lastOnboardedCountriesETag: "FakeETagNotModified"
		)
		store.validationOnboardedCountriesCache = cachedOnboardedCountries
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
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
		XCTAssertEqual(countries, store.validationOnboardedCountriesCache?.onboardedCountries)
	}
	
	// MARK: - Failures - OnboardedCountries
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_MissingETag_THEN_ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALIDIsReturned() {
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier()
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_JSON_DECODING_FAILED")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		XCTAssertEqual(receivedError, .ONBOARDED_COUNTRIES_JSON_DECODING_FAILED)
	}
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_BadNetworkConnection_THEN_ONBOARDED_COUNTRIES_NO_NETWORKIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.noNetworkConnection))
		}
		let store = MockTestStore()
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_NO_NETWORK")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_MISSING_CACHE")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		// And now we do not save something cached in the store.
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_CLIENT_ERROR")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
		// And now we do not save something cached in the store.
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_SERVER_ERROR")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
	
	func testGIVEN_ValidationService_GetOnboardedCountries_WHEN_DefaultHTTPError_THEN_ONBOARDED_COUNTRIES_SERVER_ERRORIsReturned() {
		// GIVEN
		let client = ClientMock()
		client.onValidationOnboardedCountries = { _, completion in
			completion(.failure(.noResponse))
		}
		let store = MockTestStore()
		// And now we do not save something cached in the store.
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		let expectation = self.expectation(description: "Test should fail ONBOARDED_COUNTRIES_SERVER_ERROR")
		var receivedError: ValidationOnboardedCountriesError?
	
		// WHEN
		validationService.onboardedCountries(completion: { result in
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
	
	// MARK: - Success - Validation
	
	func testGIVEN_ValidationService_WHEN_HappyCase_THEN_PassedShouldBeReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetDCCRules = { [weak self] _, _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyRulesResponse))
		}
		
		let store = MockTestStore()
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success([])
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: validationRulesAccess
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime: UInt64 = 1625655530
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificateBase45 = DigitalCovidCertificateFake.makeBase45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(familyName: "Brause", givenName: "Pascal", standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-06-06T06:06:06Z")]
			),
			and: CBORWebTokenHeader.fake(expirationTime: expirationTime)
		)
		
		guard case let .success(base45) = healthCertificateBase45 else {
			XCTFail("Could not create fake health certificate. Abort test.")
			return
		}
		let healthCertificate = try HealthCertificate(base45: base45)
		
		let expectation = self.expectation(description: "Test should success with .passed")
		var responseReport: HealthCertificateValidationReport?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: "FR",
			validationClock: validationClock,
			completion: { result in
				switch result {
				case let .success(report):
					responseReport = report
					expectation.fulfill()
				case let .failure(error):
					XCTFail("Test should not fail with error: \(error)")
				}
			}
		)
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let report = responseReport else {
			XCTFail("report must not be nil")
			return
		}
		XCTAssertEqual(report, .validationPassed)
		
	}
	
	func testGIVEN_ValidationService_WHEN_NotModifiedAcceptanceRules_THEN_CachedAcceptanceRulesShouldNotBeChanged() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetDCCRules = { [weak self] _, ruleType, completion in
			switch ruleType {
			case .acceptance:
				completion(.failure(.notModified))
			case .invalidation:
				guard let self = self else {
					XCTFail("Could not create strong self")
					return
				}
				completion(.success(self.dummyOnboardedCountriesResponse))
			}
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number One")
		store.acceptanceRulesCache = ValidationRulesCache(
			validationRules: [cachedRule],
			lastValidationRulesETag: "FakeEtag"
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([cachedRule])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success([])
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: validationRulesAccess
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime: UInt64 = 1625655530
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificateBase45 = DigitalCovidCertificateFake.makeBase45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(familyName: "Brause", givenName: "Pascal", standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-06-06T06:06:06Z")]
			),
			and: CBORWebTokenHeader.fake(expirationTime: expirationTime)
		)
		
		guard case let .success(base45) = healthCertificateBase45 else {
			XCTFail("Could not create fake health certificate. Abort test.")
			return
		}
		let healthCertificate = try HealthCertificate(base45: base45)
		
		let expectation = self.expectation(description: "Test should success with .passed")
		var responseReport: HealthCertificateValidationReport?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: "FR",
			validationClock: validationClock,
			completion: { result in
				switch result {
				case let .success(report):
					responseReport = report
					expectation.fulfill()
				case let .failure(error):
					XCTFail("Test should not fail with error: \(error)")
				}
			}
		)
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let report = responseReport else {
			XCTFail("report must not be nil")
			return
		}
		XCTAssertEqual(report, .validationPassed)
		guard let acceptanceRulesCache = store.acceptanceRulesCache else {
			XCTFail("cached rules must not be nil")
			return
		}
		// The cached rules must not be changed, if so we would have downloaded new ones.
		XCTAssertEqual(acceptanceRulesCache.validationRules, [cachedRule])
	}
	
	func testGIVEN_ValidationService_WHEN_NotModifiedInvalidationRules_THEN_CachedInvalidationRulesShouldNotBeChanged() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetDCCRules = { [weak self] _, ruleType, completion in
			switch ruleType {
			case .invalidation:
				completion(.failure(.notModified))
			case .acceptance:
				guard let self = self else {
					XCTFail("Could not create strong self")
					return
				}
				completion(.success(self.dummyOnboardedCountriesResponse))
			}
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number Two")
		store.invalidationRulesCache = ValidationRulesCache(
			validationRules: [cachedRule],
			lastValidationRulesETag: "FakeEtag"
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([cachedRule])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success([])
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: validationRulesAccess
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime: UInt64 = 1625655530
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificateBase45 = DigitalCovidCertificateFake.makeBase45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(familyName: "Brause", givenName: "Pascal", standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				testEntries: [TestEntry.fake(dateTimeOfSampleCollection: "2021-06-06T06:06:06Z")]
			),
			and: CBORWebTokenHeader.fake(expirationTime: expirationTime)
		)
		
		guard case let .success(base45) = healthCertificateBase45 else {
			XCTFail("Could not create fake health certificate. Abort test.")
			return
		}
		let healthCertificate = try HealthCertificate(base45: base45)
		
		let expectation = self.expectation(description: "Test should success with .passed")
		var responseReport: HealthCertificateValidationReport?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: "FR",
			validationClock: validationClock,
			completion: { result in
				switch result {
				case let .success(report):
					responseReport = report
					expectation.fulfill()
				case let .failure(error):
					XCTFail("Test should not fail with error: \(error)")
				}
			}
		)
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let report = responseReport else {
			XCTFail("report must not be nil")
			return
		}
		XCTAssertEqual(report, .validationPassed)
		guard let invalidationRulesCache = store.invalidationRulesCache else {
			XCTFail("cached rules must not be nil")
			return
		}
		// The cached rules must not be changed, if so we would have downloaded new ones.
		XCTAssertEqual(invalidationRulesCache.validationRules, [cachedRule])
	}
	
	// MARK: - Failures - Validation
	
	func testGIVEN_ValidationService_WHEN_expirationDateHasReached_THEN_TECHNICAL_VALIDATION_FAILED_IsReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetDCCRules = { [weak self] _, _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyRulesResponse))
		}
		
		let store = MockTestStore()
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		// expirationTime must be >= validation clock to succeed.
		let validationClock = Date()
		
		let healthCertificateBase45 = DigitalCovidCertificateFake.makeBase45Fake(
			from: DigitalCovidCertificate.fake(),
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = healthCertificateBase45 else {
			XCTFail("Could not create fake health certificate. Abort test.")
			return
		}
		let healthCertificate = try HealthCertificate(base45: base45)
		
		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: "FR",
			validationClock: validationClock,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Test should not succeed.")
				case let .failure(error):
					responseError = error
					expectation.fulfill()
				}
			}
		)
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let error = responseError else {
			XCTFail("report must not be nil")
			return
		}
		XCTAssertEqual(error, .TECHNICAL_VALIDATION_FAILED)
		
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
	
	private lazy var dummyRulesResponse: PackageDownloadResponse = {
		do {
			let fakeData = try rulesCBORDataFake()
			let package = SAPDownloadedPackage(
				keysBin: fakeData,
				signature: Data()
			)
			let response = PackageDownloadResponse(
				package: package,
				etag: "FakeEtag"
			)
			return response
		} catch {
			XCTFail("Could not create rules CBOR fake data")
			let response = PackageDownloadResponse(
				package: nil,
				etag: "FailStateETag"
			)
			return response
		}
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
