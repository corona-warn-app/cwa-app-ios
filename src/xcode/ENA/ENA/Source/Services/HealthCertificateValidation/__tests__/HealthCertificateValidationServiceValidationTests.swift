////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic
import OpenCombine
import ZIPFoundation

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class HealthCertificateValidationServiceValidationTests: XCTestCase {
	
	// MARK: - Success (Passed)
	
	func testGIVEN_ValidationService_WHEN_HappyCaseCachedIsNotUsed_THEN_NewRulesAreDownloadedAndPassedShouldBeReturned() throws {
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
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
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
		let rulesDownloadService = RulesDownloadService(signatureVerifier: MockVerifier(), store: store, client: client)
		
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime = Date(timeIntervalSince1970: 1625655530)
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
			arrivalCountry: try country(),
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
		XCTAssertEqual(report, .validationPassed(validationResults))
		// The cache must now be filled, because only when download was successful we save the rules.
		XCTAssertNotNil(store.acceptanceRulesCache)
		XCTAssertNotNil(store.invalidationRulesCache)
	}
	
	func testGIVEN_ValidationService_WHEN_HappyCaseCachedIsUsed_THEN_CachedRulesAreUsedAndPassedShouldBeReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(.notModified))
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number One")
		store.acceptanceRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeEtag",
			validationRules: [cachedRule]
			
		)
		let cachedRule2 = Rule.fake(identifier: "Number Two")
		store.invalidationRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeETag2",
			validationRules: [cachedRule2]
		)
		XCTAssertNotNil(store.acceptanceRulesCache)
		XCTAssertNotNil(store.invalidationRulesCache)
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .passed)
		]
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([cachedRule])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: validationRulesAccess, store: store, client: client)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime = Date(timeIntervalSince1970: 1625655530)
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
			arrivalCountry: try country(),
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
		XCTAssertEqual(report, .validationPassed(validationResults))
		guard let acceptanceRulesCache = store.acceptanceRulesCache,
			  let invalidationRulesCache = store.invalidationRulesCache else {
			XCTFail("cached rules must not be nil")
			return
		}
		// The cached rules must not be changed, if so we would have downloaded new ones.
		XCTAssertEqual(acceptanceRulesCache.validationRules, [cachedRule])
		XCTAssertEqual(invalidationRulesCache.validationRules, [cachedRule2])
	}
	
	// MARK: - Success (Open)
	
	func testGIVEN_ValidationService_WHEN_SomeRuleIsOpen_THEN_OpenShouldBeReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		
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
		
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: validationRulesAccess, signatureVerifier: MockVerifier(), store: store, client: client)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime = Date(timeIntervalSince1970: 1625655530)
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
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_SomeRuleIsFailed_THEN_FailedShouldBeReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		
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
		
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: validationRulesAccess, signatureVerifier: MockVerifier(), store: store, client: client)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// expirationTime must be >= validation clock to succeed.
		let expirationTime = Date(timeIntervalSince1970: 1625655530)
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
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: mockValidationRulesAccess, signatureVerifier: MockVerifier(), store: store, client: client)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .TECHNICAL_VALIDATION_FAILED(expirationDate: healthCertificate.expirationDate, signatureInvalid: false))
	}
	
	func testGIVEN_ValidationService_WHEN_signatureIsInvalid_THEN_TECHNICAL_VALIDATION_FAILED_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_PH_INVALID),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .TECHNICAL_VALIDATION_FAILED(expirationDate: healthCertificate.expirationDate, signatureInvalid: true))
	}
	
	func testGIVEN_ValidationService_WHEN_ValueSets50xError_THEN_VALUE_SET_SERVER_ERROR_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_ValueSetsOtherError_THEN_VALUE_SET_CLIENT_ERROR_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_ValueSetsNoNetwork_THEN_NO_NETWORK_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)

		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .NO_NETWORK")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_ValueSetsUnkownError_THEN_VALUE_SET_CLIENT_ERROR_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: cachingClient,
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .VALUE_SET_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingEtagNil_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		
		let fakeData = try rulesCBORDataFake()
		let package = SAPDownloadedPackage(
			keysBin: fakeData,
			signature: Data()
		)
		let response = PackageDownloadResponse(
			package: package,
			etag: nil
		)
		
		client.onGetDCCRules = { _, _, completion in
			completion(.success(response))
		}
		
		let store = MockTestStore()
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_JSON_ARCHIVE_ETAG_ERROR(.acceptance))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingPackageIsEmpty_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		
		let response = PackageDownloadResponse(
			package: nil,
			etag: "FakeETag"
		)
		
		client.onGetDCCRules = { _, _, completion in
			completion(.success(response))
		}
		
		let store = MockTestStore()
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_JSON_ARCHIVE_FILE_MISSING(.acceptance))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingVerifyingFails_THEN_ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let rulesDownloadService = RulesDownloadService(store: store, client: client)

		// To force a verifying error, we just use the real verifier instead of the mock.
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: MockValidationRulesAccess(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_JSON_ARCHIVE_SIGNATURE_INVALID(.acceptance) )
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingDataDecodingFails_THEN_ACCEPTANCE_RULE_VALIDATION_ERROR_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .failure(.CBOR_DECODING_FAILED(nil))
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: validationRulesAccess, signatureVerifier: MockVerifier(), store: store, client: client)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_VALIDATION_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_DECODING_ERROR(.acceptance, .CBOR_DECODING_FAILED(nil)))
	}
	
	// MARK: - Errors (Downloading Rules Failure Handler)
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingAcceptanceCacheIsMissing_THEN_ACCEPTANCE_RULE_MISSING_CACHE_IsReturned() throws {
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.notModified
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_MISSING_CACHE")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_MISSING_CACHE(.acceptance))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingInvalidationCacheIsMissing_THEN_INVALIDATION_RULE_MISSING_CACHE_IsReturned() throws {
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
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .INVALIDATION_RULE_MISSING_CACHE")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_MISSING_CACHE(.invalidation))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingNoNetwork_THEN_NO_NETWORK_IsReturned() throws {
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.noNetworkConnection
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .NO_NETWORK")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingServerError404_THEN_ACCEPTANCE_RULE_CLIENT_ERROR_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.serverError(404)
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_CLIENT_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_CLIENT_ERROR(.acceptance))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingServerError500_THEN_ACCEPTANCE_RULE_SERVER_ERROR_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.serverError(500)
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_SERVER_ERROR(.acceptance))
	}
	
	func testGIVEN_ValidationService_WHEN_RuleDownloadingDefaultError_THEN_ACCEPTANCE_RULE_SERVER_ERROR_IsReturned() throws {
		// Note: This test is redundant to the one for invalidation cause they have the same code path. So this one counts for both rule types.
		// GIVEN
		let client = ClientMock()
		let expectedError = URLSessionError.fakeResponse
		
		// The acceptance must success now to reach the invalidation.
		client.onGetDCCRules = { _, _, completion in
			completion(.failure(expectedError))
		}
		
		let store = MockTestStore()
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .ACCEPTANCE_RULE_SERVER_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULE_SERVER_ERROR(.acceptance))
	}
	
	// MARK: - Others
	
	func testGIVEN_ValidationService_WHEN_RuleValidationFails_THEN_RULES_VALIDATION_ERROR_IsReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		let fakeData = try rulesCBORDataFake()
		let package = SAPDownloadedPackage(
			keysBin: fakeData,
			signature: Data()
		)
		let response = PackageDownloadResponse(
			package: package,
			etag: "FakeETag"
		)
		
		client.onGetDCCRules = { _, _, completion in
			completion(.success(response))
		}
		
		let store = MockTestStore()
		
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)

		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .failure(.CBOR_DECODING_FAILED(nil))
		
		let rulesDownloadService = RulesDownloadService(validationRulesAccess: validationRulesAccess, signatureVerifier: MockVerifier(), store: store, client: client)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: validationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		let validationClock = Date(timeIntervalSince1970: TimeInterval(0))
		
		let healthCertificate = HealthCertificate.mock()
		
		let expectation = self.expectation(description: "Test should fail with .RULES_VALIDATION_ERROR")
		var responseError: HealthCertificateValidationError?
		
		// WHEN
		validationService.validate(
			healthCertificate: healthCertificate,
			arrivalCountry: try country(),
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
		XCTAssertEqual(error, .RULES_VALIDATION_ERROR(.CBOR_DECODING_FAILED(nil)))
	}

	func testGIVEN_ValidationService_WHEN_UsingAllCountryCodes_THEN_ValueIsCorrect() {
		// GIVEN
		let store = MockTestStore()
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let client = ClientMock()
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// WHEN
		let countryCodes = validationService.allCountryCodes
		
		// THEN
		// Picked some random codes
		XCTAssertTrue(countryCodes.contains("DE"))
		XCTAssertTrue(countryCodes.contains("PY"))
		XCTAssertTrue(countryCodes.contains("ZW"))
		XCTAssertTrue(countryCodes.contains("FR"))
		
		XCTAssertFalse(countryCodes.contains("AA"))
		XCTAssertFalse(countryCodes.contains("ZZ"))
		XCTAssertFalse(countryCodes.contains("HA"))
		XCTAssertFalse(countryCodes.contains("FF"))
	}
	
	func testGIVEN_ValidationService_WHEN_MappingCertificateTypes_THEN_MappingIsCorrect() {
		// GIVEN
		let store = MockTestStore()
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let client = ClientMock()
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
		
		// WHEN
		let mappedTest = validationService.mapCertificateType(.test)
		let mappedRecovery = validationService.mapCertificateType(.recovery)
		let mappedVaccination = validationService.mapCertificateType(.vaccination)
		
		// THEN
		XCTAssertEqual(mappedTest, CertLogic.CertificateType.test)
		XCTAssertEqual(mappedRecovery, CertLogic.CertificateType.recovery)
		XCTAssertEqual(mappedVaccination, CertLogic.CertificateType.vaccination)
	}
	
	func testGIVEN_ValidationService_WHEN_MappingValueSets_THEN_MappingIsCorrect() {
		// GIVEN
		let store = MockTestStore()
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let client = ClientMock()
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		let countryCodes = validationService.allCountryCodes
		let tcTrKey = "tcTr key"
		let tcMaKey = "tcMa key"
		let tcTtKey = "tcTt key"
		let tgKey = "tg key"
		let vpKey = "vp key"
		let maKey = "ma key"
		let mpKey = "mp key"
		
		let originalValueSet = SAP_Internal_Dgc_ValueSets.with {
			$0.tcTr = valueSet(key: tcTrKey)
			$0.tcMa = valueSet(key: tcMaKey)
			$0.tcTt = valueSet(key: tcTtKey)
			$0.tg = valueSet(key: tgKey)
			$0.vp = valueSet(key: vpKey)
			$0.ma = valueSet(key: maKey)
			$0.mp = valueSet(key: mpKey)
		}
		
		// WHEN
		let mappedSet = validationService.mapValueSets(valueSet: originalValueSet)
		
		// THEN
		XCTAssertEqual(mappedSet["country-2-codes"], countryCodes)
		XCTAssertEqual(mappedSet["covid-19-lab-result"]?.first, tcTrKey)
		XCTAssertEqual(mappedSet["covid-19-lab-test-manufacturer-and-name"]?.first, tcMaKey)
		XCTAssertEqual(mappedSet["covid-19-lab-test-type"]?.first, tcTtKey)
		XCTAssertEqual(mappedSet["disease-agent-targeted"]?.first, tgKey)
		XCTAssertEqual(mappedSet["sct-vaccines-covid-19"]?.first, vpKey)
		XCTAssertEqual(mappedSet["vaccines-covid-19-auth-holders"]?.first, maKey)
		XCTAssertEqual(mappedSet["vaccines-covid-19-names"]?.first, mpKey)
	}
	
	func testGIVEN_ValidationService_WHEN_MappingUnixTime_THEN_MappingIsCorrect() {
		// GIVEN
		let store = MockTestStore()
		let dscListProvider = DSCListProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)
		let client = ClientMock()
		let mockValidationRulesAccess = MockValidationRulesAccess()
		let rulesDownloadService = RulesDownloadService(
			validationRulesAccess: mockValidationRulesAccess,
			signatureVerifier: MockVerifier(),
			store: store,
			client: client
		)
		let validationService = HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			validationRulesAccess: mockValidationRulesAccess,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)

		// Exact Time for 9.7.2021, 10:30:00
		let dateToday: UInt64 = 1625826600
		
		var dateComponents = DateComponents()
		dateComponents.year = 2021
		dateComponents.month = 7
		dateComponents.day = 9
		dateComponents.hour = 10
		dateComponents.minute = 30
		dateComponents.second = 0
		dateComponents.timeZone = TimeZone(abbreviation: "UTC")
		
		let expectedDate = Calendar(identifier: .gregorian).date(from: dateComponents)
		// WHEN
		let mappedTime = validationService.mapUnixTimestampsInSecondsToDate(dateToday)
		
		// THEN
		XCTAssertEqual(mappedTime, expectedDate)
	}

	// MARK: - CertLogicEngineValidation

	func test_CertLogicEngineValidation() throws {
		guard let jsonData = certLogicTestData else {
			XCTFail("Could not load json data.")
			return
		}

		let testData = try JSONDecoder().decode(CertLogicEngineTestData.self, from: jsonData)

		guard let valueSetsData = Data(base64Encoded: testData.general.valueSetProtocolBuffer),
			  let valueSets = try? SAP_Internal_Dgc_ValueSets(serializedData: valueSetsData) else {
			XCTFail("Could not load valueSets.")
			return
		}

		let valueSetsStub = ValueSetsStub(valueSets: valueSets)

		let expectation = self.expectation(description: "Validation should complete for every test case.")
		expectation.expectedFulfillmentCount = testData.testCases.count

		for testCase in testData.testCases {
			let mockVerifier = MockVerifier()
			let mockStore = MockTestStore()
			let mockClient = ClientMock()
			let dscListProvider = DSCListProvider(
				client: CachingHTTPClientMock(),
				store: MockTestStore()
			)
			
			guard let package = try? makeSAPDownloadedPackage(with: testCase.rules) else {
				XCTFail("Could not create package.")
				return
			}

			mockClient.onGetDCCRules = { _, _, completion in
				let package = PackageDownloadResponse(
					package: package,
					etag: ""
				)
				completion(.success(package))
			}
			let validationRulesAccess = ValidationRulesAccess()
			let rulesDownloadService = RulesDownloadService(
				validationRulesAccess: validationRulesAccess,
				signatureVerifier: mockVerifier,
				store: mockStore,
				client: mockClient
			)
			let validationService = HealthCertificateValidationService(
				store: mockStore,
				client: mockClient,
				vaccinationValueSetsProvider: valueSetsStub,
				validationRulesAccess: validationRulesAccess,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: dscListProvider,
				rulesDownloadService: rulesDownloadService
			)
			let certificate = try HealthCertificate(base45: testCase.dcc)
			let country = try XCTUnwrap(Country(countryCode: testCase.countryOfArrival))

			validationService.validate(
				healthCertificate: certificate,
				arrivalCountry: country,
				validationClock: Date(timeIntervalSince1970: TimeInterval(testCase.validationClock))
			) { result in

				guard case let .success(validationReport) = result else {
					XCTFail("Success expected for validation result.")
					return
				}

				switch validationReport {
				case .validationFailed(let validationResults),
					 .validationOpen(let validationResults),
					 .validationPassed(let validationResults):

					let passCount = validationResults.filter { $0.result == .passed }.count
					let openCount = validationResults.filter { $0.result == .open }.count
					let failCount = validationResults.filter { $0.result == .fail }.count

					XCTAssertEqual(passCount, testCase.expPass, "CertEngineTestCase failed with incorrect expPass count: \(testCase.testCaseDescription)")
					XCTAssertEqual(openCount, testCase.expOpen, "CertEngineTestCase failed with incorrect expOpen count: \(testCase.testCaseDescription)")
					XCTAssertEqual(failCount, testCase.expFail, "CertEngineTestCase failed with incorrect expFail count: \(testCase.testCaseDescription)")
				}

				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: .short)
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
	
	private func valueSet(key: String) -> SAP_Internal_Dgc_ValueSet {
		return SAP_Internal_Dgc_ValueSet.with {
			$0.items.append(
				SAP_Internal_Dgc_ValueSetItem.with {
					$0.key = key
				}
			)
		}
	}
	
	private func country() throws -> Country {
		 return try XCTUnwrap(Country(countryCode: "FR"))
	}

	private func makeSAPDownloadedPackage(with rules: [Rule]) throws -> SAPDownloadedPackage? {
		let cborRulesData = try CodableCBOREncoder().encode(rules)

		let archive = try XCTUnwrap(Archive(accessMode: .create))
		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: UInt32(cborRulesData.count), bufferSize: 4, provider: { position, size -> Data in
			return cborRulesData.subdata(in: position..<position + size)
		})
		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return Data().subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()
		return SAPDownloadedPackage(compressedData: archiveData)
	}

	private var certLogicTestData: Data? {
		let bundle = Bundle(for: HealthCertificateValidationServiceValidationTests.self)
		guard let url = bundle.url(forResource: "dcc-validation-rules-common-test-cases", withExtension: "json"),
			  let data = FileManager.default.contents(atPath: url.path) else {
			return nil
		}
		return data
	}
}

/// ONLY for testing purposes because it ignores underlining errors for comparisons.
extension ValidationOnboardedCountriesError: Equatable {
	public static func == (lhs: ValidationOnboardedCountriesError, rhs: ValidationOnboardedCountriesError) -> Bool {
		switch (lhs, rhs) {
		case let (.ONBOARDED_COUNTRIES_DECODING_ERROR(lhsRuleValidationError), .ONBOARDED_COUNTRIES_DECODING_ERROR(rhsRuleValidationError)):
			return lhsRuleValidationError == rhsRuleValidationError
		default:
			return lhs.localizedDescription == rhs.localizedDescription
		}
	}
}

/// ONLY for testing purposes because it ignores underlining errors for comparisons.
extension RuleValidationError: Equatable {
	public static func == (lhs: RuleValidationError, rhs: RuleValidationError) -> Bool {
		switch (lhs, rhs) {
		case (.CBOR_DECODING_FAILED, .CBOR_DECODING_FAILED):
			return true
		case (.JSON_ENCODING_FAILED, .JSON_ENCODING_FAILED):
			return true
		case (.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND):
			return true
		default:
			return false
		}
	}
}

private struct ValueSetsStub: VaccinationValueSetsProviding {

	var valueSets: SAP_Internal_Dgc_ValueSets

	func latestVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		// return stubbed value sets; no error
		return Just(valueSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	func fetchVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		// return stubbed value sets; no error
		return Just(valueSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
