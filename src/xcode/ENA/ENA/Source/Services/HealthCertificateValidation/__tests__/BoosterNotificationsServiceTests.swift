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
		let rulesDownloadService = FakeRulesDownloadService(.success([]))
		let mockBoosterRulesAccess = MockBoosterRulesAccess(
			expectedBoosterResult: .success(
				ValidationResult(
					rule: Rule.fake(),
					result: .passed
				)
			)
		)
		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: mockBoosterRulesAccess
		)
				
		let expectation = expectation(description: "Test should success with .passed")

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
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(resultRule)
	}

	func testGIVEN_BoosterService_WHEN_DownloadSucceeded_THEN_BOOSTER_VALIDATION_ERROR() throws {
		// GIVEN
		let rulesDownloadService = FakeRulesDownloadService(.success([]))
		let mockBoosterRulesAccess = MockBoosterRulesAccess(
			expectedBoosterResult: .failure(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)
		)
		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: mockBoosterRulesAccess
		)

		let expectation = expectation(description: "Test should success with .passed")

		// WHEN
		var responseError: BoosterNotificationServiceError?
		boosterService.applyRulesForCertificates(
			certificates: [],
			completion: { result in
				switch result {
				case .success:
					XCTFail("Error should be returned.")
				case .failure(let error):
					responseError = error
				}
				expectation.fulfill()
			}
		)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(responseError, .BOOSTER_VALIDATION_ERROR(.JSON_VALIDATION_RULE_SCHEMA_NOTFOUND))
	}

	func testGIVEN_BoosterService_WHEN_signatureIsInvalid_THEN_TECHNICAL_VALIDATION_FAILED_IsReturned() throws {
		// GIVEN
		let rulesDownloadService = FakeRulesDownloadService(.failure(.RULE_DECODING_ERROR(.boosterNotification, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND)))

		let boosterService = BoosterNotificationsService(
			rulesDownloadService: rulesDownloadService,
			validationRulesAccess: MockBoosterRulesAccess()
		)

		let expectation = self.expectation(description: "Test should fail with .TECHNICAL_VALIDATION_FAILED")
		
		// WHEN
		var responseError: BoosterNotificationServiceError?
		boosterService.applyRulesForCertificates(
			certificates: [],
			completion: { result in
				switch result {
				case .success:
					XCTFail("Error should be returned.")
				case .failure(let error):
					responseError = error
				}
				expectation.fulfill()
			}
		)
		
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(responseError, .CERTIFICATE_VALIDATION_ERROR(.downloadRulesError(.RULE_DECODING_ERROR(.boosterNotification, .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND))))
	}

}
