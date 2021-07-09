////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class HealthCertificateValidationProviderValidationTests: XCTestCase {
	
	// MARK: - Success (Passed)
	
	func testGIVEN_ValidationProvider_WHEN_HappyCaseCachedIsNotUsed_THEN_NewRulesAreDownloadedAndPassedShouldBeReturned() throws {
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
		
		XCTAssertNil(store.acceptanceRulesCache)
		XCTAssertNil(store.invalidationRulesCache)
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "B"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "C"), result: .passed)
		]
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationProvider = HealthCertificateValidationProvider(
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
		validationProvider.validate(
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
		XCTAssertNotNil(store.acceptanceRulesCache)
		XCTAssertNotNil(store.invalidationRulesCache)
	}
	
	func testGIVEN_ValidationProvider_WHEN_HappyCaseCachedIsUsed_THEN_CachedRulesAreUsedAndPassedShouldBeReturned() throws {
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
				completion(.success(self.dummyRulesResponse))
			}
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number One")
		store.acceptanceRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeEtag",
			validationRules: [cachedRule]
			
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .passed)
		]
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([cachedRule])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationProvider = HealthCertificateValidationProvider(
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
		validationProvider.validate(
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
	
	func testGIVEN_ValidationProvider_WHEN_NotModifiedInvalidationRules_THEN_CachedInvalidationRulesShouldNotBeChanged() throws {
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
				completion(.success(self.dummyRulesResponse))
			}
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number Two")
		store.invalidationRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeEtag",
			validationRules: [cachedRule]
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .passed)
		]
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([cachedRule])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationProvider = HealthCertificateValidationProvider(
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
		validationProvider.validate(
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
	
	// MARK: - Success (Open)
	
	func testGIVEN_ValidationProvider_WHEN_SomeRuleIsOpen_THEN_OpenShouldBeReturned() throws {
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
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .open),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .passed)
		]
		
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationProvider = HealthCertificateValidationProvider(
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
		
		let expectation = self.expectation(description: "Test should success with .validationOpen")
		var responseReport: HealthCertificateValidationReport?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(report, .validationOpen(validationResults))
	}
	
	// MARK: - Success (Fail)
	
	func testGIVEN_ValidationProvider_WHEN_SomeRuleIsFailed_THEN_FailedShouldBeReturned() throws {
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
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .open),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .fail)
		]
		
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationProvider = HealthCertificateValidationProvider(
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
		
		let expectation = self.expectation(description: "Test should success with .validationFailed")
		var responseReport: HealthCertificateValidationReport?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(report, .validationFailed(validationResults))
	}
	
	// MARK: - Errors (ValueSets)
	
	func testGIVEN_ValidationProvider_WHEN_expirationDateHasReached_THEN_TECHNICAL_VALIDATION_FAILED_IsReturned() throws {
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
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: "FR",
			validationClock: Date(),
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
	
	func testGIVEN_ValidationProvider_WHEN_ValueSets50xError_THEN_VALUE_SET_SERVER_ERROR_IsReturned() throws {
		// GIVEN
		let cachingClient = CachingHTTPClientMock()
		guard let fakedUrlResponse = HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 505, httpVersion: nil, headerFields: nil) else {
			XCTFail("Could not create faked HTTPURLResponse. Abort test.")
			return
		}
		let expectedError = URLSessionError.httpError("", fakedUrlResponse)
		cachingClient.onFetchVaccinationValueSets = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		let client = ClientMock()
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .VALUE_SET_SERVER_ERROR)
	}
	
	func testGIVEN_ValidationProvider_WHEN_ValueSetsOtherError_THEN_VALUE_SET_CLIENT_ERROR_IsReturned() {
		// GIVEN
		let cachingClient = CachingHTTPClientMock()
		guard let fakedUrlResponse = HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 999, httpVersion: nil, headerFields: nil) else {
			XCTFail("Could not create faked HTTPURLResponse. Abort test.")
			return
		}
		let expectedError = URLSessionError.httpError("", fakedUrlResponse)
		cachingClient.onFetchVaccinationValueSets = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		let client = ClientMock()
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .VALUE_SET_CLIENT_ERROR)
	}
	
	func testGIVEN_ValidationProvider_WHEN_ValueSetsNoNetwork_THEN_NO_NETWORK_IsReturned() {
		// GIVEN
		let cachingClient = CachingHTTPClientMock()
		let expectedError = URLSessionError.noNetworkConnection
		cachingClient.onFetchVaccinationValueSets = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		let client = ClientMock()
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .NO_NETWORK")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .NO_NETWORK)
	}
	
	func testGIVEN_ValidationProvider_WHEN_ValueSetsUnkownError_THEN_VALUE_SET_CLIENT_ERROR_IsReturned() {
		// GIVEN
		let cachingClient = CachingHTTPClientMock()
		let expectedError = URLSessionError.fakeResponse
		cachingClient.onFetchVaccinationValueSets = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		let client = ClientMock()
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .VALUE_SET_CLIENT_ERROR)
	}
	
	// MARK: - Errors (Downloading Rules Success Handler)
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingEtagNil_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		
		// THEN
		
		// WHEN
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingPackageIsEmpty_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		
		// THEN
		
		// WHEN
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingVerifyingFails_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		
		// THEN
		
		// WHEN
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingDataDecodingFails_THEN_ACCEPTANCE_RULE_VALIDATION_ERROR_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		
		// THEN
		
		// WHEN
	}
	
	// MARK: - Errors (Downloading Rules Failure Handler)
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingAcceptanceCacheIsMissing_THEN_ACCEPTANCE_RULE_MISSING_CACHE_IsReturned() {
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.notModified
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_MISSING_CACHE")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .ACCEPTANCE_RULE_MISSING_CACHE)
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingInvalidationCacheIsMissing_THEN_INVALIDATION_RULE_MISSING_CACHE_IsReturned() {
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.notModified
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number One")
		store.acceptanceRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeEtag",
			validationRules: [cachedRule]
			
		)
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .INVALIDATION_RULE_MISSING_CACHE")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .INVALIDATION_RULE_MISSING_CACHE)
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingNoNetwork_THEN_NO_NETWORK_IsReturned() {
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.noNetworkConnection
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .NO_NETWORK")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .NO_NETWORK)
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingServerError404_THEN_ACCEPTANCE_RULE_CLIENT_ERROR_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.serverError(404)
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .ACCEPTANCE_RULE_CLIENT_ERROR)
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingServerError500_THEN_ACCEPTANCE_RULE_SERVER_ERROR_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.serverError(500)
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .ACCEPTANCE_RULE_SERVER_ERROR)
	}
	
	func testGIVEN_ValidationProvider_WHEN_RuleDownloadingDefaultError_THEN_ACCEPTANCE_RULE_SERVER_ERROR_IsReturned() {
		// Note: This test would be redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.fakeResponse
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationProvider = HealthCertificateValidationProvider(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			signatureVerifier: MockVerifier(),
			validationRulesAccess: MockValidationRulesAccess()
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationProvider.validate(
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
		XCTAssertEqual(error, .ACCEPTANCE_RULE_SERVER_ERROR)
	}
	
	// MARK: - Private
	
	private func validHealthCertificate() throws -> HealthCertificate {
		let healthCertificateBase45 = DigitalCovidCertificateFake.makeBase45Fake(
			from: DigitalCovidCertificate.fake(),
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = healthCertificateBase45 else {
			fatalError("Could not create fake health certificate. Abort test.")
		}
		return try HealthCertificate(base45: base45)
	}
	
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
}
