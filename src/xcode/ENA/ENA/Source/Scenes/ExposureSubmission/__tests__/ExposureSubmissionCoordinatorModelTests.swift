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
		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		
		coronaTestService.pcrTest.value = nil
		coronaTestService.antigenTest.value = nil

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredPCRTest() {
		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()

		coronaTestService.pcrTest.value = .mock(testResult: .pending)
		coronaTestService.antigenTest.value = nil

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.pcrTest.value?.testResult = .positive
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		coronaTestService.pcrTest.value?.testResult = .negative
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		coronaTestService.pcrTest.value?.testResult = .invalid
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))

		// Should not be shown for expired tests
		coronaTestService.pcrTest.value?.testResult = .expired
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredAntigenTest() {
		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		
		coronaTestService.pcrTest.value = nil
		coronaTestService.antigenTest.value = .mock(testResult: .pending)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest.value?.testResult = .positive
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest.value?.testResult = .invalid
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		// Should not be shown for expired tests
		coronaTestService.antigenTest.value?.testResult = .expired
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))

		coronaTestService.antigenTest.value?.testResult = .negative
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))

		// Should not be shown for outdated antigen tests
		coronaTestService.antigenTestIsOutdated.value = true
		XCTAssertFalse(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	func testShouldShowOverrideTestNotice_WithRegisteredTests() {
		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		
		coronaTestService.pcrTest.value = .mock(testResult: .pending)
		coronaTestService.antigenTest.value = .mock(testResult: .pending)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .pcr))
		XCTAssertTrue(model.shouldShowOverrideTestNotice(for: .antigen))
	}

	// MARK: - Should Show TestCertificateScreen

	func testShouldShowTestCertificateScreen_WithPCRTest() {
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertTrue(model.shouldShowTestCertificateScreen(with: .pcr(guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915", qrCodeHash: "")))
	}

	func testShouldShowTestCertificateScreen_WithAntigenTestThatHasCertificateSupport() {
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let antigenTestQRCodeInformation = RapidTestQRCodeInformation(
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
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let antigenTestQRCodeInformation = RapidTestQRCodeInformation(
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
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let antigenTestQRCodeInformation = RapidTestQRCodeInformation(
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
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		XCTAssertFalse(model.shouldShowTestCertificateScreen(with: .teleTAN(tan: "qwdzxcsrhe")))
	}

	// MARK: - Symptoms Option Selected

	func testSymptomsOptionYesSelected() {
		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		model.coronaTestType = .pcr
		model.symptomsOnsetOptionSelected(.preferNotToSay)

		// Submit to check that correct symptoms onset is set
		model.submitExposure(isLoading: { _ in }, onSuccess: { }, onError: { _ in })

		XCTAssertEqual(model.exposureSubmissionService.symptomsOnset, .symptomaticWithUnknownOnset)

		waitForExpectations(timeout: .short)
	}

	// MARK: - Recycle Bin Item To Restore

	func testRecycleBinItem_UserPCRTestIsInRecycleBin() {
		let userPCRRecycleBinItem = RecycleBinItem(
			recycledAt: Date(),
			item: .userCoronaTest(.pcr(.mock(qrCodeHash: "userPCRQRCodeHash")))
		)

		let store = MockTestStore()
		store.recycleBinItems = Set([
			RecycleBinItem(
				recycledAt: Date(),
				item: RecycledItem.certificate(HealthCertificate.mock())
			),
			userPCRRecycleBinItem
		])

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertEqual(
			model.recycleBinItemToRestore(for: .pcr(guid: "", qrCodeHash: "userPCRQRCodeHash")),
			userPCRRecycleBinItem
		)
	}

	func testRecycleBinItem_UserPCRTestIsNotInRecycleBin() {
		let store = MockTestStore()
		store.recycleBinItems = Set([
			RecycleBinItem(
				recycledAt: Date(),
				item: RecycledItem.certificate(HealthCertificate.mock())
			)
		])

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertNil(
			model.recycleBinItemToRestore(for: .pcr(guid: "", qrCodeHash: "userPCRQRCodeHash"))
		)
	}

	func testRecycleBinItem_FamilyMemberPCRTestIsInRecycleBin() {
		let familyMemberPCRRecycleBinItem = RecycleBinItem(
			recycledAt: Date(),
			item: .familyMemberCoronaTest(.pcr(.mock(qrCodeHash: "familyMemberPCRQRCodeHash")))
		)

		let store = MockTestStore()
		store.recycleBinItems = Set([
			RecycleBinItem(
				recycledAt: Date(),
				item: RecycledItem.certificate(HealthCertificate.mock())
			),
			familyMemberPCRRecycleBinItem
		])

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertEqual(
			model.recycleBinItemToRestore(for: .pcr(guid: "", qrCodeHash: "familyMemberPCRQRCodeHash")),
			familyMemberPCRRecycleBinItem
		)
	}

	func testRecycleBinItem_FamilyMemberPCRTestIsNotInRecycleBin() {
		let store = MockTestStore()
		store.recycleBinItems = Set([
			RecycleBinItem(
				recycledAt: Date(),
				item: RecycledItem.certificate(HealthCertificate.mock())
			)
		])

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: store)
		)

		XCTAssertNil(
			model.recycleBinItemToRestore(for: .pcr(guid: "", qrCodeHash: "userPCRQRCodeHash"))
		)
	}

	// MARK: - Submit Exposure

	func testSuccessfulSubmit() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(nil)
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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
			completion(.preconditionError(.noKeysCollected))
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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
	
	func testSuccessfulSubmitNoSubmissionConsent() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.preconditionError(.noSubmissionConsent))
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

	func testFailingSubmitWithKeysNotSharedError() {
		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.submitExposureCallback = { completion in
			completion(.preconditionError(.keysNotShared))
		}

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: MockCoronaTestService(),
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
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

	func testGetTestResultForPCRTestSucceeds() {
		let expectedTestResult: TestResult = .positive

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerPCRTestAndGetResultResult = .success(expectedTestResult)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

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
			onError: { _ in
				XCTFail("Success expected.")
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetFamilyMemberTestResultForPCRTestSucceeds() {
		let expectedFamilyMemberCoronaTest: FamilyMemberCoronaTest = .pcr(.mock(testResult: .positive))

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerPCRTestAndGetResultResult = .success(expectedFamilyMemberCoronaTest)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")
		
		model.registerFamilyMemberTestAndGetResult(
			   for: "displayName",
			   registrationInformation: .pcr(guid: "E1277F-E1277F24-4AD2-40BC-AFF8-CBCCCD893E4B", qrCodeHash: "qrCodeHash"),
			   certificateConsent: .given(dateOfBirth: "2000-01-01"),
			   isLoading: {
				   isLoadingValues.append($0)
				   isLoadingExpectation.fulfill()
			   },
			   onSuccess: { familyMemberCoronaTest in
				   XCTAssertEqual(familyMemberCoronaTest.testResult, expectedFamilyMemberCoronaTest.testResult)

				   onSuccessExpectation.fulfill()
			   },
			   onError: { _ in
				   XCTFail("Success expected.")
			   }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetTestResultForPCRTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerPCRTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerTestAndGetResult(
			for: .pcr(guid: "", qrCodeHash: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in
				XCTFail("Error expected.")
			},
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetFamilyMemberTestResultForPCRTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerPCRTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)
		
		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerFamilyMemberTestAndGetResult(
			   for: "displayName",
			   registrationInformation: .pcr(guid: "E1277F-E1277F24-4AD2-40BC-AFF8-CBCCCD893E4B", qrCodeHash: "qrCodeHash"),
			   certificateConsent: .given(dateOfBirth: "2000-01-01"),
			   isLoading: {
				   isLoadingValues.append($0)
				   isLoadingExpectation.fulfill()
			   },
			   onSuccess: { _ in
				   XCTFail("Error expected.")
			   },
			   onError: { error in
				   XCTAssertEqual(error, expectedError)

				   onErrorExpectation.fulfill()
			   }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetTestResultForPCRTestFromTeleTanSucceeds() {
		let expectedTestResult: TestResult = .positive

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerPCRTestFromTeleTanAndGetResultResult = .success(expectedTestResult)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		model.registerTestAndGetResult(
			for: .teleTAN(tan: ""),
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
			onError: { _ in
				XCTFail("Success expected.")
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetTestResultForPCRTestFromTeleTanFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerPCRTestFromTeleTanAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerTestAndGetResult(
			for: .teleTAN(tan: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in
				XCTFail("Error expected.")
			},
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetTestResultForAntigenTestSucceeds() {
		let expectedTestResult: TestResult = .positive

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerAntigenTestAndGetResultResult = .success(expectedTestResult)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		model.registerTestAndGetResult(
			for: .antigen(qrCodeInformation: .mock(), qrCodeHash: ""),
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
			onError: { _ in
				XCTFail("Success expected.")
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetFamilyMemberTestResultForAntigenTestSucceeds() {
		let expectedFamilyMemberCoronaTest: FamilyMemberCoronaTest = .antigen(.mock(testResult: .positive))

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerAntigenTestAndGetResultResult = .success(expectedFamilyMemberCoronaTest)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		model.registerFamilyMemberTestAndGetResult(
			   for: "displayName",
			   registrationInformation: .antigen(qrCodeInformation: .mock(), qrCodeHash: ""),
			   certificateConsent: .given(dateOfBirth: "2000-01-01"),
			   isLoading: {
				   isLoadingValues.append($0)
				   isLoadingExpectation.fulfill()
			   },
			   onSuccess: { familyMemberCoronaTest in
				   XCTAssertEqual(familyMemberCoronaTest.testResult, expectedFamilyMemberCoronaTest.testResult)

				   onSuccessExpectation.fulfill()
			   },
			   onError: { _ in
				   XCTFail("Success expected.")
			   }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetTestResultForAntigenTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerAntigenTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerTestAndGetResult(
			for: .antigen(qrCodeInformation: .mock(), qrCodeHash: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in
				XCTFail("Error expected.")
			},
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetFamilyMemberTestResultForAntigenTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerAntigenTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerFamilyMemberTestAndGetResult(
			   for: "displayName",
			   registrationInformation: .antigen(qrCodeInformation: .mock(), qrCodeHash: ""),
			   certificateConsent: .given(dateOfBirth: "2000-01-01"),
			   isLoading: {
				   isLoadingValues.append($0)
				   isLoadingExpectation.fulfill()
			   },
			   onSuccess: { _ in
				   XCTFail("Error expected.")
			   },
			   onError: { error in
				  XCTAssertEqual(error, expectedError)

				  onErrorExpectation.fulfill()
			   }
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetTestResultForRapidPCRTestSucceeds() {
		let expectedTestResult: TestResult = .positive

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerRapidPCRTestAndGetResultResult = .success(expectedTestResult)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		model.registerTestAndGetResult(
			for: .rapidPCR(qrCodeInformation: .mock(), qrCodeHash: ""),
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
			onError: { _ in
				XCTFail("Success expected.")
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetFamilyMemberTestResultForRapidPCRTestSucceeds() {
		let expectedFamilyMemberCoronaTest: FamilyMemberCoronaTest = .pcr(.mock(testResult: .positive))

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerRapidPCRTestAndGetResultResult = .success(expectedFamilyMemberCoronaTest)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onSuccessExpectation = expectation(description: "onSuccess is called")

		model.registerFamilyMemberTestAndGetResult(
			for: "displayName",
			registrationInformation: .rapidPCR(qrCodeInformation: .mock(), qrCodeHash: ""),
			certificateConsent: .given(dateOfBirth: "2000-01-01"),
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
		    onSuccess: { familyMemberCoronaTest in
			   XCTAssertEqual(familyMemberCoronaTest.testResult, expectedFamilyMemberCoronaTest.testResult)

			   onSuccessExpectation.fulfill()
		    },
			onError: { _ in
				XCTFail("Success expected.")
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testGetTestResultForRapidPCRTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		coronaTestService.registerRapidPCRTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: MockFamilyMemberCoronaTestService(),
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")

		model.registerTestAndGetResult(
			for: .rapidPCR(qrCodeInformation: .mock(), qrCodeHash: ""),
			isSubmissionConsentGiven: true,
			certificateConsent: .notGiven,
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in
				XCTFail("Error expected.")
			},
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}

	func testGetFamilyMemberTestResultForRapidPCRTestFails() {
		let expectedError: CoronaTestServiceError = .testResultError(.invalidResponse)

		let coronaTestService = MockCoronaTestService()
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.registerRapidPCRTestAndGetResultResult = .failure(expectedError)

		let model = ExposureSubmissionCoordinatorModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			coronaTestService: coronaTestService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			eventProvider: MockEventStore(),
			recycleBin: RecycleBin(store: MockTestStore())
		)

		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()

		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2

		let onErrorExpectation = expectation(description: "onError is called")
		
		model.registerFamilyMemberTestAndGetResult(
			for: "displayName",
			registrationInformation: .rapidPCR(qrCodeInformation: .mock(), qrCodeHash: ""),
			certificateConsent: .given(dateOfBirth: "2000-01-01"),
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { _ in
				XCTFail("Error expected.")
			},
			onError: { error in
				XCTAssertEqual(error, expectedError)

				onErrorExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
}
