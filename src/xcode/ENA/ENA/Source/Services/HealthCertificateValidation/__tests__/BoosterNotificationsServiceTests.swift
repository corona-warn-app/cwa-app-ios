//
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic
import OpenCombine
import ZIPFoundation

class BoosterNotificationsServiceTests: XCTestCase {
	
	func testGIVEN_BoosterService_WHEN_HappyCaseCachedIsNotUsed_THEN_NewRulesAreDownloadedAndPassedShouldBeReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetBoosterNotificationsRules = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyRulesResponse))
		}
		
		let rulesDownloadService = RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
		var mockBoosterRulesAccess = MockBoosterRulesAccess()
		let validationResult = ValidationResult(rule: Rule.fake(identifier: "A"), result: .passed)
		mockBoosterRulesAccess.expectedBoosterResult = .success(validationResult)
		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: mockBoosterRulesAccess
		)
				
		let expectation = self.expectation(description: "Test should success with .passed")
		
		// WHEN
		let certificates = [
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			)
		]
		
		var resultRule: Rule?

		boosterService.applyRulesForCertificates(certificates: certificates, completion: { result in
			switch result {
			case let .success(result):
				resultRule = result.rule
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(resultRule)
	}
	/*
	func testGIVEN_BoosterService_WHEN_HappyCaseCachedIsUsed_THEN_CachedRulesAreUsedAndPassedShouldBeReturned() throws {
		// GIVEN
		let client = ClientMock()
		
		client.onGetBoosterNotificationsRules = { _, completion in
			completion(.failure(.notModified))
		}
		
		let store = MockTestStore()
		let cachedRule = Rule.fake(identifier: "Number One")
		store.boosterRulesCache = ValidationRulesCache(
			lastValidationRulesETag: "FakeEtag",
			validationRules: [cachedRule]
			
		)
		XCTAssertNotNil(store.boosterRulesCache)

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
		var mockBoosterRulesAccess = MockBoosterRulesAccess()
		let validationResult = ValidationResult(rule: Rule.fake(identifier: "A"), result: .passed)
		mockBoosterRulesAccess.expectedBoosterResult = .success(validationResult)
		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: mockBoosterRulesAccess
		)

		let expectation = self.expectation(description: "Test should success with .passed")
		// WHEN
		
		let certificates = [
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			)
		]
		boosterService.applyRulesForCertificates(certificates: certificates, completion: { result in
			switch result {
			case .success:
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})
				
		// THEN
		waitForExpectations(timeout: .short)
	
		
		guard let boosterRulesCache = store.boosterRulesCache else {
			XCTFail("cached rules must not be nil")
			return
		}
		// The cached rules must not be changed, if so we would have downloaded new ones.
		XCTAssertEqual(boosterRulesCache.validationRules, [cachedRule])
		XCTAssertEqual(boosterRulesCache.validationRules.count, 1)

	}

	*/

	func testGIVEN_BoosterService_WHEN_signatureIsInvalid_THEN_TECHNICAL_VALIDATION_FAILED_IsReturned() throws {
		// GIVEN
		let client = ClientMock()
		client.onGetBoosterNotificationsRules = { [weak self] _, completion in
			guard let self = self else {
				XCTFail("Could not create strong self")
				return
			}
			completion(.success(self.dummyRulesResponse))
		}
		
		let rulesDownloadService = RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())

		var mockBoosterRulesAccess = MockBoosterRulesAccess()
		let validationResult = ValidationResult(rule: Rule.fake(identifier: "A"), result: .passed)
		mockBoosterRulesAccess.expectedBoosterResult = .success(validationResult)
		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: mockBoosterRulesAccess
		)

		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		
		// WHEN
		
		let certificates = [
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			DigitalCovidCertificateWithHeader.fake(
				header: CBORWebTokenHeader.fake(
					expirationTime: Date.distantFuture
				),
				certificate: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			)
		]
		
		var responseError: BoosterNotificationServiceError?

		boosterService.applyRulesForCertificates(certificates: certificates, completion: { result in
			switch result {
			case .success:
				XCTFail("Error should be returned.")
			case .failure(let error):
			responseError = error
			}
			expectation.fulfill()
		})
		
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(responseError, .CERTIFICATE_VALIDATION_ERROR(.RULE_DECODING_ERROR(.boosterNotification, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)))
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
