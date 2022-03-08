//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

// global to access in unit tests
// version will be used for migration logic
public let kCurrentHealthCertifiedPersonsVersion = 3

protocol HealthCertificateServiceServable {
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson
	) throws
}

// swiftlint:disable:next type_body_length
class HealthCertificateService: HealthCertificateServiceServable {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		dccSignatureVerifier: DCCSignatureVerifying,
		dscListProvider: DSCListProviding,
		appConfiguration: AppConfigurationProviding,
		digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol = DigitalCovidCertificateAccess(),
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		cclService: CCLServable,
		recycleBin: RecycleBin
	) {
		#if DEBUG
		if isUITesting {
			let store = MockTestStore()
			let appConfiguration = CachedAppConfigurationMock(store: store)

			self.store = store
			self.dccSignatureVerifier = dccSignatureVerifier
			self.dscListProvider = DSCListProvider(client: CachingHTTPClientMock(), store: store)
			self.appConfiguration = appConfiguration
			self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
			self.healthCertificateNotificationService = HealthCertificateNotificationService(
				appConfiguration: appConfiguration,
				notificationCenter: notificationCenter
			)
			self.cclService = cclService
			self.recycleBin = recycleBin

			setup()
			configureForTesting()

			return
		}
		#endif

		self.store = store
		self.dccSignatureVerifier = dccSignatureVerifier
		self.dscListProvider = dscListProvider
		self.appConfiguration = appConfiguration
		self.digitalCovidCertificateAccess = digitalCovidCertificateAccess
		self.healthCertificateNotificationService = HealthCertificateNotificationService(
			appConfiguration: appConfiguration,
			notificationCenter: notificationCenter
		)
		self.cclService = cclService
		self.recycleBin = recycleBin

		setup()
	}

	// MARK: - Internal

	@DidSetPublished private(set) var healthCertifiedPersons = [HealthCertifiedPerson]() {
		didSet {
			Log.debug("Did set healthCertifiedPersons.")

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
	
	@DidSetPublished var lastSelectedScenarioIdentifier: String? {
		didSet {
			if lastSelectedScenarioIdentifier != oldValue {
				self.store.lastSelectedScenarioIdentifier = lastSelectedScenarioIdentifier
			}
		}
	}
	
	private(set) var unseenNewsCount = CurrentValueSubject<Int, Never>(0)
	
	var nextValidityTimer: Timer?

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

	// swiftlint:disable cyclomatic_complexity
	@discardableResult
	func registerHealthCertificate(
		base45: Base45,
		checkSignatureUpfront: Bool = true,
		checkMaxPersonCount: Bool = true,
		markAsNew: Bool = false
	) -> Result<CertificateResult, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)
		
		// If the certificate is in the recycle bin, restore it and skip registration process.
		if let recycleBinItem = recycleBin.item(for: base45), case let .certificate(healthCertificate) = recycleBinItem.item {
			let healthCertifiedPerson = addHealthCertificate(healthCertificate)
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
				Log.debug("Check signature of certificate upfront.")

				if case .failure(let error) = dccSignatureVerifier.verify(
					certificate: base45,
					with: dscListProvider.signingCertificates.value,
					and: Date()
				) {
					Log.error("Signature check of certificate failed with error: \(error).")
					return .failure(.invalidSignature(error))
				}
			}

			if healthCertificate.hasTooManyEntries {
				Log.error("[HealthCertificateService] Registering health certificate failed: certificate has too many entries", log: .api)
				return .failure(.certificateHasTooManyEntries)
			}

			var personWarnThresholdReached = false
			
			// If we already have the person, we can skip the checkMaxPersonCount
			if findFirstPerson(for: healthCertificate, from: healthCertifiedPersons) == nil {
				if checkMaxPersonCount {
					Log.debug("Check against max person count.")
					
					if healthCertifiedPersons.count >= appConfiguration.featureProvider.intValue(for: .dccPersonCountMax) {
						Log.debug("Abort registering certificate due to too many persons registered.")
						return .failure(.tooManyPersonsRegistered)
					}
					
					if healthCertifiedPersons.count + 1 >= appConfiguration.featureProvider.intValue(for: .dccPersonWarnThreshold) {
						Log.debug("Person warn threshold is reached.")
						personWarnThresholdReached = true
					}
				}
			}
			
			if healthCertifiedPersons.contains(healthCertificate) {
				Log.error("[HealthCertificateService] Registering health certificate failed: certificate already registered", log: .api)
				return .failure(.certificateAlreadyRegistered(healthCertificate.type))
			}

			let healthCertifiedPerson = addHealthCertificate(healthCertificate)
	
			Log.info("Successfuly registered health certificate.")
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
	
	func replaceHealthCertificate(
		oldCertificateRef: DCCCertificateReference,
		with newHealthCertificateString: String,
		for person: HealthCertifiedPerson
	) throws {
		let newHealthCertificate = try HealthCertificate(base45: newHealthCertificateString)
		guard let oldHealthCertificate = person.healthCertificate(for: oldCertificateRef) else {
			return
		}
		
		person.healthCertificates.replace(oldHealthCertificate, with: newHealthCertificate)
		
		updateValidityState(for: newHealthCertificate)
		scheduleTimer()

		healthCertificateNotificationService.createNotifications(for: newHealthCertificate)
		
		healthCertificateNotificationService.removeAllNotifications(for: oldHealthCertificate, completion: {})

		recycleBin.moveToBin(.certificate(oldHealthCertificate))
	}

	@discardableResult
	func addHealthCertificate(_ healthCertificate: HealthCertificate) -> HealthCertifiedPerson {
		Log.info("Add health certificate to person.")
		
		let newlyGroupedPersons = groupingPersons(appending: healthCertificate)
		
		guard let healthCertifiedPerson = findFirstPerson(
			for: healthCertificate, from: newlyGroupedPersons
		) else {
			Log.error("HealthCertificate was not found immediately after adding it.")
			fatalError("HealthCertificate was not found immediately after adding it. This case is not possible. The healthCertificate was added to newlyGroupedPersons before.")
		}
		
		let isNewPersonAdded = newlyGroupedPersons.count > healthCertifiedPersons.count
		healthCertifiedPersons = newlyGroupedPersons
		
		updateValidityState(for: healthCertificate)
		scheduleTimer()

		healthCertificateNotificationService.createNotifications(for: healthCertificate)
		
		if isNewPersonAdded {
			Log.info("[HealthCertificateService] Successfully registered health certificate for a new person", log: .api)
			// Manual update needed as the person subscriptions were not set up when the certificate was added
			updateDCCWalletInfo(for: healthCertifiedPerson)
			updateGradients()
		} else {
			Log.info("[HealthCertificateService] Successfully registered health certificate for a person with other existing certificates", log: .api)
		}
		
		Log.info("Finished adding health certificate to person.")
		
		return healthCertifiedPerson
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
				} else if healthCertifiedPerson.healthCertificates.count > 1 {
					Log.info("[HealthCertificateService] Need to check if we have to regroup after deletion a certificate.", log: .api)
					regroupAfterDeletion(for: healthCertifiedPerson)
				}
				break
			}
		}
		// we do not have to wait here, so we leave the completion empty
		healthCertificateNotificationService.removeAllNotifications(for: healthCertificate, completion: {})

		// Move HealthCertificate to the recycle-bin
		recycleBin.moveToBin(.certificate(healthCertificate))
	}

	func updateDCCWalletInfosIfNeeded(isForced: Bool = false, completion: (() -> Void)? = nil) {
		cclService.updateConfiguration { [weak self] configurationDidChange in
			guard let self = self else {
				completion?()
				return
			}
			let dispatchGroup = DispatchGroup()
			for person in self.healthCertifiedPersons where (configurationDidChange || person.needsDCCWalletInfoUpdate || isForced) {
				dispatchGroup.enter()
				self.updateDCCWalletInfo(for: person) {
					dispatchGroup.leave()
				}
			}

			dispatchGroup.notify(queue: .global()) {
				completion?()
			}
		}
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons = store.healthCertifiedPersons
		initialHealthCertifiedPersonsReadFromStore = true

		updateHealthCertifiedPersonSubscriptions(for: healthCertifiedPersons)
	}
	
	func groupingPersons(
		appending newHealthCertificate: HealthCertificate
	) -> [HealthCertifiedPerson] {
		// Please note: A new certificate can combine several persons to one.

		// Search for matching persons.
		var newGroupedPersons = healthCertifiedPersons
		var matchingPersons = [HealthCertifiedPerson]()
		for person in newGroupedPersons {
			for certificate in person.healthCertificates {
				if certificate.belongsToSamePerson(newHealthCertificate) {
					if !matchingPersons.contains(person) {
						matchingPersons.append(person)
					}
				}
			}
		}
		
		// If more than one person was found, reduce persons to one person and add the certificate to the reduced person.
		// This is the scenario where the new certificate has combined several persons to one.
		if matchingPersons.count > 1 {
			var allCertificates = matchingPersons.flatMap { $0.healthCertificates }
			allCertificates.append(newHealthCertificate)
			
			// Use the first person to reduce all others into it.
			let firstPerson = matchingPersons[0]
			firstPerson.healthCertificates = allCertificates
			firstPerson.isPreferredPerson = matchingPersons.contains { $0.isPreferredPerson }
			
			newGroupedPersons.remove(elements: matchingPersons)
			newGroupedPersons.append(firstPerson)
		}
		// If there is exact 1 person found, add the new certificate to that person.
		else if matchingPersons.count == 1 {
			matchingPersons[0].healthCertificates.append(newHealthCertificate)
		}
		// If no person was found, create a new person with the new certificate.
		else {
			newGroupedPersons.append(
				HealthCertifiedPerson(
					healthCertificates: [newHealthCertificate]
				)
			)
		}
		
		// Apply sorting.
		for person in newGroupedPersons {
			person.healthCertificates.sort(by: <)
		}
		newGroupedPersons.sort()

		return newGroupedPersons
	}
	
	func findFirstPerson(for certificate: HealthCertificate, from persons: [HealthCertifiedPerson]) -> HealthCertifiedPerson? {
		for person in persons {
			for personCertificate in person.healthCertificates {
				if certificate.belongsToSamePerson(personCertificate) {
					return person
				}
			}
		}
		
		return nil
	}

	func updateValidityStatesAndNotificationsWithFreshDSCList(completion: () -> Void) {
		Log.info("Update validity state and notifications with fresh dsc list.")

		// .dropFirst: drops the first callback, which is called with default signing certificates.
		// .first: only executes 1 element and no subsequent elements.
		// This way only the 2. call with freshly fetched signing certificates is executed.
		dscListProvider.signingCertificates
			.dropFirst()
			.first()
			.sink { [weak self] _ in
				self?.updateValidityStatesAndNotifications()
			}
			.store(in: &subscriptions)
	}

	func updateValidityStatesAndNotifications(
		shouldScheduleTimer: Bool = true
	) {
		Log.info("Update validity states and notifications.")

		attemptToRestoreDecodingFailedHealthCertificates()

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				updateValidityState(for: healthCertificate)
				healthCertificateNotificationService.recreateNotifications(for: healthCertificate)
			}
		}

		if shouldScheduleTimer {
			scheduleTimer()
		}
	}

	func validUntilDates(for healthCertificates: [HealthCertificate], signingCertificates: [DCCSigningCertificate]) -> [Date] {
		Log.info("Read valid until dates.")

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
			self?.updateValidityStatesAndNotifications()
			self?.nextValidityTimer = nil
		}

		// remove old notifications before we subscribe new ones
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		// schedule timer updates
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(scheduleTimer), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	func attemptToRestoreDecodingFailedHealthCertificates() {
		healthCertifiedPersons.forEach {
			$0.attemptToRestoreDecodingFailedHealthCertificates()
		}
	}

	func remove(decodingFailedHealthCertificate: DecodingFailedHealthCertificate) {
		healthCertifiedPersons
			.first {
				$0.decodingFailedHealthCertificates.contains(decodingFailedHealthCertificate)
			}?
			.decodingFailedHealthCertificates
			.removeAll {
				$0 == decodingFailedHealthCertificate
			}
	}

	// MARK: - Private

	private let store: HealthCertificateStoring
	private let dccSignatureVerifier: DCCSignatureVerifying
	private let dscListProvider: DSCListProviding
	private let appConfiguration: AppConfigurationProviding
	private let digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol
	private let healthCertificateNotificationService: HealthCertificateNotificationService
	private let recycleBin: RecycleBin
	private let cclService: CCLServable

	private var initialHealthCertifiedPersonsReadFromStore = false

	private var healthCertifiedPersonSubscriptions = Set<AnyCancellable>()
	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		
		HealthCertificateMigrator().migrate(store: store)
		updatePublishersFromStore()
		updateTimeBasedValidityStates()

		updateGradients()
		
		subscribeAppConfigUpdates()
		subscribeDSCListChanges()
		updateDCCWalletInfosIfNeeded()
		scheduleTimer()
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
		Log.info("Update health certificate subscriptions.")

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
				}
				.store(in: &healthCertifiedPersonSubscriptions)

			healthCertifiedPerson.dccWalletInfoUpdateRequest
				.sink { [weak self] healthCertifiedPerson in
					self?.updateDCCWalletInfo(for: healthCertifiedPerson)
				}
				.store(in: &healthCertifiedPersonSubscriptions)
		}
	}

	private func updateGradients() {
		let gradientTypes: [GradientView.GradientType] = [.lightBlue, .mediumBlue, .darkBlue]
		self.healthCertifiedPersons
			.enumerated()
			.forEach { index, person in
				let healthCertificate = person.mostRelevantHealthCertificate

				if healthCertificate?.validityState == .valid ||
					healthCertificate?.validityState == .expiringSoon ||
					(healthCertificate?.type == .test && healthCertificate?.validityState == .expired) {
					person.gradientType = gradientTypes[index % 3]
				} else {
					person.gradientType = .solidGrey
				}
			}
	}

	private func updateDCCWalletInfo(for person: HealthCertifiedPerson, completion: (() -> Void)? = nil) {
		person.queue.async {
			let result = self.cclService.dccWalletInfo(
				for: person.healthCertificates.map { $0.dccWalletCertificate }, with: self.store.lastSelectedScenarioIdentifier ?? ""
			)

			switch result {
			case .success(let dccWalletInfo):
				let previousBoosterNotificationIdentifier = person.boosterRule?.identifier ?? person.dccWalletInfo?.boosterNotification.identifier
				let previousCertificateReissuance = person.dccWalletInfo?.certificateReissuance
				let previousAdmissionStateIdentifier = person.dccWalletInfo?.admissionState.identifier

				person.dccWalletInfo = dccWalletInfo
				person.mostRecentWalletInfoUpdateFailed = false
				#if DEBUG
				if isUITesting {
					if LaunchArguments.healthCertificate.hasBoosterNotification.boolValue {
						person.dccWalletInfo = self.updateDccWalletInfoForMockBoosterNotification(dccWalletInfo: dccWalletInfo)
					}
					if LaunchArguments.healthCertificate.hasCertificateReissuance.boolValue {
						person.dccWalletInfo = self.updateDccWalletInfoForMockCertificateReissuance(dccWalletInfo: dccWalletInfo)
					}
				}
				#endif

				let dispatchGroup = DispatchGroup()

				dispatchGroup.enter()
				self.healthCertificateNotificationService.scheduleBoosterNotificationIfNeeded(
					for: person,
					previousBoosterNotificationIdentifier: previousBoosterNotificationIdentifier,
					completion: {
						dispatchGroup.leave()
					}
				)

				dispatchGroup.enter()
				self.healthCertificateNotificationService.scheduleCertificateReissuanceNotificationIfNeeded(
					for: person,
					previousCertificateReissuance: previousCertificateReissuance,
					completion: {
						dispatchGroup.leave()
					}
				)
				
				dispatchGroup.enter()
				self.healthCertificateNotificationService.scheduleAdmissionStateChangedNotificationIfNeeded(
					for: person,
					previousAdmissionStateIdentifier: previousAdmissionStateIdentifier,
					completion: {
						dispatchGroup.leave()
					}
				)

				dispatchGroup.notify(queue: .global()) {
					completion?()
				}

			case .failure(let error):
				Log.error("Wallet info update failed", error: error)
				person.mostRecentWalletInfoUpdateFailed = true
				completion?()
			}
		}
	}

	private func updateValidityState(for healthCertificate: HealthCertificate) {
		let previousValidityState = healthCertificate.validityState

		let blockedIdentifierChunks = appConfiguration.currentAppConfig.value
			.dgcParameters.blockListParameters.blockedUvciChunks
		if healthCertificate.isBlocked(by: blockedIdentifierChunks) {
			healthCertificate.validityState = .blocked
		} else {
			let signatureVerificationResult = dccSignatureVerifier.verify(
				certificate: healthCertificate.base45,
				with: dscListProvider.signingCertificates.value,
				and: Date()
			)

			switch signatureVerificationResult {
			case .success:
				updateTimeBasedValidityState(for: healthCertificate)
			case .failure:
				healthCertificate.validityState = .invalid
			}
		}

		if healthCertificate.validityState != previousValidityState {
			// Only validity states that are not shown as `.valid` should be marked as new for the user.
			healthCertificate.isValidityStateNew = !healthCertificate.isConsideredValid
		}
	}

	private func updateTimeBasedValidityStates() {
		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.healthCertificates.forEach { healthCertificate in
				updateTimeBasedValidityState(for: healthCertificate)
			}
		}
	}

	private func updateTimeBasedValidityState(for healthCertificate: HealthCertificate) {
		guard healthCertificate.validityState != .invalid && healthCertificate.validityState != .blocked else {
			return
		}

		let currentAppConfiguration = appConfiguration.currentAppConfig.value
		let expirationThresholdInDays = currentAppConfiguration.dgcParameters.expirationThresholdInDays
		let expiringSoonDate = Calendar.current.date(
			byAdding: .day,
			value: -Int(expirationThresholdInDays),
			to: healthCertificate.expirationDate
		)

		if Date() >= healthCertificate.expirationDate {
			healthCertificate.validityState = .expired
		} else if let expiringSoonDate = expiringSoonDate, Date() >= expiringSoonDate {
			healthCertificate.validityState = .expiringSoon
		} else {
			healthCertificate.validityState = .valid
		}
	}
	
	private func regroupAfterDeletion(
		for healthCertifiedPerson: HealthCertifiedPerson
	) {
		let regroupedPersons = regroup(
			healthCertifiedPerson: healthCertifiedPerson
		)
		
		// Find person and replace it by our regroupedPersons
		// Use a copy of healthCertifiedPersons to avoid multiple changes to healthCertifiedPersons.
		var mutatedHealthCertifiedPersons = healthCertifiedPersons
		mutatedHealthCertifiedPersons.remove(healthCertifiedPerson)
		mutatedHealthCertifiedPersons.append(contentsOf: regroupedPersons)
		healthCertifiedPersons = mutatedHealthCertifiedPersons
		
		// We only want to call updateDCCWalletInfo for new created persons.
		// For the existing person it is called when the certificates changed.
		let newlyPersons = healthCertifiedPersons.filter { $0 != healthCertifiedPerson }
		newlyPersons.forEach { updateDCCWalletInfo(for: $0) }
		
		healthCertifiedPersons.sort()
		updateGradients()
	}
	
	// This regroup preserves the reference to healthCertifiedPerson during regrouping.
	// This is needed because there might be a combine registration to that person reference.
	private func regroup(
		healthCertifiedPerson: HealthCertifiedPerson
	) -> [HealthCertifiedPerson] {
		
		// Save the reference of the person and the first certificate of it. We need to preserve the reference of the person because there might be some combine registrations on this person.
		let allCertificates = healthCertifiedPerson.healthCertificates
		var certificates = healthCertifiedPerson.healthCertificates
		guard let first = certificates.first else {
			Log.error("Should not happen because we proof before if we have at least one certificate in the person", log: .api)
			return []
		}
		certificates.removeFirst()
		// Create now from every remaining certificate of the person a new person
		var splittedPersons = certificates.map { HealthCertifiedPerson(healthCertificates: [$0]) }
		healthCertifiedPerson.healthCertificates = [first]
		// Append the original person to the newly created persons
		splittedPersons.append(healthCertifiedPerson)
		
		var regroupedPersons = [HealthCertifiedPerson]()

		for certificate in allCertificates {
			let matchingPersons = splittedPersons.findPersons(for: certificate)
			let matchingRegroupedPersons = regroupedPersons.findPersons(for: certificate)
			
			regroupedPersons.remove(elements: matchingRegroupedPersons)
			
			let allPersons = matchingPersons + matchingRegroupedPersons
			var mergedPerson: HealthCertifiedPerson
			if allPersons.contains(healthCertifiedPerson) {
				mergedPerson = healthCertifiedPerson
			} else {
				guard let person = allPersons.first else {
					continue
				}
				mergedPerson = person
			}
			
			for matchingPerson in allPersons {
				for certificate in matchingPerson.healthCertificates {
					if !mergedPerson.healthCertificates.contains(certificate) {
						mergedPerson.healthCertificates.append(certificate)
					}
				}
				
				if matchingPerson.isPreferredPerson {
					mergedPerson.isPreferredPerson = true
				}
			}
			
			regroupedPersons.append(mergedPerson)
		}
		
		return regroupedPersons
	}

	// swiftlint:disable:next file_length
}
