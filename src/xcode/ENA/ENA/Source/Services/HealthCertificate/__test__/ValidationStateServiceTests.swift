////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class TestHealthCertificateService: HealthCertificateService {

	var expectationHook: () -> Void = {}

	override func updateValidityStates(shouldScheduleTimer: Bool = true) {
		super.updateValidityStates(shouldScheduleTimer: shouldScheduleTimer)
		expectationHook()
	}

}

class ValidationStateServiceTests: XCTestCase {

	func test_AppConfigDidUpdate_THEN_UpdateGetsCalled() {
		// GIVEN
		let validationStateServiceExpectation = expectation(description: "ValidationStateService updated")

		let appConfiguration = CachedAppConfigurationMock()
		let store = MockTestStore()
		let service = TestHealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: appConfiguration
		)
		service.expectationHook = {
			validationStateServiceExpectation.fulfill()
		}

		// WHEN
		let originalConfiguration = appConfiguration.currentAppConfig.value
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE"]
		appConfiguration.currentAppConfig.value = config

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotEqual(config, originalConfiguration)
		XCTAssertNil(service.nextValidityTimer)
	}

	func test_DSCListChanges_THEN_UpdateGetsCalled() {
		// GIVEN
		let validationStateServiceExpectation = expectation(description: "ValidationStateService updated")

		let dscListProvider = MockDSCListProvider()
		let store = MockTestStore()
		let service = TestHealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: dscListProvider,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.expectationHook = {
			validationStateServiceExpectation.fulfill()
		}

		// WHEN

		let fakeDCCSigningCertificate = DCCSigningCertificate(kid: Data(), data: Data())
		dscListProvider.signingCertificates.value = [fakeDCCSigningCertificate]

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNil(service.nextValidityTimer)
	}

}
