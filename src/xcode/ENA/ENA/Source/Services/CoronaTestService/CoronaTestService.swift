////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

// swiftlint:disable:next type_body_length
class CoronaTestService: CoronaTestServiceProviding {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding,
		store: CoronaTestStoring & CoronaTestStoringLegacy & WarnOthersTimeIntervalStoring,
		eventStore: EventStoringProviding,
		diaryStore: DiaryStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		ppacService: PrivacyPreservingAccessControl,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin,
		badgeWrapper: HomeBadgeWrapper
	) {
		#if DEBUG
		if isUITesting {
			if LaunchArguments.exposureSubmission.isFetchingSubmissionTan.boolValue {
				self.restServiceProvider = .registrationTokenServiceProvider
			} else {
				self.restServiceProvider = .coronaTestServiceProvider
			}
			self.store = MockTestStore()
			self.eventStore = MockEventStore()
			self.diaryStore = MockDiaryStore()
			self.appConfiguration = CachedAppConfigurationMock()

			self.healthCertificateService = healthCertificateService
			self.healthCertificateRequestService = healthCertificateRequestService
			self.ppacService = ppacService
			self.notificationCenter = notificationCenter
			self.recycleBin = recycleBin
			self.badgeWrapper = badgeWrapper

			self.fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService, appConfiguration: appConfiguration)
			self.warnOthersReminder = WarnOthersReminder(store: store)

			setup()

			pcrTest.value = mockPCRTest
			antigenTest.value = mockAntigenTest

			return
		}
		#endif

		self.restServiceProvider = restServiceProvider
		self.store = store
		self.eventStore = eventStore
		self.diaryStore = diaryStore
		self.appConfiguration = appConfiguration
		self.healthCertificateService = healthCertificateService
		self.healthCertificateRequestService = healthCertificateRequestService
		self.ppacService = ppacService
		self.notificationCenter = notificationCenter
		self.recycleBin = recycleBin
		self.badgeWrapper = badgeWrapper

		self.fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService, appConfiguration: appConfiguration)
		self.warnOthersReminder = WarnOthersReminder(store: store, userNotificationCenter: notificationCenter)

		healthCertificateRequestService.didRegisterTestCertificate
			.sink { [weak self] certificateIdentifier, testCertificateRequest in
				self?.setUniqueCertificateIdentifier(certificateIdentifier, from: testCertificateRequest)
			}
			.store(in: &subscriptions)

		setup()
	}

	#if DEBUG

	convenience init(
		store: CoronaTestStoring & CoronaTestStoringLegacy & WarnOthersTimeIntervalStoring,
		eventStore: EventStoringProviding,
		diaryStore: DiaryStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateRequestService: HealthCertificateRequestService,
		ppacService: PrivacyPreservingAccessControl,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		recycleBin: RecycleBin,
		badgeWrapper: HomeBadgeWrapper
	) {
		self.init(
			restServiceProvider: .coronaTestServiceProvider,
			store: store,
			eventStore: eventStore,
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: healthCertificateRequestService,
			ppacService: ppacService,
			notificationCenter: notificationCenter,
			recycleBin: recycleBin,
			badgeWrapper: badgeWrapper
		)
	}

	#endif

	// MARK: - Protocol CoronaTestServiceProviding

	var pcrTest = CurrentValueSubject<UserPCRTest?, Never>(nil)
	var antigenTest = CurrentValueSubject<UserAntigenTest?, Never>(nil)

	var antigenTestIsOutdated = CurrentValueSubject<Bool, Never>(false)

	var pcrTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)
	var antigenTestResultIsLoading = CurrentValueSubject<Bool, Never>(false)

	func coronaTest(ofType type: CoronaTestType) -> UserCoronaTest? {
		switch type {
		case .pcr:
			return pcrTest.value.map { .pcr($0) }
		case .antigen:
			return antigenTest.value.map { .antigen($0) }
		}
	}
	
	// This function is responsible to register a PCR test from QR Code
	func registerPCRTestAndGetResult(
		guid: String,
		qrCodeHash: String,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		var certificateConsentGiven = false
		var dateOfBirthKey: String?
		if case let .given(givenDateOfBirth) = certificateConsent,
		   let dateOfBirthString = givenDateOfBirth,
		   let generatedDateOfBirthKey = hashedKey(dateOfBirthString: dateOfBirthString, guid: guid) {
			certificateConsentGiven = true
			dateOfBirthKey = generatedDateOfBirthKey
		}

		Log.info("[CoronaTestService] Registering PCR test (guid: \(private: guid, public: "GUID ID"), isSubmissionConsentGiven: \(isSubmissionConsentGiven), certificateConsentGiven: \(certificateConsentGiven)), dateOfBirthKey: \(private: String(describing: dateOfBirthKey))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(guid),
			withType: .guid,
			dateOfBirthKey: dateOfBirthKey,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					if self?.pcrTest.value != nil {
						self?.moveTestToBin(.pcr)
					}

					self?.pcrTest.value = UserPCRTest(
						registrationDate: Date(),
						registrationToken: registrationToken,
						qrCodeHash: qrCodeHash,
						testResult: .pending,
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false,
						certificateSupportedByPointOfCare: true,
						certificateConsentGiven: certificateConsentGiven,
						certificateRequested: false
					)

					Log.info("[CoronaTestService] PCR test registered: \(private: String(describing: self?.pcrTest.value), public: "PCR Test result")", log: .api)

					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken, .pcr)))
					// updating badge count for home tab
					if markAsUnseen {
						self?.badgeWrapper.increase(.unseenTests, by: 1)
					}

					self?.getTestResult(for: .pcr, duringRegistration: true) { result in
						completion(result)
					}
				case .failure(let error):
					Log.error("[CoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}

	// This function is responsible to register a PCR test from TeleTAN
	func registerPCRTest(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping (Result<Void, CoronaTestServiceError>) -> Void
	) {
		Log.info("[CoronaTestService] Registering PCR test (teleTAN: \(private: teleTAN, public: "teleTAN ID"), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: teleTAN,
			withType: .teleTan,
			dateOfBirthKey: nil,
			completion: { [weak self] result in
				self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()

				switch result {
				case .success(let registrationToken):
					if self?.pcrTest.value != nil {
						self?.moveTestToBin(.pcr)
					}

					 let _pcrTest = UserPCRTest(
						registrationDate: Date(),
						registrationToken: registrationToken,
						testResult: .positive,
						finalTestResultReceivedDate: Date(),
						positiveTestResultWasShown: true,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false,
						certificateSupportedByPointOfCare: true,
						certificateConsentGiven: false,
						certificateRequested: false
					)
					self?.pcrTest.value = _pcrTest

					Log.info("[CoronaTestService] PCR test registered: \(private: String(describing: self?.pcrTest.value), public: "PCR Test result")", log: .api)

					self?.createKeySubmissionMetadataDefaultValues(for: .pcr(_pcrTest))
					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken, .pcr)))
					Analytics.collect(.testResultMetadata(.updateTestResult(.positive, registrationToken, .pcr)))
					Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(true, .pcr)))

					// Because every test registered per teleTAN is positive, we can add this PCR test as positive in the contact diary.
					// testDate: For PCR -> registration date
					// testType: Always PCR
					// testResult: teleTan is always positive
					
					let stringDate = ISO8601DateFormatter.justLocalDateFormatter.string(from: _pcrTest.registrationDate)
					self?.diaryStore.addCoronaTest(
						testDate: stringDate,
						testType: CoronaTestType.pcr.rawValue,
						testResult: TestResult.positive.rawValue
					)
					self?.pcrTest.value?.journalEntryCreated = true
					
					completion(.success(()))
				case .failure(let error):
					Log.error("[CoronaTestService] PCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))
				}
			}
		)
	}
	
	func registerPCRTestAndGetResult(
		teleTAN: String,
		isSubmissionConsentGiven: Bool,
		completion: @escaping TestResultHandler
	) {
		registerPCRTest(teleTAN: teleTAN, isSubmissionConsentGiven: isSubmissionConsentGiven) { result in
			switch result {
			case .success:
				completion(.success(.positive))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	// swiftlint:disable:next function_parameter_count
	func registerAntigenTestAndGetResult(
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering antigen test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate), firstName: \(private: String(describing: firstName)), lastName: \(private: String(describing: lastName)), dateOfBirth: \(private: String(describing: dateOfBirth)), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(hash),
			withType: .guid,
			dateOfBirthKey: nil,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					if self?.antigenTest.value != nil {
						self?.moveTestToBin(.antigen)
					}

					var certificateConsentGiven = false
					if case .given = certificateConsent {
						certificateConsentGiven = true
					}

					self?.antigenTest.value = UserAntigenTest(
						pointOfCareConsentDate: pointOfCareConsentDate,
						registrationDate: Date(),
						registrationToken: registrationToken,
						qrCodeHash: qrCodeHash,
						testedPerson: TestedPerson(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth),
						testResult: .pending,
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false,
						certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
						certificateConsentGiven: certificateConsentGiven,
						certificateRequested: false
					)
					Log.info("[CoronaTestService] Antigen test registered: \(private: String(describing: self?.antigenTest.value), public: "Antigen test result")", log: .api)

					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken, .antigen)))

					// updating badge count for home tab
					if markAsUnseen {
						self?.badgeWrapper.increase(.unseenTests, by: 1)
					}

					self?.getTestResult(for: .antigen, duringRegistration: true) { result in
						completion(result)
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[CoronaTestService] Antigen test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	// swiftlint:disable:next function_parameter_count
	func registerRapidPCRTestAndGetResult(
		with hash: String,
		qrCodeHash: String,
		pointOfCareConsentDate: Date,
		firstName: String?,
		lastName: String?,
		dateOfBirth: String?,
		isSubmissionConsentGiven: Bool,
		markAsUnseen: Bool,
		certificateSupportedByPointOfCare: Bool,
		certificateConsent: TestCertificateConsent,
		completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Registering RapidPCR test (hash: \(private: hash), pointOfCareConsentDate: \(private: pointOfCareConsentDate), firstName: \(private: String(describing: firstName)), lastName: \(private: String(describing: lastName)), dateOfBirth: \(private: String(describing: dateOfBirth)), isSubmissionConsentGiven: \(isSubmissionConsentGiven))", log: .api)

		getRegistrationToken(
			forKey: ENAHasher.sha256(hash),
			withType: .guid,
			dateOfBirthKey: nil,
			completion: { [weak self] result in
				switch result {
				case .success(let registrationToken):
					if self?.pcrTest.value != nil {
						self?.moveTestToBin(.pcr)
					}

					var certificateConsentGiven = false
					if case .given = certificateConsent {
						certificateConsentGiven = true
					}

					self?.pcrTest.value = UserPCRTest(
						registrationDate: Date(),
						registrationToken: registrationToken,
						qrCodeHash: qrCodeHash,
						testResult: .pending,
						finalTestResultReceivedDate: nil,
						positiveTestResultWasShown: false,
						isSubmissionConsentGiven: isSubmissionConsentGiven,
						submissionTAN: nil,
						keysSubmitted: false,
						journalEntryCreated: false,
						certificateSupportedByPointOfCare: certificateSupportedByPointOfCare,
						certificateConsentGiven: certificateConsentGiven,
						certificateRequested: false
					)

					Log.info("[CoronaTestService] RapidPCR test registered: \(private: String(describing: self?.pcrTest.value), public: "RapidPCR test result")", log: .api)

					Analytics.collect(.testResultMetadata(.registerNewTestMetadata(Date(), registrationToken, .pcr)))

					// updating badge count for home tab
					if markAsUnseen {
						self?.badgeWrapper.increase(.unseenTests, by: 1)
					}

					self?.getTestResult(for: .pcr, duringRegistration: true) { result in
						completion(result)
					}

					self?.fakeRequestService.fakeSubmissionServerRequest()
				case .failure(let error):
					Log.error("[CoronaTestService] RapidPCR test registration failed: \(error.localizedDescription)", log: .api)

					completion(.failure(error))

					self?.fakeRequestService.fakeVerificationAndSubmissionServerRequest()
				}
			}
		)
	}
	
	func reregister(coronaTest: UserCoronaTest) {
		switch coronaTest {
		case .pcr(let pcrTest):
			self.pcrTest.value = pcrTest
		case .antigen(let antigenTest):
			self.antigenTest.value = antigenTest
		}

		scheduleWarnOthersNotificationIfNeeded(coronaTestType: coronaTest.type)
	}

	func updateTestResults(force: Bool = true, presentNotification: Bool, completion: @escaping VoidResultHandler) {
		if CWAHibernationProvider.shared.isHibernationState {
			Log.info("[CoronaTestService] Will not Update test results because of End of Life state. force: \(force), presentNotification: \(presentNotification)", log: .api)
			completion(.success(()))
			return
		}
		Log.info("[CoronaTestService] Update all test results. force: \(force), presentNotification: \(presentNotification)", log: .api)

		let group = DispatchGroup()
		var errors = [CoronaTestServiceError]()

		for coronaTestType in CoronaTestType.allCases {
			group.enter()
			Log.info("[CoronaTestService] Dispatch group entered in updateTestResults for (coronaTestType: \(coronaTestType))")
			
			updateTestResult(for: coronaTestType, force: force, presentNotification: presentNotification) { result in
				switch result {
				case .failure(let error):
					Log.error(error.localizedDescription, log: .api)
					errors.append(error)
				case .success:
					break
				}

				Log.info("[CoronaTestService] Dispatch group exited in updateTestResults for (coronaTestType: \(coronaTestType))")
				group.leave()
			}
		}

		group.notify(queue: .main) {
			if let error = errors.first {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
	}

	func updateTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool = true,
		presentNotification: Bool = false,
		completion: @escaping TestResultHandler
	) {
		if CWAHibernationProvider.shared.isHibernationState {
			Log.info("[CoronaTestService] Will not Update test result because of End of Life state. force: \(force), presentNotification: \(presentNotification)", log: .api)
			guard let coronaTest = coronaTest(ofType: coronaTestType) else {
				Log.error("[CoronaTestService] Getting test result failed: No corona test of requested type", log: .api)

				completion(.failure(.noCoronaTestOfRequestedType))
				return
			}
			Log.info("[CoronaTestService] Will return the latest cached test result because of End of Life state. force: \(force), presentNotification: \(presentNotification)", log: .api)
			completion(.success(coronaTest.testResult))
		}
		Log.info("[CoronaTestService] Updating test result (coronaTestType: \(coronaTestType)), force: \(force), presentNotification: \(presentNotification)", log: .api)
		
		getTestResult(for: coronaTestType, force: force, duringRegistration: false, presentNotification: presentNotification) { [weak self] result in
			Log.info("[CoronaTestService] Received test result from getTestResult: \(private: result)")
			
			guard let self = self else {
				completion(result)
				Log.warning("[CoronaTestService] Could not get self, skipping fakeRequestService call")
				return
			}

			self.fakeRequestService.fakeVerificationAndSubmissionServerRequest {
				completion(result)
			}
		}
	}

	func getSubmissionTAN(for coronaTestType: CoronaTestType, completion: @escaping SubmissionTANResultHandler) {
		Log.info("[CoronaTestService] Getting submission tan (coronaTestType: \(coronaTestType))", log: .api)

		guard let coronaTest = coronaTest(ofType: coronaTestType) else {
			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		if let submissionTAN = coronaTest.submissionTAN {
			completion(.success(submissionTAN))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			completion(.failure(.noRegistrationToken))
			return
		}
			let resource = RegistrationTokenResource(
				sendModel: RegistrationTokenSendModel(
					token: registrationToken
				)
			)
			restServiceProvider.load(resource) { result in
				switch result {
				case .success(let model):
					let submissionTAN = model.submissionTAN
					switch coronaTestType {
					case .pcr:
						self.pcrTest.value?.submissionTAN = submissionTAN
						self.pcrTest.value?.registrationToken = nil

						Log.info("Received submission tan for PCR test: \(private: String(describing: self.pcrTest.value), public: "PCR Test result")", log: .api)
					case .antigen:
						self.antigenTest.value?.submissionTAN = submissionTAN
						self.antigenTest.value?.registrationToken = nil

						Log.info("Received submission tan for antigen test: \(private: String(describing: self.antigenTest.value), public: "TAN for antigen test")", log: .api)
					}

					completion(.success(submissionTAN))

				case .failure(let error):
					Log.error("Getting submission tan failed: \(error.localizedDescription)", log: .api)

					completion(.failure(.registrationTokenError(error)))
				}
			}
	}

	func moveTestToBin(_ coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Moving test to bin (coronaTestType: \(coronaTestType)", log: .api)

		if let coronaTest = coronaTest(ofType: coronaTestType) {
			recycleBin.moveToBin(.userCoronaTest(coronaTest))
		}

		removeTest(coronaTestType)
	}

	func removeTest(_ coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Removing test (coronaTestType: \(coronaTestType)", log: .api)

		switch coronaTestType {
		case .pcr:
			pcrTest.value = nil
			// updating badge count for home tab
			badgeWrapper.decrease(.unseenTests, by: 1)
		case .antigen:
			antigenTest.value = nil
			// updating badge count for home tab
			badgeWrapper.decrease(.unseenTests, by: 1)
		}

		warnOthersReminder.cancelNotifications(for: coronaTestType)
		DeadmanNotificationManager().resetDeadmanNotification()
	}

	func evaluateShowingTest(ofType coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Evaluating showing test (coronaTestType: \(coronaTestType))", log: .api)

		switch coronaTestType {
		case .pcr where pcrTest.value?.testResult == .positive:
			pcrTest.value?.positiveTestResultWasShown = true

			Log.info("[CoronaTestService] Positive PCR test result was shown", log: .api)
		case .antigen where antigenTest.value?.testResult == .positive:
			antigenTest.value?.positiveTestResultWasShown = true

			Log.info("[CoronaTestService] Positive antigen test result was shown", log: .api)
		default:
			break
		}

		scheduleWarnOthersNotificationIfNeeded(coronaTestType: coronaTestType)
	}
	
	func evaluateSavingTestToDiary(ofTestType coronaTestType: CoronaTestType) {
		Log.info("[CoronaTestService] Evaluating saving test (coronaTestType: \(coronaTestType))", log: .api)

		guard let coronaTest = coronaTest(ofType: coronaTestType), coronaTest.testResult == .positive, !coronaTest.positiveTestResultWasShown else {
			Log.info("[CoronaTestService] will not save test to the diary (coronaTestType: \(coronaTestType))", log: .api)
			return
		}
		createCoronaTestEntryInContactDiary(coronaTestType: coronaTestType)
	}
	
	func updatePublishersFromStore() {
		Log.info("[CoronaTestService] Updating publishers from store", log: .api)

		if pcrTest.value != store.pcrTest {
			pcrTest.value = store.pcrTest

			Log.info("[CoronaTestService] PCR test updated from store", log: .api)
		}

		if antigenTest.value != store.antigenTest {
			antigenTest.value = store.antigenTest

			Log.info("[CoronaTestService] Antigen test updated from store", log: .api)
		}
	}

	func migrate() {
		let keysSubmitted = store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil
		if store.registrationToken != nil || keysSubmitted, let testRegistrationTimestamp = store.devicePairingConsentAcceptTimestamp {
			// The registration token is set to nil after submission, therefore we cannot fetch the result from the server and need
			// to infer a positive test result when keys were submitted. If the positive test result was shown we also can confidently set it to .positive.
			// For all other cases we set it to .pending and fetch the actual test result afterwards, as we did not store it in v2.0 and earlier.
			let testResult: TestResult = keysSubmitted || store.positiveTestResultWasShown ? .positive : .pending

			// In v2.0 and earlier the `positiveTestResultWasShown` property was reset on submission,
			// from v2.1 we keep it set to true even after the submission.
			let positiveTestResultWasShown = store.positiveTestResultWasShown || keysSubmitted

			pcrTest.value = UserPCRTest(
				registrationDate: Date(timeIntervalSince1970: TimeInterval(testRegistrationTimestamp)),
				registrationToken: store.registrationToken,
				testResult: testResult,
				finalTestResultReceivedDate: store.testResultReceivedTimeStamp.map { Date(timeIntervalSince1970: TimeInterval($0)) },
				positiveTestResultWasShown: positiveTestResultWasShown,
				isSubmissionConsentGiven: store.isSubmissionConsentGiven,
				submissionTAN: store.tan,
				keysSubmitted: keysSubmitted,
				journalEntryCreated: false,
				certificateSupportedByPointOfCare: true,
				certificateConsentGiven: false,
				certificateRequested: false
			)

			Log.info("[CoronaTestService] Migrated preexisting PCR test: \(private: String(describing: pcrTest), public: "PCR Test result")", log: .api)
		} else {
			Log.info("[CoronaTestService] No migration required (store.registrationToken: \(private: String(describing: store.registrationToken), public: "registration token ID"), store.lastSuccessfulSubmitDiagnosisKeyTimestamp: \(String(describing: store.lastSuccessfulSubmitDiagnosisKeyTimestamp)), store.devicePairingConsentAcceptTimestamp: \(String(describing: store.devicePairingConsentAcceptTimestamp))", log: .api)
		}

		store.registrationToken = nil
		store.teleTan = nil
		store.tan = nil
		store.testGUID = nil
		store.devicePairingConsentAccept = false
		store.devicePairingConsentAcceptTimestamp = nil
		store.devicePairingSuccessfulTimestamp = nil
		store.testResultReceivedTimeStamp = nil
		store.testRegistrationDate = nil
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = nil
		store.positiveTestResultWasShown = false
		store.isSubmissionConsentGiven = false
	}
	
	func healthCertificateTuple(for uniqueCertificateIdentifier: String) -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		var healthTuple: (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)?
		self.healthCertificateService.healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				if healthCertificate.uniqueCertificateIdentifier == uniqueCertificateIdentifier {
					healthTuple = (certificate: healthCertificate, certifiedPerson: healthCertifiedPerson)
				}
			}
		}
		return healthTuple
	}
	
	func createCoronaTestEntryInContactDiary(coronaTestType: CoronaTestType?) {
		if let coronaTestType = coronaTestType,
		   let coronaTest = coronaTest(ofType: coronaTestType),
		   (coronaTest.testResult == .positive || coronaTest.testResult == .negative) && !coronaTest.journalEntryCreated {
			let sampleDate: Date
			switch coronaTestType {
			case .pcr:
				pcrTest.value?.journalEntryCreated = true
				sampleDate = coronaTest.testDate
			case .antigen:
				antigenTest.value?.journalEntryCreated = true
				sampleDate = antigenTest.value?.sampleCollectionDate ?? coronaTest.testDate
			}
			// PCR -> registration date
			// antigen -> sample collection date if available otherwise we use point of care consent date
			// Warning: updatedSampleCollectionDate must get used because the service level struct antigenTest has changed and coronaTest wasn't updated
			//
			let stringDate = ISO8601DateFormatter.justLocalDateFormatter.string(from: sampleDate)
			Log.debug("Write test result to contact diary at date: \(stringDate)", log: .contactdiary)
			diaryStore.addCoronaTest(
				testDate: stringDate,
				testType: coronaTestType.rawValue,
				testResult: coronaTest.testResult.rawValue
			)
			
		}
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private var store: CoronaTestStoring & CoronaTestStoringLegacy
	private let eventStore: EventStoringProviding
	private let diaryStore: DiaryStoring
	private let appConfiguration: AppConfigurationProviding
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateRequestService: HealthCertificateRequestService
	private let ppacService: PrivacyPreservingAccessControl
	private let notificationCenter: UserNotificationCenter
	private let recycleBin: RecycleBin
	private let badgeWrapper: HomeBadgeWrapper
	private let serialQueue = AsyncOperation.serialQueue(named: "CoronaTestService.serialQueue")

	private let fakeRequestService: FakeRequestService
	private let warnOthersReminder: WarnOthersReminder

	private var outdatedStateTimer: Timer?
	private var antigenTestOutdatedDate: Date?

	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		pcrTest
			.sink { [weak self] pcrTest in
				self?.store.pcrTest = pcrTest

				if pcrTest?.keysSubmitted == true {
					self?.warnOthersReminder.cancelNotifications(for: .pcr)
				}
			}
			.store(in: &subscriptions)

		antigenTest
			.sink { [weak self] antigenTest in
				self?.store.antigenTest = antigenTest

				if antigenTest?.keysSubmitted == true {
					self?.warnOthersReminder.cancelNotifications(for: .antigen)
				}

				self?.antigenTestIsOutdated.value = false
				self?.antigenTestOutdatedDate = nil

				if let antigenTest = antigenTest {
					self?.setupOutdatedPublisher(for: antigenTest)
				}
			}
			.store(in: &subscriptions)
	}

	// internal for testing
	func getRegistrationToken(
		forKey key: String,
		withType type: KeyType,
		dateOfBirthKey: String?,
		completion: @escaping RegistrationResultHandler
	) {
		// Check if first char of dateOfBirthKey is a lower cased "x". If not, we fail because it is malformed. If dateOfBirthKey is nil, we pass this check.
		if let dateOfBirthKey = dateOfBirthKey {
			guard dateOfBirthKey.first == "x" else {
				completion(.failure(.malformedDateOfBirthKey))
				return
			}
		}

		let resource = TeleTanResource(
			sendModel: TeleTanSendModel(
				key: key,
				keyType: type,
				keyDob: dateOfBirthKey
			)
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				completion(.success(model.registrationToken))
			case .failure(let error):
				completion(.failure(.teleTanError(error)))
			}
		}
	}

	private func hashedKey(dateOfBirthString: String, guid: String) -> String? {
		guard let dateOfBirth = ISO8601DateFormatter.justUTCDateFormatter.date(from: dateOfBirthString) else {
			return nil
		}

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .utcTimeZone
		dateFormatter.dateFormat = "ddMMyyyy"
		let dateOfBirthString = dateFormatter.string(from: dateOfBirth)

		return "x\(ENAHasher.sha256("\(guid)\(dateOfBirthString)").dropFirst())"
	}

	// swiftlint:disable:next cyclomatic_complexity function_body_length
	private func getTestResult(
		for coronaTestType: CoronaTestType,
		force: Bool = true,
		duringRegistration: Bool,
		presentNotification: Bool = false,
		_ completion: @escaping TestResultHandler
	) {
		Log.info("[CoronaTestService] Getting test result (coronaTestType: \(coronaTestType), duringRegistration: \(duringRegistration))", log: .api)

		guard let coronaTest = coronaTest(ofType: coronaTestType) else {
			Log.error("[CoronaTestService] Getting test result failed: No corona test of requested type", log: .api)

			completion(.failure(.noCoronaTestOfRequestedType))
			return
		}

		guard let registrationToken = coronaTest.registrationToken else {
			Log.error("[CoronaTestService] Getting test result failed: No registration token", log: .api)

			completion(.failure(.noRegistrationToken))
			return
		}

		guard force || coronaTest.finalTestResultReceivedDate == nil else {
			Log.info("[CoronaTestService] Get test result completed early because final test result is present.", log: .api)
			completion(.success(coronaTest.testResult))
			return
		}

		let registrationDate = coronaTest.registrationDate ?? coronaTest.testDate
		let ageInDays = Calendar.current.dateComponents([.day], from: registrationDate, to: Date()).day ?? 0

		guard coronaTest.testResult != .expired || ageInDays < 21 else {
			Log.error("[CoronaTestService] Expired test result older than 21 days returned", log: .api)

			completion(.success(coronaTest.testResult))
			return
		}

		switch coronaTestType {
		case .pcr:
			pcrTestResultIsLoading.value = true
		case .antigen:
			antigenTestResultIsLoading.value = true
		}
		
		let operation = CoronaTestResultOperation(restService: restServiceProvider, registrationToken: registrationToken) { [weak self] result in
			guard let self = self else { return }

			switch coronaTestType {
			case .pcr:
				self.pcrTestResultIsLoading.value = false
			case .antigen:
				self.antigenTestResultIsLoading.value = false
			}

			#if DEBUG
			if isUITesting {
				completion(
					self.mockTestResult(for: coronaTestType).flatMap { .success($0) } ??
						.failure(.noCoronaTestOfRequestedType)
				)

				return
			}
			#endif

			switch result {
			case let .failure(error):
				Log.error("[CoronaTestService] Getting test result failed: \(error.localizedDescription)", log: .api)

				// For error .qrDoesNotExist we set the test result to expired
				if case let .receivedResourceError(ressourceError) = error, ressourceError == .qrDoesNotExist {
					Log.info("[CoronaTestService] Error Code 400 when getting test result, setting expired test result", log: .api)

					switch coronaTestType {
					case .pcr:
						self.pcrTest.value?.testResult = .expired
					case .antigen:
						self.antigenTest.value?.testResult = .expired
					}

					// For tests older than 21 days this should not be handled as an error
					if ageInDays >= 21 {
						Log.info("[CoronaTestService] Test older than 21 days, no error is returned", log: .api)

						completion(.success(.expired))
					} else {
						Log.error("[CoronaTestService] Test younger than 21 days, error is returned", log: .api)

						completion(.failure(.testResultError(error)))
					}
				} else {
					completion(.failure(.testResultError(error)))
				}
			case let .success(response):
				let testResult = TestResult(serverResponse: response.testResult, coronaTestType: coronaTestType)

				Log.info("[CoronaTestService] Got test result (coronaTestType: \(coronaTestType), testResult: \(testResult)), sampleCollectionDate: \(String(describing: response.sc))", log: .api)
				var updatedSampleCollectionDate: Date?

				switch coronaTestType {
				case .pcr:
					Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken, .pcr)))
					
					self.pcrTest.value?.testResult = testResult
				case .antigen:
					Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken, .antigen)))

					self.antigenTest.value?.testResult = testResult

					updatedSampleCollectionDate = response.sc.map {
						Date(timeIntervalSince1970: TimeInterval($0))
					}
					self.antigenTest.value?.sampleCollectionDate = updatedSampleCollectionDate
				}

				switch testResult {
				case .positive, .negative, .invalid:
					if case .positive = testResult, let coronaTest = self.coronaTest(ofType: coronaTestType), !coronaTest.keysSubmitted {
						self.createKeySubmissionMetadataDefaultValues(for: coronaTest)
					}
					// for negative result we save the result directly to the diary as there is no additional UI that the user has to go through unlike the positive test result where the user sees a "Test result is available" screen first.
					if case .negative = testResult {
						self.createCoronaTestEntryInContactDiary(coronaTestType: coronaTestType)
					}
					if self.coronaTest(ofType: coronaTestType)?.finalTestResultReceivedDate == nil {
						switch coronaTestType {
						case .pcr:
							self.pcrTest.value?.finalTestResultReceivedDate = Date()
						case .antigen:
							self.antigenTest.value?.finalTestResultReceivedDate = Date()
						}

						if testResult == .negative && coronaTest.certificateConsentGiven && !coronaTest.certificateRequested {
							self.healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
								coronaTestType: coronaTestType,
								registrationToken: registrationToken,
								registrationDate: registrationDate,
								retryExecutionIfCertificateIsPending: true,
								labId: response.labId
							)

							switch coronaTestType {
							case .pcr:
								self.pcrTest.value?.certificateRequested = true
							case .antigen:
								self.antigenTest.value?.certificateRequested = true
							}
						}

						if presentNotification && !CWAHibernationProvider.shared.isHibernationState {
							Log.info("[CoronaTestService] Triggering Notification (coronaTestType: \(coronaTestType), testResult: \(testResult))", log: .api)
							
							// We attach the test result and type to determine which screen to show when user taps the notification
							self.notificationCenter.presentNotification(
								title: AppStrings.LocalNotifications.testResultsTitle,
								body: AppStrings.LocalNotifications.testResultsBody,
								identifier: ActionableNotificationIdentifier.testResult.identifier,
								info: [
									ActionableNotificationIdentifier.testResult.identifier: testResult.rawValue,
									ActionableNotificationIdentifier.testResultType.identifier: coronaTestType.rawValue
								]
							)
						}
					}


					if duringRegistration {
						Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.registeredTest(coronaTestType))))
						Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.registeredTest(coronaTestType))))
						Analytics.collect(.keySubmissionMetadata(.setHoursSinceCheckinHighRiskWarningAtTestRegistration(.registeredTest(coronaTestType))))
						Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration(.registeredTest(coronaTestType))))
					}

					completion(.success(testResult))
				case .pending:
					completion(.success(testResult))
				case .expired:
					if duringRegistration {
						// The .expired status is only known after the test has been registered on the server
						// so we generate an error here, even if the server returned the http result 201
						completion(.failure(.testExpired))
					} else {
						completion(.success(testResult))
					}
				}
			}
		}

		serialQueue.addOperation(operation)
	}

	private func setupOutdatedPublisher(for antigenTest: UserAntigenTest) {
		// Only rapid antigen tests with a negative test result can become outdated
		guard antigenTest.testResult == .negative else {
			return
		}

		let hoursToDeemTestOutdated = appConfiguration.currentAppConfig.value
			.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated

		guard
			hoursToDeemTestOutdated != 0,
			let outdatedDate = Calendar.current.date(byAdding: .hour, value: Int(hoursToDeemTestOutdated), to: antigenTest.testDate)
		else {
			return
		}

		if Date() >= outdatedDate {
			antigenTestIsOutdated.value = true
		} else {
			antigenTestOutdatedDate = outdatedDate
			scheduleOutdatedStateTimer()
		}
	}

	private func scheduleWarnOthersNotificationIfNeeded(coronaTestType: CoronaTestType) {
		if let coronaTest = coronaTest(ofType: coronaTestType), coronaTest.testResult == .positive, coronaTest.positiveTestResultWasShown {
			DeadmanNotificationManager().resetDeadmanNotification()

			if !coronaTest.isSubmissionConsentGiven, !coronaTest.keysSubmitted, !CWAHibernationProvider.shared.isHibernationState {
				warnOthersReminder.scheduleNotifications(for: coronaTestType)
			}
		}
	}

	private func createKeySubmissionMetadataDefaultValues(for coronaTest: UserCoronaTest) {
		let submittedAfterRapidAntigenTest: Bool
		switch coronaTest {
		case .pcr:
			submittedAfterRapidAntigenTest = false
		case .antigen:
			submittedAfterRapidAntigenTest = true
		}

		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: coronaTest.isSubmissionConsentGiven,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedWithTeleTAN: false,
			submittedAfterRapidAntigenTest: submittedAfterRapidAntigenTest,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: false
		)

		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .registeredTest(coronaTest.type))))
		Analytics.collect(.keySubmissionMetadata(.setDaysSinceMostRecentDateAtENFRiskLevelAtTestRegistration(.registeredTest(coronaTest.type))))
		Analytics.collect(.keySubmissionMetadata(.setHoursSinceENFHighRiskWarningAtTestRegistration(.registeredTest(coronaTest.type))))
	}

	private func scheduleOutdatedStateTimer() {
		outdatedStateTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		guard let antigenTestOutdatedDate = antigenTestOutdatedDate else {
			return
		}

		// Schedule new timer.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUpdateTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		outdatedStateTimer = Timer(fireAt: antigenTestOutdatedDate, interval: 0, target: self, selector: #selector(updateFromTimer), userInfo: nil, repeats: false)

		guard let outdatedStateTimer = outdatedStateTimer else { return }
		RunLoop.current.add(outdatedStateTimer, forMode: .common)
	}

	private func setUniqueCertificateIdentifier(_ uniqueCertificateIdentifier: String, from testCertificateRequest: TestCertificateRequest) {
		switch testCertificateRequest.coronaTestType {
		case .pcr:
			if self.pcrTest.value?.registrationToken == testCertificateRequest.registrationToken {
				pcrTest.value?.uniqueCertificateIdentifier = uniqueCertificateIdentifier
			}
		case .antigen:
			if self.antigenTest.value?.registrationToken == testCertificateRequest.registrationToken {
				self.antigenTest.value?.uniqueCertificateIdentifier = uniqueCertificateIdentifier
			}
		}
		
		setUniqueCertificateIdentifierForRecycleBinItemsIfNeeded(uniqueCertificateIdentifier, from: testCertificateRequest)
	}
	
	// For Edge Cases, if a Test Certificate was received, after the Test Result was moved to recycle bin.
	// The method sets the Unique Certificate Identifier (UCI) in the corresponding item.
	private func setUniqueCertificateIdentifierForRecycleBinItemsIfNeeded(_ uniqueCertificateIdentifier: String, from testCertificateRequest: TestCertificateRequest) {
		switch testCertificateRequest.coronaTestType {
		case .pcr:
			recycleBin.recycledItems.forEach { recycleBinItem in
				if case let .userCoronaTest(userCoronaTest) = recycleBinItem.item,
					userCoronaTest.registrationToken == testCertificateRequest.registrationToken {
					
					if case let .pcr(userPCRTest) = userCoronaTest {
						var userPCRTestValueCopy = userPCRTest
						userPCRTestValueCopy.set(uniqueCertificateIdentifier: uniqueCertificateIdentifier)
						
						// Write the item with the UCI
						recycleBin.moveToBin(.userCoronaTest(.pcr(userPCRTestValueCopy)))
						// Remove the item without the UCI
						recycleBin.remove(recycleBinItem)
					}
				}
			}

		case .antigen:
			recycleBin.recycledItems.forEach { recycleBinItem in
				if case let .userCoronaTest(userCoronaTest) = recycleBinItem.item,
					userCoronaTest.registrationToken == testCertificateRequest.registrationToken {
					
					if case let .antigen(userAntigenTest) = userCoronaTest {
						var userAntigenTestValueCopy = userAntigenTest
						userAntigenTestValueCopy.set(uniqueCertificateIdentifier: uniqueCertificateIdentifier)
						
						// Write the item with the UCI
						recycleBin.moveToBin(.userCoronaTest(.antigen(userAntigenTestValueCopy)))
						// Remove the item without the UCI
						recycleBin.remove(recycleBinItem)
					}
				}
			}
		}
	}

	@objc
	private func invalidateTimer() {
		outdatedStateTimer?.invalidate()
	}

	@objc
	private func refreshUpdateTimerAfterResumingFromBackground() {
		updateFromTimer()
		scheduleOutdatedStateTimer()
	}

	@objc
	private func updateFromTimer() {
		guard let antigenTestOutdatedDate = antigenTestOutdatedDate else {
			return
		}

		antigenTestIsOutdated.value = Date() >= antigenTestOutdatedDate
	}

	#if DEBUG

	private var mockPCRTest: UserPCRTest? {
		if let testResult = mockTestResult(for: .pcr) {
			return UserPCRTest(
				registrationDate: Date(),
				registrationToken: "asdf",
				testResult: testResult,
				finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
				positiveTestResultWasShown: LaunchArguments.test.pcr.positiveTestResultWasShown.boolValue,
				isSubmissionConsentGiven: LaunchArguments.test.pcr.isSubmissionConsentGiven.boolValue,
				submissionTAN: nil,
				keysSubmitted: LaunchArguments.test.pcr.keysSubmitted.boolValue,
				journalEntryCreated: false,
				certificateSupportedByPointOfCare: true,
				certificateConsentGiven: false,
				certificateRequested: false
			)
		} else {
			return nil
		}
	}

	private var mockAntigenTest: UserAntigenTest? {
		if let testResult = mockTestResult(for: .antigen) {
			return UserAntigenTest(
				pointOfCareConsentDate: Date(),
				registrationDate: Date(),
				registrationToken: "zxcv",
				testedPerson: TestedPerson(firstName: "Erika", lastName: "Mustermann", dateOfBirth: "1964-08-12"),
				testResult: testResult,
				finalTestResultReceivedDate: testResult == .pending ? nil : Date(),
				positiveTestResultWasShown: LaunchArguments.test.antigen.positiveTestResultWasShown.boolValue,
				isSubmissionConsentGiven: LaunchArguments.test.antigen.isSubmissionConsentGiven.boolValue,
				submissionTAN: nil,
				keysSubmitted: LaunchArguments.test.antigen.keysSubmitted.boolValue,
				journalEntryCreated: false,
				certificateSupportedByPointOfCare: false,
				certificateConsentGiven: false,
				certificateRequested: false
			)
		} else {
			return nil
		}
	}

	private func mockTestResult(for coronaTestType: CoronaTestType) -> TestResult? {
		switch coronaTestType {
		case .pcr:
			return LaunchArguments.test.pcr.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .pcr) }
		case .antigen:
			return LaunchArguments.test.antigen.testResult.stringValue.flatMap { TestResult(stringValue: $0, coronaTestType: .antigen) }
		}
	}

	func mockHealthCertificateTuple() -> (certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson)? {
		guard let certificate = self.healthCertificateService.healthCertifiedPersons[0].testCertificates.first else { return nil }
		let certifiedPerson = self.healthCertificateService.healthCertifiedPersons[0]
		
		return (certificate: certificate, certifiedPerson: certifiedPerson)
	}

	#endif

	// swiftlint:disable:next file_length
}
