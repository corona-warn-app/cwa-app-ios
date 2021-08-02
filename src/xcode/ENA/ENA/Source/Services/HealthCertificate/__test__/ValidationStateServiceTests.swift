////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class TestHealthCertificateService: HealthCertificateService {

	convenience init(
		store: HealthCertificateStoring,
		signatureVerifying: DCCSignatureVerifying,
		dscListProvider: DSCListProviding,
		client: Client,
		appConfiguration: AppConfigurationProviding,
		validUntilDates: [Date],
		expirationDates: [Date]
	) {
		self.init(
			store: store,
		 signatureVerifying: signatureVerifying,
		 dscListProvider: dscListProvider,
			client: client,
		 appConfiguration: appConfiguration
	 )
		self.validUntilDates = validUntilDates
		self.expirationDates = expirationDates

	}

	// inject some test data helpers
	var validationUpdatedHook: () -> Void = {}
	var validUntilDates: [Date] = []
	var expirationDates: [Date] = []

	override func updateValidityStatesAndNotifications(shouldScheduleTimer: Bool = true) {
		super.updateValidityStatesAndNotifications(shouldScheduleTimer: shouldScheduleTimer)
		validationUpdatedHook()
	}

	override func validUntilDates(for healthCertificates: [HealthCertificate], signingCertificates: [DCCSigningCertificate]) -> [Date] {
		return validUntilDates
	}

	override func expirationDates(for healthCertificates: [HealthCertificate]) -> [Date] {
		return expirationDates
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
		service.validationUpdatedHook = {
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
		service.validationUpdatedHook = {
			validationStateServiceExpectation.fulfill()
		}

		// WHEN

		let fakeDCCSigningCertificate = DCCSigningCertificate(kid: Data(), data: Data())
		dscListProvider.signingCertificates.value = [fakeDCCSigningCertificate]

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNil(service.nextValidityTimer)
	}

	struct DateHelpers {
		let minus2Days = Date(timeIntervalSinceNow: 60 * 60 * 24 * -2)
		let minus1Day = Date(timeIntervalSinceNow: 60 * 60 * 24 * -1)
		let now = Date()
		let plus5Seconds = Date(timeIntervalSinceNow: .short)
		let plus1Day = Date(timeIntervalSinceNow: 60 * 60 * 24 * 1)
		let plus2Days = Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)

		var orderDates: [Date] {
			[minus2Days, minus1Day, now, plus5Seconds, plus1Day, plus2Days]
		}

		var futureDates: [Date] {
			[plus5Seconds, plus1Day, plus2Days]
		}
	}

	func test_processNextFireTimestamp_THEN_isNearestFuturedate() throws {
		// GIVEN
		let dateHelper = DateHelpers()
		let service = TestHealthCertificateService(
			store: MockTestStore(),
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			validUntilDates: dateHelper.orderDates.shuffled(),
			expirationDates: dateHelper.futureDates.shuffled()
		)

		// WHEN
		let nextDate = try XCTUnwrap(service.nextFireDate)
		// THEN
		XCTAssertEqual(dateHelper.plus5Seconds, nextDate)
	}

	func test_scheduleTimer_THEN_TriggersUpdateAndGetsReset() throws {
		// GIVEN
		let dateHelper = DateHelpers()
		let service = TestHealthCertificateService(
			store: MockTestStore(),
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			validUntilDates: dateHelper.orderDates.shuffled(),
			expirationDates: dateHelper.futureDates.shuffled()
		)

		let validationStateServiceExpectation = expectation(description: "ValidationStateService updated")
		service.validationUpdatedHook = {
			validationStateServiceExpectation.fulfill()
		}

		// WHEN
		service.scheduleTimer()
		XCTAssertNotNil(service.nextValidityTimer)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNil(service.nextValidityTimer)
	}

}
