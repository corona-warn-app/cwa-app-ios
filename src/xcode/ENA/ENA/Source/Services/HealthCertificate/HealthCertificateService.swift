//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit
import UserNotifications

// global to access in unit tests
// version will be used for migration logic
public let kCurrentHealthCertifiedPersonsVersion = 2

// swiftlint:disable:next type_body_length
class HealthCertificateService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		dccSignatureVerifier: DCCSignatureVerifying,
		dscListProvider: DSCListProviding,
		client: Client,
		appConfiguration: AppConfigurationProviding,
		digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol = DigitalCovidCertificateAccess(),
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		boosterNotificationsService: BoosterNotificationsServiceProviding,
		recycleBin: RecycleBin
	) {
		#if DEBUG
		if isUITesting {
			let store = MockTestStore()

			self.store = store
			self.dccSignatureVerifier = dccSignatureVerifier
			self.dscListProvider = DSCListProvider(client: CachingHTTPClientMock(), store: store)
			self.client = ClientMock()
			self.appConfiguration = CachedAppConfigurationMock(store: store)
			self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
			self.notificationCenter = notificationCenter
			self.boosterNotificationsService = boosterNotificationsService
			self.recycleBin = recycleBin
			setup()
			configureForTesting()

			return
		}
		#endif

		self.store = store
		self.dccSignatureVerifier = dccSignatureVerifier
		self.dscListProvider = dscListProvider
		self.client = client
		self.appConfiguration = appConfiguration
		self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
		self.notificationCenter = notificationCenter
		self.boosterNotificationsService = boosterNotificationsService
		self.recycleBin = recycleBin

		setup()
	}

	// MARK: - Internal

	@DidSetPublished private(set) var healthCertifiedPersons = [HealthCertifiedPerson]() {
		didSet {
			let personsAddedOrRemoved = oldValue.map({ "\(String(describing: $0.name?.fullName))\(String(describing: $0.dateOfBirth))" }) != healthCertifiedPersons.map({ "\(String(describing: $0.name?.fullName))\(String(describing: $0.dateOfBirth))" })

			if initialHealthCertifiedPersonsReadFromStore {
				store.healthCertifiedPersons = healthCertifiedPersons
			}

			let unseenNewsCount = healthCertifiedPersons.map { $0.unseenNewsCount }.reduce(0, +)
			if self.unseenNewsCount.value != unseenNewsCount {
				self.unseenNewsCount.value = unseenNewsCount
			}

			if personsAddedOrRemoved {
				updateHealthCertifiedPersonSubscriptions(for: healthCertifiedPersons)
			}
		}
	}

	@DidSetPublished private(set) var testCertificateRequests = [TestCertificateRequest]() {
		didSet {
			if initialTestCertificateRequestsReadFromStore {
				store.testCertificateRequests = testCertificateRequests
			}

			updateTestCertificateRequestSubscriptions(for: testCertificateRequests)
		}
	}

	private(set) var unseenNewsCount = CurrentValueSubject<Int, Never>(0)
	var didRegisterTestCertificate: ((String, TestCertificateRequest) -> Void)?
	
	var nextValidityTimer: Timer?
	var boosterNotificationsService: BoosterNotificationsServiceProviding
	var nextFireDate: Date? {
		let healthCertificates = healthCertifiedPersons
			.flatMap { $0.healthCertificates }
		let signingCertificates = dscListProvider.signingCertificates.value

		let allValidUntilDates = validUntilDates(for: healthCertificates, signingCertificates: signingCertificates)
		let allExpirationDates = expirationDates(for: healthCertificates)
		let allDatesToExam = (allValidUntilDates + allExpirationDates)
			.filter { date in
				date.timeIntervalSinceNow.sign == .plus
			}
		return allDatesToExam.min()
	}
	
	/*
	Trigger this on:
		- when the app comes into foreground
		- when the regular background execution runs (e.g. Key Download)
	*/
	
	func checkIfBoosterRulesShouldBeFetched(completion: @escaping(String?) -> Void) {
		if let lastExecutionDate = store.lastBoosterNotificationsExecutionDate,
		   Calendar.utcCalendar.isDateInToday(lastExecutionDate) {
			let errorMessage = "general: Booster Notifications rules was already Download today, will be skipped..."
			Log.info(errorMessage, log: .vaccination)
			completion(errorMessage)
		} else {
			Log.info("Booster Notifications rules Will Download...", log: .vaccination)
			applyBoosterRulesForHealthCertificates(completion: completion)
		}
	}
	
	private func applyBoosterRulesForHealthCertificates(completion: @escaping(String?) -> Void) {
		healthCertifiedPersons.forEach { healthCertifiedPerson in
			applyBoosterRulesForHealthCertificatesOfAPerson(healthCertifiedPerson: healthCertifiedPerson, completion: completion)
		}
	}
	
	@discardableResult
	func registerHealthCertificate(
		base45: Base45,
		checkSignatureUpfront: Bool = true,
		markAsNew: Bool = false
	) -> Result<CertificateResult, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		// If the certificate is in the recycle bin, restore it and skip registration process.
		if let recycleBinItem = recycleBin.item(for: base45), case let .certificate(healthCertificate) = recycleBinItem.item {
			let healthCertifiedPerson = registeredHealthCertifiedPerson(for: healthCertificate) ?? HealthCertifiedPerson(healthCertificates: [])
			addHealthCertificate(healthCertificate, to: healthCertifiedPerson)
			recycleBin.remove(recycleBinItem)

			return .success(
				CertificateResult(
					registrationDetail: .restoredFromBin,
					person: healthCertifiedPerson,
					certificate: healthCertificate
				)
			)
		}

		do {
			let healthCertificate = try HealthCertificate(base45: base45, isNew: markAsNew)

			// check signature
			if checkSignatureUpfront {
				if case .failure(let error) = dccSignatureVerifier.verify(
					certificate: base45,
					with: dscListProvider.signingCertificates.value,
					and: Date()
				) {
					return .failure(.invalidSignature(error))
				}
			}

			if healthCertificate.hasTooManyEntries {
				Log.error("[HealthCertificateService] Registering health certificate failed: certificate has too many entries", log: .api)
				return .failure(.certificateHasTooManyEntries)
			}

			var healthCertifiedPerson: HealthCertifiedPerson
			var personWarnThresholdReached = false

			if let registeredHealthCertifiedPerson = registeredHealthCertifiedPerson(for: healthCertificate) {
				healthCertifiedPerson = registeredHealthCertifiedPerson
			} else {
				if healthCertifiedPersons.count >= appConfiguration.featureProvider.intValue(for: .dccPersonCountMax) {
					return .failure(.tooManyPersonsRegistered)
				}

				if healthCertifiedPersons.count + 1 >= appConfiguration.featureProvider.intValue(for: .dccPersonWarnThreshold) {
					personWarnThresholdReached = true
				}

				healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
			}

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: {
					$0.uniqueCertificateIdentifier == healthCertificate.uniqueCertificateIdentifier
				})
			if isDuplicate {
				Log.error("[HealthCertificateService] Registering health certificate failed: certificate already registered", log: .api)
				return .failure(.certificateAlreadyRegistered(healthCertificate.type))
			}

			addHealthCertificate(healthCertificate, to: healthCertifiedPerson)

			return .success(
				CertificateResult(
					registrationDetail: personWarnThresholdReached ? .personWarnThresholdReached : nil,
					person: healthCertifiedPerson,
					certificate: healthCertificate
				)
			)

		} catch let error as CertificateDecodingError {
			Log.error("[HealthCertificateService] Registering health certificate failed with .decodingError: \(error.localizedDescription)", log: .api)
			return .failure(.decodingError(error))
		} catch {
			return .failure(.other(error))
		}
	}

	func registeredHealthCertifiedPerson(for healthCertificate: HealthCertificate) -> HealthCertifiedPerson? {
		healthCertifiedPersons
			.first(where: {
				$0.healthCertificates.first?.name.groupingStandardizedName == healthCertificate.name.groupingStandardizedName &&
				$0.healthCertificates.first?.dateOfBirthDate == healthCertificate.dateOfBirthDate
			})
	}

	func addHealthCertificate(_ healthCertificate: HealthCertificate) {
		addHealthCertificate(
			healthCertificate,
			to: registeredHealthCertifiedPerson(for: healthCertificate) ?? HealthCertifiedPerson(healthCertificates: [])
		)
	}

	func addHealthCertificate(_ healthCertificate: HealthCertificate, to healthCertifiedPerson: HealthCertifiedPerson) {
		healthCertifiedPerson.healthCertificates.append(healthCertificate)
		healthCertifiedPerson.healthCertificates.sort(by: <)

		if !healthCertifiedPersons.contains(healthCertifiedPerson) {
			Log.info("[HealthCertificateService] Successfully registered health certificate for a new person", log: .api)
			healthCertifiedPersons = (healthCertifiedPersons + [healthCertifiedPerson]).sorted()
			updateValidityStatesAndNotifications()
			updateGradients()
		} else {
			Log.info("[HealthCertificateService] Successfully registered health certificate for a person with other existing certificates", log: .api)
		}

		applyBoosterRulesForHealthCertificatesOfAPerson(healthCertifiedPerson: healthCertifiedPerson) { errorMessage in
			guard let errorMessage = errorMessage else { return }
			Log.error(errorMessage, log: .vaccination, error: nil)
		}

		if healthCertificate.type != .test {
			createNotifications(for: healthCertificate)
		}
	}

	func moveHealthCertificateToBin(_ healthCertificate: HealthCertificate) {
		for healthCertifiedPerson in healthCertifiedPersons {
			if let index = healthCertifiedPerson.healthCertificates.firstIndex(of: healthCertificate) {
				healthCertifiedPerson.healthCertificates.remove(at: index)
				Log.info("[HealthCertificateService] Removed health certificate at index \(index)", log: .api)

				if healthCertifiedPerson.healthCertificates.isEmpty {
					healthCertifiedPersons = healthCertifiedPersons
						.filter { $0 != healthCertifiedPerson }
						.sorted()
					updateGradients()

					Log.info("[HealthCertificateService] Removed health certified person", log: .api)
				}
				break
			}
		}
		// we do not have to wait here, so we leave the completion empty
		removeAllNotifications(for: healthCertificate, completion: {})

		// Move HealthCertificate to the recycle-bin
		recycleBin.moveToBin(.certificate(healthCertificate))
	}

	func registerAndExecuteTestCertificateRequest(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date,
		retryExecutionIfCertificateIsPending: Bool,
		labId: String?,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		Log.info("[HealthCertificateService] Registering test certificate request: (coronaTestType: \(coronaTestType), registrationToken: \(private: registrationToken), registrationDate: \(registrationDate), retryExecutionIfCertificateIsPending: \(retryExecutionIfCertificateIsPending)", log: .api)

		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: coronaTestType,
			registrationToken: registrationToken,
			registrationDate: registrationDate,
			labId: labId
		)

		testCertificateRequests.append(testCertificateRequest)

		executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: retryExecutionIfCertificateIsPending,
			completion: completion
		)
	}

	// swiftlint:disable:next cyclomatic_complexity
	func executeTestCertificateRequest(
		_ testCertificateRequest: TestCertificateRequest,
		retryIfCertificateIsPending: Bool,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)? = nil
	) {
		Log.info("[HealthCertificateService] Executing test certificate request: \(private: testCertificateRequest)", log: .api)

		testCertificateRequest.isLoading = true

		// If we didn't retrieve a labId for a PRC test result, the lab is not supporting test certificates.
		if testCertificateRequest.coronaTestType == .pcr && testCertificateRequest.labId == nil {
			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.dgcNotSupportedByLab))
			return
		}

		do {
			let rsaKeyPair = try testCertificateRequest.rsaKeyPair ?? DCCRSAKeyPair(registrationToken: testCertificateRequest.registrationToken)
			testCertificateRequest.rsaKeyPair = rsaKeyPair
			let publicKey = try rsaKeyPair.publicKeyForBackend()

			appConfiguration.appConfiguration()
				.sink { [weak self] in
					guard let self = self else { return }

					var waitAfterPublicKeyRegistrationInSeconds = TimeInterval($0.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds)

					var waitForRetryInSeconds = TimeInterval($0.dgcParameters.testCertificateParameters.waitForRetryInSeconds)

					// 0 means the value is not set -> setting it to a default waiting time of 10 seconds
					if waitAfterPublicKeyRegistrationInSeconds == 0 {
						waitAfterPublicKeyRegistrationInSeconds = 10
					}

					if waitForRetryInSeconds == 0 {
						waitForRetryInSeconds = 10
					}

					Log.info("[HealthCertificateService] waitAfterPublicKeyRegistrationInSeconds: \(waitAfterPublicKeyRegistrationInSeconds), waitForRetryInSeconds: \(waitForRetryInSeconds)", log: .api)

					if !testCertificateRequest.rsaPublicKeyRegistered {
						Log.info("[HealthCertificateService] Registering public key …", log: .api)

						self.client.dccRegisterPublicKey(
							isFake: false,
							token: testCertificateRequest.registrationToken,
							publicKey: publicKey,
							completion: { result in
								switch result {
								case .success:
									Log.info("[HealthCertificateService] Public key successfully registered", log: .api)

									testCertificateRequest.rsaPublicKeyRegistered = true
									DispatchQueue.global().asyncAfter(deadline: .now() + waitAfterPublicKeyRegistrationInSeconds) {
										self.requestDigitalCovidCertificate(
											for: testCertificateRequest,
											rsaKeyPair: rsaKeyPair,
											retryIfCertificateIsPending: retryIfCertificateIsPending,
											waitForRetryInSeconds: waitForRetryInSeconds,
											completion: completion
										)
									}
								case .failure(let registrationError) where registrationError == .tokenAlreadyAssigned:
									Log.info("[HealthCertificateService] Public key was already registered.", log: .api)

									testCertificateRequest.rsaPublicKeyRegistered = true
									testCertificateRequest.isLoading = false
									self.requestDigitalCovidCertificate(
										for: testCertificateRequest,
										rsaKeyPair: rsaKeyPair,
										retryIfCertificateIsPending: retryIfCertificateIsPending,
										waitForRetryInSeconds: waitForRetryInSeconds,
										completion: completion
									)
								case .failure(let registrationError):
									Log.error("[HealthCertificateService] Public key registration failed: \(registrationError.localizedDescription)", log: .api)

									testCertificateRequest.requestExecutionFailed = true
									testCertificateRequest.isLoading = false
									completion?(.failure(.publicKeyRegistrationFailed(registrationError)))
								}
							}
						)
					} else if let encryptedDEK = testCertificateRequest.encryptedDEK,
							  let encryptedCOSE = testCertificateRequest.encryptedCOSE {
						Log.info("[HealthCertificateService] Encrypted COSE and DEK already exist, immediately assembling certificate.", log: .api)

						self.assembleDigitalCovidCertificate(
							for: testCertificateRequest,
							rsaKeyPair: rsaKeyPair,
							encryptedDEK: encryptedDEK,
							encryptedCOSE: encryptedCOSE,
							completion: completion
						)
					} else {
						Log.info("[HealthCertificateService] Public key already registered, immediately requesting certificate.", log: .api)

						self.requestDigitalCovidCertificate(
							for: testCertificateRequest,
							rsaKeyPair: rsaKeyPair,
							retryIfCertificateIsPending: retryIfCertificateIsPending,
							waitForRetryInSeconds: waitForRetryInSeconds,
							completion: completion
						)
					}
				}
				.store(in: &subscriptions)
		} catch let error as DCCRSAKeyPairError {
			Log.error("[HealthCertificateService] Key pair error occurred: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.rsaKeyPairGenerationFailed(error)))
		} catch {
			Log.error("[HealthCertificateService] Error occurred: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.other(error)))
		}
	}

	func remove(testCertificateRequest: TestCertificateRequest) {
		testCertificateRequest.rsaKeyPair?.removeFromKeychain()
		if let index = testCertificateRequests.firstIndex(of: testCertificateRequest) {
			testCertificateRequests.remove(at: index)
		}
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons = store.healthCertifiedPersons
		initialHealthCertifiedPersonsReadFromStore = true

		testCertificateRequests = store.testCertificateRequests
		initialTestCertificateRequestsReadFromStore = true

		updateHealthCertifiedPersonSubscriptions(for: healthCertifiedPersons)
	}

	func migration() {
		// at the moment we only have 1 migration step
		// if more is needed we should add a migration serial queue
		let lastVersion = store.healthCertifiedPersonsVersion ?? 0
		guard lastVersion < kCurrentHealthCertifiedPersonsVersion else {
			Log.debug("Migration was done already - stop here")
			return
		}
		defer {
			// after leaving mark migration as done
			store.healthCertifiedPersonsVersion = kCurrentHealthCertifiedPersonsVersion
		}

		let originalHealthCertifiedPersons = store.healthCertifiedPersons
		let groupedPersons = Dictionary(grouping: store.healthCertifiedPersons) { (person: HealthCertifiedPerson) -> String in
			guard let firstHealthCertificate = person.healthCertificates.first else { return "" }

			return "\(firstHealthCertificate.name.groupingStandardizedName)<<\(DCCDateStringFormatter.formattedString(from: firstHealthCertificate.dateOfBirth))"
		}

		var newHealthCertifiedPersons = [HealthCertifiedPerson]()
		for personGroup in groupedPersons {
			if personGroup.value.count > 1 {
				let combinedHealthCertifiedPerson = HealthCertifiedPerson(
					healthCertificates: personGroup.value.flatMap { $0.healthCertificates }.sorted(by: <),
					isPreferredPerson: personGroup.value.contains { $0.isPreferredPerson },
					boosterRule: nil,
					isNewBoosterRule: false
				)
				newHealthCertifiedPersons.append(combinedHealthCertifiedPerson)
			} else {
				newHealthCertifiedPersons.append(contentsOf: personGroup.value)
			}
		}
		newHealthCertifiedPersons.sort()

		if originalHealthCertifiedPersons != newHealthCertifiedPersons {
			Log.debug("Did update grouping name of certificates")
			store.healthCertifiedPersons = newHealthCertifiedPersons
		}
	}

	func updateValidityStatesAndNotificationsWithFreshDSCList(shouldScheduleTimer: Bool = true, completion: () -> Void) {
		// .dropFirst: drops the first callback, which is called with default signing certificates.
		// .first: only executes 1 element and no subsequent elements.
		// This way only the 2. call with freshly fetched signing certificates is executed.
		dscListProvider.signingCertificates
			.dropFirst()
			.first()
			.sink { [weak self] _ in
				self?.updateValidityStatesAndNotifications(shouldScheduleTimer: shouldScheduleTimer)
			}
			.store(in: &subscriptions)
	}

	func updateValidityStatesAndNotifications(shouldScheduleTimer: Bool = true) {
		let currentAppConfiguration = appConfiguration.currentAppConfig.value
		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				let expirationThresholdInDays = currentAppConfiguration.dgcParameters.expirationThresholdInDays
				let expiringSoonDate = Calendar.current.date(
					byAdding: .day,
					value: -Int(expirationThresholdInDays),
					to: healthCertificate.expirationDate
				)

				let previousValidityState = healthCertificate.validityState

				let blockedIdentifierChunks = appConfiguration.currentAppConfig.value
					.dgcParameters.blockListParameters.blockedUvciChunks
				if healthCertificate.isBlocked(by: blockedIdentifierChunks) {
					healthCertificate.validityState = .blocked
				} else {
					let signatureVerificationResult = self.dccSignatureVerifier.verify(
						certificate: healthCertificate.base45,
						with: self.dscListProvider.signingCertificates.value,
						and: Date()
					)

					switch signatureVerificationResult {
					case .success:
						if Date() >= healthCertificate.expirationDate {
							healthCertificate.validityState = .expired
						} else if let expiringSoonDate = expiringSoonDate, Date() >= expiringSoonDate {
							healthCertificate.validityState = .expiringSoon
						} else {
							healthCertificate.validityState = .valid
						}
					case .failure:
						healthCertificate.validityState = .invalid
					}
				}

				if healthCertificate.validityState != previousValidityState {
					/// Only validity states that are not shown as `.valid` should be marked as new for the user.
					healthCertificate.isValidityStateNew = !healthCertificate.isConsideredValid
				}

				healthCertifiedPerson.triggerMostRelevantCertificateUpdate()
			}
		}
		if shouldScheduleTimer {
			scheduleTimer()
		}
		
		self.updateNotifications()
	}

	func validUntilDates(for healthCertificates: [HealthCertificate], signingCertificates: [DCCSigningCertificate]) -> [Date] {
		let dccValidation = DCCSignatureVerification()
		return healthCertificates
			.map { certificate in
				dccValidation.validUntilDate(certificate: certificate.base45, with: signingCertificates)
			}
			.compactMap { result -> Date? in
				switch result {
				case let .success(date):
					return date

				case let .failure(error):
					Log.error("Error while validating certificate \(error.localizedDescription)")
					return nil
				}
			}
	}

	func expirationDates(for healthCertificates: [HealthCertificate]) -> [Date] {
		return healthCertificates.map { $0.expirationDate }
	}

	@objc
	func scheduleTimer() {
		invalidateTimer()
		guard let fireDate = nextFireDate,
			fireDate.timeIntervalSinceNow > 0 else {
			Log.info("no next date in the future found - can't schedule timer")
			return
		}

		Log.info("Schedule validity timer in \(fireDate.timeIntervalSinceNow) seconds")
		nextValidityTimer = Timer.scheduledTimer(withTimeInterval: fireDate.timeIntervalSinceNow, repeats: false) { [weak self] _ in
			self?.updateValidityStatesAndNotifications(shouldScheduleTimer: false)
			self?.nextValidityTimer = nil
		}

		// remove old notifications before we subscribe new ones
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		// schedule timer updates
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(scheduleTimer), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let dccSignatureVerifier: DCCSignatureVerifying
	private let dscListProvider: DSCListProviding
	private let client: Client
	private let appConfiguration: AppConfigurationProviding
	private let digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol
	private let notificationCenter: UserNotificationCenter
	private let recycleBin: RecycleBin

	private var initialHealthCertifiedPersonsReadFromStore = false
	private var initialTestCertificateRequestsReadFromStore = false

	private var healthCertifiedPersonSubscriptions = Set<AnyCancellable>()
	private var testCertificateRequestSubscriptions = Set<AnyCancellable>()
	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		migration()
		updatePublishersFromStore()

		subscribeToNotifications()
		updateGradients()
		
		// Validation Service
		subscribeAppConfigUpdates()
		subscribeDSCListChanges()

		updateValidityStatesAndNotifications()
	}

	private func subscribeAppConfigUpdates() {
		// subscribe app config updates
		appConfiguration.currentAppConfig
			.dropFirst()
			.sink { [weak self] _ in
				self?.updateValidityStatesAndNotifications()
			}
			.store(in: &subscriptions)
	}

	private func subscribeDSCListChanges() {
		// subscribe to changes of dcc certificates list
		dscListProvider.signingCertificates
			.dropFirst()
			.sink { [weak self] _ in
				self?.updateValidityStatesAndNotifications()
			}
			.store(in: &subscriptions)
	}

	@objc
	private func invalidateTimer() {
		Log.info("Invalidate scheduled validity timer")
		nextValidityTimer?.invalidate()
		nextValidityTimer = nil
	}

	private func updateHealthCertifiedPersonSubscriptions(for healthCertifiedPersons: [HealthCertifiedPerson]) {
		healthCertifiedPersonSubscriptions = []

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectDidChange
				.sink { [weak self] healthCertifiedPerson in
					guard let self = self else { return }

					if healthCertifiedPerson.isPreferredPerson {
						// Set isPreferredPerson = false on all other persons to only have one preferred person
						self.healthCertifiedPersons
							.filter { $0 != healthCertifiedPerson }
							.forEach {
								$0.isPreferredPerson = false
							}
					}

					// Always trigger the publisher to inform subscribers and update store
					self.healthCertifiedPersons = self.healthCertifiedPersons.sorted()
					self.updateGradients()
					self.updateValidityStatesAndNotifications()
				}
				.store(in: &healthCertifiedPersonSubscriptions)
		}
	}

	private func updateGradients() {
		let gradientTypes: [GradientView.GradientType] = [.lightBlue(withStars: true), .mediumBlue(withStars: true), .darkBlue(withStars: true)]
		self.healthCertifiedPersons
			.enumerated()
			.forEach { index, person in
				let healthCertificate = person.mostRelevantHealthCertificate

				if healthCertificate?.validityState == .valid ||
					healthCertificate?.validityState == .expiringSoon ||
					(healthCertificate?.type == .test && healthCertificate?.validityState == .expired) {
					person.gradientType = gradientTypes[index % 3]
				} else {
					person.gradientType = .solidGrey(withStars: true)
				}
			}
	}
	
	/// This method should be called: At startup, at creation, at removal and at update validity states of HealthCertificates.
	/// First, removes all local notifications and then re-adds all updates or new notifications to the notification center.
	private func updateNotifications() {
		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				// No notifications for test certificates
				if healthCertificate.type == .recovery || healthCertificate.type == .vaccination {
					removeAllNotifications(for: healthCertificate, completion: { [weak self] in
						self?.createNotifications(for: healthCertificate)
					})
				}
			}
		}
	}

	private func updateTestCertificateRequestSubscriptions(for testCertificateRequests: [TestCertificateRequest]) {
		testCertificateRequestSubscriptions = []

		testCertificateRequests.forEach { testCertificateRequest in
			testCertificateRequest.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.testCertificateRequests = self.testCertificateRequests
				}
				.store(in: &testCertificateRequestSubscriptions)
		}
	}

	private func subscribeToNotifications() {
		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.testCertificateRequests.forEach {
					self?.executeTestCertificateRequest($0, retryIfCertificateIsPending: false)
				}
				self?.updateValidityStatesAndNotifications()
			}
			.store(in: &subscriptions)
	}

	private func requestDigitalCovidCertificate(
		for testCertificateRequest: TestCertificateRequest,
		rsaKeyPair: DCCRSAKeyPair,
		retryIfCertificateIsPending: Bool,
		waitForRetryInSeconds: TimeInterval,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)?
	) {
		Log.info("[HealthCertificateService] Requesting certificate…", log: .api)

		client.getDigitalCovid19Certificate(
			registrationToken: testCertificateRequest.registrationToken,
			isFake: false
		) { [weak self] result in
			switch result {
			case .success(let dccResponse):
				Log.info("[HealthCertificateService] Certificate request succeeded", log: .api)

				self?.assembleDigitalCovidCertificate(
					for: testCertificateRequest,
					rsaKeyPair: rsaKeyPair,
					encryptedDEK: dccResponse.dek,
					encryptedCOSE: dccResponse.dcc,
					completion: completion
				)
			case .failure(let error) where error == .dccPending && retryIfCertificateIsPending:
				DispatchQueue.global().asyncAfter(deadline: .now() + waitForRetryInSeconds) {
					Log.info("[HealthCertificateService] Certificate request failed with .dccPending, retrying.", log: .api)

					self?.requestDigitalCovidCertificate(
						for: testCertificateRequest,
						rsaKeyPair: rsaKeyPair,
						retryIfCertificateIsPending: false,
						waitForRetryInSeconds: waitForRetryInSeconds,
						completion: completion
					)
				}
			case .failure(let error):
				Log.error("[HealthCertificateService] Certificate request failed with error \(error.localizedDescription)", log: .api)

				testCertificateRequest.requestExecutionFailed = true
				testCertificateRequest.isLoading = false
				completion?(.failure(.certificateRequestFailed(error)))
			}
		}
	}

	private func assembleDigitalCovidCertificate(
		for testCertificateRequest: TestCertificateRequest,
		rsaKeyPair: DCCRSAKeyPair,
		encryptedDEK: String,
		encryptedCOSE: String,
		completion: ((Result<Void, HealthCertificateServiceError.TestCertificateRequestError>) -> Void)?
	) {
		Log.info("[HealthCertificateService] Assembling certificate…", log: .api)

		guard let encryptedDEKData = Data(base64Encoded: encryptedDEK) else {
			Log.error("[HealthCertificateService] Assembling certificate failed: base64 decoding failed", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.base64DecodingFailed))
			return
		}

		do {
			let decodedDEK = try rsaKeyPair.decrypt(encryptedDEKData)
			let result = digitalCovidCertificateAccess.convertToBase45(from: encryptedCOSE, with: decodedDEK)

			switch result {
			case .success(let healthCertificateBase45):
				let registerResult = registerHealthCertificate(
					base45: healthCertificateBase45,
					checkSignatureUpfront: false,
					markAsNew: true
				)

				switch registerResult {
				case .success(let certificateResult):
					Log.info("[HealthCertificateService] Certificate assembly succeeded", log: .api)
					
					didRegisterTestCertificate?(certificateResult.certificate.uniqueCertificateIdentifier, testCertificateRequest)
					
					remove(testCertificateRequest: testCertificateRequest)
					completion?(.success(()))
				case .failure(let error):
					Log.error("[HealthCertificateService] Assembling certificate failed: Register failed: \(error.localizedDescription)", log: .api)

					testCertificateRequest.requestExecutionFailed = true
					testCertificateRequest.isLoading = false
					completion?(.failure(.registrationError(error)))
				}
			case .failure(let error):
				Log.error("[HealthCertificateService] Assembling certificate failed: Conversion failed: \(error.localizedDescription)", log: .api)

				testCertificateRequest.requestExecutionFailed = true
				testCertificateRequest.isLoading = false
				completion?(.failure(.assemblyFailed(error)))
			}
		} catch {
			Log.error("[HealthCertificateService] Assembling certificate failed: DEK decryption failed: \(error.localizedDescription)", log: .api)

			testCertificateRequest.requestExecutionFailed = true
			testCertificateRequest.isLoading = false
			completion?(.failure(.decryptionFailed(error)))
		}
	}
	
	private func removeAllNotifications(
		for healthCertificate: HealthCertificate,
		completion: @escaping () -> Void
	) {
		let id = healthCertificate.uniqueCertificateIdentifier
		
		Log.info("Cancel all notifications for certificate with id: \(private: id).", log: .vaccination)
		
		let expiringSoonId = LocalNotificationIdentifier.certificateExpiringSoon.rawValue + "\(id)"
		let expiredId = LocalNotificationIdentifier.certificateExpired.rawValue + "\(id)"

		notificationCenter.getPendingNotificationRequests { [weak self] requests in
			let notificationIds = requests.map {
				$0.identifier
			}.filter {
				$0.contains(expiringSoonId) ||
				$0.contains(expiredId)
			}

			self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIds)
			completion()
		}
	}
	
	private func createNotifications(for healthCertificate: HealthCertificate) {
		let id = healthCertificate.uniqueCertificateIdentifier
		
		let expirationThresholdInDays = appConfiguration.currentAppConfig.value.dgcParameters.expirationThresholdInDays
		let expiringSoonDate = Calendar.current.date(
			byAdding: .day,
			value: -Int(expirationThresholdInDays),
			to: healthCertificate.expirationDate
		)
		
		let expirationDate = healthCertificate.expirationDate
		scheduleNotificationForExpiringSoon(id: id, date: expiringSoonDate)
		scheduleNotificationForExpired(id: id, date: expirationDate)

		// Schedule an 'invalid' notification, if it was not scheduled before.
		if healthCertificate.validityState == .invalid && !healthCertificate.didShowInvalidNotification {
			scheduleInvalidNotification(id: id)
			healthCertificate.didShowInvalidNotification = true
		}

		// Schedule a 'blocked' notification, if it was not scheduled before.
		if healthCertificate.validityState == .blocked && !healthCertificate.didShowBlockedNotification {
			scheduleBlockedNotification(id: id)
			healthCertificate.didShowBlockedNotification = true
		}
	}
	
	private func scheduleNotificationForExpiringSoon(
		id: String,
		date: Date?
	) {
		guard let date = date else {
			Log.error("Could not schedule expiring soon notification for certificate with id: \(private: id) because we have no expiringSoonDate.", log: .vaccination)
			return
		}
		
		Log.info("Schedule expiring soon notification for certificate with id: \(private: id) with expiringSoonDate: \(date)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let expiringSoonDateComponents = Calendar.current.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: date
		)

		let trigger = UNCalendarNotificationTrigger(dateMatching: expiringSoonDateComponents, repeats: false)

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpiringSoon.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)

		addNotification(request: request)
		
	}
	
	private func scheduleNotificationForExpired(
		id: String,
		date: Date
	) {
		Log.info("Schedule expired notification for certificate with id: \(private: id) with expirationDate: \(date)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let expiredDateComponents = Calendar.current.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: date
		)

		let trigger = UNCalendarNotificationTrigger(dateMatching: expiredDateComponents, repeats: false)

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpired.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)

		addNotification(request: request)
	}

	private func scheduleInvalidNotification(
		id: String
	) {
		Log.info("Schedule invalid notification for certificate with id: \(private: id)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateInvalid.rawValue + "\(id)",
			content: content,
			trigger: nil
		)

		addNotification(request: request)
	}

	private func scheduleBlockedNotification(
		id: String
	) {
		Log.info("Schedule blocked notification for certificate with id: \(private: id)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateBlocked.rawValue + "\(id)",
			content: content,
			trigger: nil
		)

		addNotification(request: request)
	}
	
	private func addNotification(request: UNNotificationRequest) {
		_ = notificationCenter.getPendingNotificationRequests { [weak self] requests in
			guard !requests.contains(request) else {
				Log.info(
					"Did not schedule notification: \(private: request.identifier) because it is already scheduled.",
					log: .vaccination
				)
				return
			}
			self?.notificationCenter.add(request) { error in
				if error != nil {
					Log.error(
						"Could not schedule notification: \(private: request.identifier)",
						log: .vaccination,
						error: error
					)
				}
			}
		}
	}
	
	private func applyBoosterRulesForHealthCertificatesOfAPerson(healthCertifiedPerson: HealthCertifiedPerson, completion: @escaping(String?) -> Void) {
		Log.info("Applying booster rules for person", log: .vaccination)
		let healthCertificatesWithHeader: [DigitalCovidCertificateWithHeader] = healthCertifiedPerson.healthCertificates.map {
			return DigitalCovidCertificateWithHeader(header: $0.cborWebTokenHeader, certificate: $0.digitalCovidCertificate)
		}
		boosterNotificationsService.applyRulesForCertificates(certificates: healthCertificatesWithHeader, completion: { result in
			switch result {
			case .success(let validationResult):
				let previousSavedBoosterRule = healthCertifiedPerson.boosterRule
				healthCertifiedPerson.boosterRule = validationResult.rule
				
				if let currentRule = healthCertifiedPerson.boosterRule, currentRule.identifier != previousSavedBoosterRule?.identifier {
					
					// we need to have an ID for the notification and since the certified person doesn't have this property "unlike the certificates" we will compute it as the hash of the string of the standardizedName + dateOfBirth
					guard let name = healthCertifiedPerson.name?.standardizedName,
						  let dateOfBirth = healthCertifiedPerson.dateOfBirth else {
						let errorMessage = "general: standardizedName or dateOfBirth is nil, will not trigger notification"
						Log.error(errorMessage, log: .vaccination, error: nil)
						completion(errorMessage)
						return
					}
					let id = ENAHasher.sha256(name + dateOfBirth)
					self.scheduleBoosterNotification(id: id)
					completion(nil)
				} else {
					let errorMessage = "The New passed booster rule has the same identifier as the old one saved for this person, so we will not trigger the notification"
					Log.debug(errorMessage, log: .vaccination)
					let name = healthCertifiedPerson.name?.standardizedName ?? ""
					completion("for \(private: name): \(errorMessage)")
				}
				
			case .failure(let validationError):
				if validationError == .BOOSTER_VALIDATION_ERROR(.NO_VACCINATION_CERTIFICATE) || validationError == .BOOSTER_VALIDATION_ERROR(.NO_PASSED_RESULT) {
					healthCertifiedPerson.boosterRule = nil
				}

				Log.error(validationError.localizedDescription, log: .vaccination, error: validationError)
				let name = healthCertifiedPerson.name?.standardizedName ?? ""
				completion("for \(private: name): \(validationError.localizedDescription)")
			}
		})
	}
	
	private func scheduleBoosterNotification(id: String) {
		
		Log.info("Schedule booster notification for certificate with id: \(private: id) with trigger date: \(Date())", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateGenericBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.boosterVaccination.rawValue + "\(id)",
			content: content,
			trigger: nil
		)

		addNotification(request: request)
	}

	// swiftlint:disable:next file_length
}
