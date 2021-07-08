////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic

// swiftlint:disable:next type_body_length
class HealthCertificateValidationServiceValidationTests: XCTestCase {
			
	// MARK: - Success (Passed)
	
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
		
		XCTAssertNil(store.acceptanceRulesCache)
		XCTAssertNil(store.invalidationRulesCache)
				
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "B"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "C"), result: .passed)
		]
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationService = HealthCertificateValidationProvider(
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
		XCTAssertNotNil(store.acceptanceRulesCache)
		XCTAssertNotNil(store.invalidationRulesCache)
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
		let validationService = HealthCertificateValidationProvider(
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
		let validationService = HealthCertificateValidationProvider(
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
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .open),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .passed)
		]
		
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationService = HealthCertificateValidationProvider(
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
		// Need to double the results because the injected expectedValidationResult will be returned twice (1x acceptance, 1x invalidation)
		XCTAssertEqual(report, .validationOpen(validationResults + validationResults))
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
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		
		let validationResults = [
			ValidationResult(rule: Rule.fake(identifier: "Rule A"), result: .passed),
			ValidationResult(rule: Rule.fake(identifier: "Rule B"), result: .open),
			ValidationResult(rule: Rule.fake(identifier: "Rule C"), result: .fail)
		]
		
		var validationRulesAccess = MockValidationRulesAccess()
		validationRulesAccess.expectedAcceptanceExtractionResult = .success([])
		validationRulesAccess.expectedInvalidationExtractionResult = .success([])
		validationRulesAccess.expectedValidationResult = .success(validationResults)
		let validationService = HealthCertificateValidationProvider(
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
		// Need to double the results because the injected expectedValidationResult will be returned twice (1x acceptance, 1x invalidation)
		XCTAssertEqual(report, .validationFailed(validationResults + validationResults))
	}
	
	// MARK: - Errors
	
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
		let validationService = HealthCertificateValidationProvider(
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
