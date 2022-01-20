//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionCoordinatorModelTests: CWATestCase {

	// MARK: - Should Show Override Test Notice

	func testShouldShowOverrideTestNotice_WithoutRegisteredTests() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: FakeRulesDownloadService()
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.pcrTest = nil
		coronaTestService.antigenTest = nil

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			eventProvider: MockEventStore()
		)

		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredPCRTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: FakeRulesDownloadService()
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.pcrTest = PCRTest.mock(testResult: .pending)
		coronaTestService.antigenTest = nil

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			eventProvider: MockEventStore()
		)

		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.pcrTest?.testResult = .positive
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		coronaTestService.pcrTest?.testResult = .negative
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		coronaTestService.pcrTest?.testResult = .invalid
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		// Should not be shown for expired tests
		coronaTestService.pcrTest?.testResult = .expired
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredAntigenTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: FakeRulesDownloadService()
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.pcrTest = nil
		coronaTestService.antigenTest = AntigenTest.mock(testResult: .pending)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			eventProvider: MockEventStore()
		)

		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest?.testResult = .positive
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest?.testResult = .invalid
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		// Should not be shown for expired tests
		coronaTestService.antigenTest?.testResult = .expired
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest?.testResult = .negative
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		// Should not be shown for outdated antigen tests
		coronaTestService.antigenTestIsOutdated = true
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredTests() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: FakeRulesDownloadService()
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		coronaTestService.pcrTest = PCRTest.mock(testResult: .pending)
		coronaTestService.antigenTest = AntigenTest.mock(testResult: .pending)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			eventProvider: MockEventStore()
		)

		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	// MARK: - Should Show TestCertificateScreen

	func testShouldShowTestCertificateScreen_WithPCRTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		XCTAssertTrue(model.shouldShowTestCertificateScreen(with: .pcr(guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915", qrCodeHash: "")))
	}

	func testShouldShowTestCertificateScreen_WithAntigenTestThatHasCertificateSupport() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		let antigenTestQRCodeInformation = AntigenTestQRCodeInformation(
			hash: "",
			timestamp: 0,
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			testID: nil,
			cryptographicSalt: nil,
			certificateSupportedByPointOfCare: true
		)

		XCTAssertTrue(model.shouldShowTestCertificateScreen(with: .antigen(qrCodeInformation: antigenTestQRCodeInformation, qrCodeHash: "")))
	}

	func testShouldShowTestCertificateScreen_WithAntigenTestThatHasNoCertificateSupport() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		let antigenTestQRCodeInformation = AntigenTestQRCodeInformation(
			hash: "",
			timestamp: 0,
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			testID: nil,
			cryptographicSalt: nil,
			certificateSupportedByPointOfCare: false
		)

		XCTAssertFalse(model.shouldShowTestCertificateScreen(with: .antigen(qrCodeInformation: antigenTestQRCodeInformation, qrCodeHash: "")))
	}

	func testShouldShowTestCertificateScreen_WithAntigenTestThatHasNoCertificateSupportSpecified() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		let antigenTestQRCodeInformation = AntigenTestQRCodeInformation(
			hash: "",
			timestamp: 0,
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			testID: nil,
			cryptographicSalt: nil,
			certificateSupportedByPointOfCare: nil
		)

		XCTAssertFalse(model.shouldShowTestCertificateScreen(with: .antigen(qrCodeInformation: antigenTestQRCodeInformation, qrCodeHash: "")))
	}

	func testShouldShowTestCertificateScreen_FromTeleTAN() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		XCTAssertFalse(model.shouldShowTestCertificateScreen(with: .teleTAN(tan: "qwdzxcsrhe")))
	}

	// MARK: - Symptoms Option Selected

	func testSymptomsOptionYesSelected() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.symptomsOptionSelected(.yes)

		XCTAssertTrue(model.shouldShowSymptomsOnsetScreen)
	}

	func testSymptomsOptionNoSelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOptionSelected(.no)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .nonSymptomatic)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOptionPreferNotToSaySelected() {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertFalse(model.shouldShowSymptomsOnsetScreen)
		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .noInformation)

		waitForExpectations(timeout: .short)
	}

	// MARK: - Symptoms Onset Option Selected

	func testSymptomsOnsetOptionExactDateSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr

		let yesterday = try XCTUnwrap(Calendar.gregorian().date(byAdding: .day, value: -1, to: Date()))

		model.symptomsOnsetOptionSelected(.exactDate(yesterday))

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .daysSinceOnset(1))

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionLastSevenDaysSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOnsetOptionSelected(.lastSevenDays)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .lastSevenDays)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionOneToTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOnsetOptionSelected(.oneToTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .oneToTwoWeeksAgo)


		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionMoreThanTwoWeeksAgoSelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOnsetOptionSelected(.moreThanTwoWeeksAgo)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .moreThanTwoWeeksAgo)

		waitForExpectations(timeout: .short)
	}

	func testSymptomsOnsetOptionPreferNotToSaySelected() throws {
		let submissionExpectation = expectation(description: "Submission is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { _ in
			submissionExpectation.fulfill()
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr
		model.symptomsOnsetOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .symptomaticWithUnknownOnset)

		waitForExpectations(timeout: .short)
	}

	// MARK: - Submit Exposure

	func testSuccessfulSubmit() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(nil)
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.submitExposure(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testSuccessfulSubmitWithoutKeys() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.noKeysCollected)
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.submitExposure(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testFailingSubmitWithNotAuthorizedError() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.notAuthorized)
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		// .notAuthorized should not trigger an error
		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.submitExposure(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testFailingSubmitWithInternalError() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.internal)
		}

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		model.coronaTestType = .pcr

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.submitExposure(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { onSuccessExpectation.fulfill() },
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetTestResultSucceeds() {
		let expectedTestResult: TestResult = .positive

		
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenModel(registrationToken: "fake")),
				.success(TestResultModel(testResult: expectedTestResult.rawValue, sc: nil, labId: nil))
			]
		)

		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: CoronaTestService(
				client: client,
				restServiceProvider: restServiceProvider,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		let onErrorExpectation = expectation(description: "onError is not called")
		onErrorExpectation.isInverted = true

		model.registerTestAndGetResult(
			for: .pcr(guid: "", qrCodeHash: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { testResult in
				XCTAssertEqual(testResult, expectedTestResult)

				onSuccessExpectation.fulfill()
			},
			onError: { _ in onErrorExpectation.fulfill() }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetTestResultFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let exposureSubmissionService = MockExposureSubmissionService()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenModel(registrationToken: "fake")),
				.failure(ServiceError<TestResultError>.invalidResponse),
				.success(SubmissionTANModel(submissionTAN: "fake"))
			]
		)

		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: CoronaTestService(
				client: client,
				restServiceProvider: restServiceProvider,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: FakeRulesDownloadService()
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			eventProvider: MockEventStore()
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerTestAndGetResult(
			for: .pcr(guid: "", qrCodeHash: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in onSuccessExpectation.fulfill() },
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

}
