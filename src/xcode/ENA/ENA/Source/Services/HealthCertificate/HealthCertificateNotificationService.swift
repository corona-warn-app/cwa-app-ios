//
// 🦠 Corona-Warn-App
//

import UserNotifications

class HealthCertificateNotificationService {

	// MARK: - Init

	init(
		appConfiguration: AppConfigurationProviding,
		notificationCenter: UserNotificationCenter
	) {
		self.appConfiguration = appConfiguration
		self.notificationCenter = notificationCenter
	}

	// MARK: - Internal

	func createNotifications(
		for healthCertificate: HealthCertificate,
		completion: @escaping () -> Void
	) {
		guard healthCertificate.type != .test else {
			completion()
			return
		}

		Log.info("Create notifications.")

		let healthCertificateIdentifier = healthCertificate.uniqueCertificateIdentifier

		let expirationThresholdInDays = appConfiguration.currentAppConfig.value.dgcParameters.expirationThresholdInDays
		let expiringSoonDate = Calendar.current.date(
			byAdding: .day,
			value: -Int(expirationThresholdInDays),
			to: healthCertificate.expirationDate
		)

		let dispatchGroup = DispatchGroup()
		
		let expirationDate = healthCertificate.expirationDate
		
		dispatchGroup.enter()
		scheduleNotificationForExpiringSoon(
			healthCertificateIdentifier: healthCertificateIdentifier,
			date: expiringSoonDate,
			completion: {
				dispatchGroup.leave()
			}
		)
		
		dispatchGroup.enter()
		scheduleNotificationForExpired(
			healthCertificateIdentifier: healthCertificateIdentifier,
			date: expirationDate,
			completion: {
				dispatchGroup.leave()
			}
		)

		// Schedule an 'invalid' notification, if it was not scheduled before.
		if healthCertificate.validityState == .invalid && !healthCertificate.didShowInvalidNotification {
			
			dispatchGroup.enter()
			scheduleInvalidNotification(
				healthCertificateIdentifier: healthCertificateIdentifier,
				completion: {
					dispatchGroup.leave()
				}
			)
			healthCertificate.didShowInvalidNotification = true
		}

		// Schedule a 'blocked' notification, if it was not scheduled before.
		if healthCertificate.validityState == .blocked && !healthCertificate.didShowBlockedNotification {
			
			dispatchGroup.enter()
			scheduleBlockedNotification(
				healthCertificateIdentifier: healthCertificateIdentifier,
				completion: {
					dispatchGroup.leave()
				}
			)
			healthCertificate.didShowBlockedNotification = true
		}
		
		dispatchGroup.notify(queue: .global()) {
			completion()
		}
	}
	
	func removeAllNotifications(
		for healthCertificate: HealthCertificate,
		completion: @escaping () -> Void
	) {
		guard healthCertificate.type != .test else {
			completion()
			return
		}
		
		let healthCertificateIdentifier = healthCertificate.uniqueCertificateIdentifier
		
		Log.info("Cancel all notifications for certificate with id: \(private: healthCertificateIdentifier).", log: .vaccination)
		
		let expiringSoonId = LocalNotificationIdentifier.certificateExpiringSoon.rawValue + "\(healthCertificateIdentifier)"
		let expiredId = LocalNotificationIdentifier.certificateExpired.rawValue + "\(healthCertificateIdentifier)"

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

	func recreateNotifications(
		for healthCertificate: HealthCertificate,
		completion: @escaping () -> Void
	) {
		// No notifications for test certificates
		removeAllNotifications(for: healthCertificate, completion: { [weak self] in
			self?.createNotifications(
				for: healthCertificate,
				completion: completion
			)
		})
	}

	func scheduleBoosterNotificationIfNeeded(
		for person: HealthCertifiedPerson,
		previousBoosterNotificationIdentifier: String?,
		completion: @escaping () -> Void
	) {
		let name = person.name?.standardizedName
		guard let newBoosterNotificationIdentifier = person.dccWalletInfo?.boosterNotification.identifier else {
			Log.info("No booster notification identifier found for person \(private: String(describing: name))", log: .vaccination)
			completion()

			return
		}

		if newBoosterNotificationIdentifier != previousBoosterNotificationIdentifier {
			guard let personIdentifier = person.identifier else {
				Log.error("Person identifier is nil, will not trigger booster notification", log: .vaccination)
				completion()

				return
			}

			Log.info("Scheduling booster notification for \(private: String(describing: name))", log: .vaccination)

			self.scheduleBoosterNotification(personIdentifier: personIdentifier, completion: completion)
		} else {
			Log.debug("Booster notification identifier \(private: newBoosterNotificationIdentifier) unchanged, no booster notification scheduled", log: .vaccination)
			completion()
		}
	}

	func scheduleCertificateReissuanceNotificationIfNeeded(
		for person: HealthCertifiedPerson,
		previousCertificateReissuance: DCCCertificateReissuance?,
		completion: @escaping () -> Void
	) {
		let name = person.name?.standardizedName
		guard let newCertificateReissuance = person.dccWalletInfo?.certificateReissuance else {
			Log.info("No certificate reissuance found for person \(private: String(describing: name))", log: .vaccination)
			completion()

			return
		}

		if newCertificateReissuance != previousCertificateReissuance {
			guard let personIdentifier = person.identifier else {
				Log.error("Person identifier is nil, will not trigger certificate reissuance notification", log: .vaccination)
				completion()

				return
			}

			Log.info("Scheduling reissuance notification for \(private: String(describing: name))", log: .vaccination)

			self.scheduleCertificateReissuanceNotification(personIdentifier: personIdentifier, completion: completion)
		} else {
			Log.debug("Certificate reissuance \(private: newCertificateReissuance) unchanged, no reissuance notification scheduled", log: .vaccination)
			completion()
		}
	}

	func scheduleAdmissionStateChangedNotificationIfNeeded(
		for person: HealthCertifiedPerson,
		previousAdmissionStateIdentifier: String?,
		completion: @escaping () -> Void
	) {
		let name = person.name?.standardizedName
		guard let newAdmissionStateIdentifier = person.dccWalletInfo?.admissionState.identifier else {
			Log.info("No New admissionState found for person \(private: String(describing: name))", log: .vaccination)
			completion()

			return
		}
		
		guard previousAdmissionStateIdentifier != nil else {
			Log.info("No old admissionState for person \(private: String(describing: name))", log: .vaccination)
			completion()

			return
		}
		
		if newAdmissionStateIdentifier != previousAdmissionStateIdentifier {
			guard let personIdentifier = person.identifier else {
				Log.error("Person identifier is nil, will not trigger admissionState notification", log: .vaccination)
				completion()

				return
			}

			Log.info("Scheduling admissionState notification for \(private: String(describing: name))", log: .vaccination)

			self.scheduleAdmissionStateChangeNotification(personIdentifier: personIdentifier, completion: completion)
		} else {
			Log.debug("admissionState \(private: newAdmissionStateIdentifier) unchanged, no admissionState notification scheduled", log: .vaccination)
			completion()
		}
	}
	
	// MARK: - Private

	private let appConfiguration: AppConfigurationProviding
	private let notificationCenter: UserNotificationCenter
	
	private func scheduleNotificationForExpiringSoon(
		healthCertificateIdentifier: String,
		date: Date?,
		completion: @escaping () -> Void
	) {
		guard let date = date else {
			Log.error("Could not schedule expiring soon notification for certificate with id: \(private: healthCertificateIdentifier) because we have no expiringSoonDate.", log: .vaccination)
			completion()
			return
		}
		
		Log.info("Schedule expiring soon notification for certificate with id: \(private: healthCertificateIdentifier) with expiringSoonDate: \(date)", log: .vaccination)

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
			identifier: LocalNotificationIdentifier.certificateExpiringSoon.rawValue + "\(healthCertificateIdentifier)",
			content: content,
			trigger: trigger
		)

		addNotification(
			request: request,
			completion: completion
		)
	}
	
	private func scheduleNotificationForExpired(
		healthCertificateIdentifier: String,
		date: Date,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule expired notification for certificate with id: \(private: healthCertificateIdentifier) with expirationDate: \(date)", log: .vaccination)

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
			identifier: LocalNotificationIdentifier.certificateExpired.rawValue + "\(healthCertificateIdentifier)",
			content: content,
			trigger: trigger
		)

		addNotification(
			request: request,
			completion: completion
		)
	}

	private func scheduleInvalidNotification(
		healthCertificateIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule invalid notification for certificate with id: \(private: healthCertificateIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateInvalid.rawValue + "\(healthCertificateIdentifier)",
			content: content,
			trigger: nil
		)

		addNotification(
			request: request,
			completion: completion
		)
	}

	private func scheduleBlockedNotification(
		healthCertificateIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule blocked notification for certificate with id: \(private: healthCertificateIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateBlocked.rawValue + "\(healthCertificateIdentifier)",
			content: content,
			trigger: nil
		)

		addNotification(
			request: request,
			completion: completion
		)
	}

	private func scheduleBoosterNotification(
		personIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule booster notification for person with id: \(private: personIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateGenericBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.boosterVaccination.rawValue + "\(personIdentifier)",
			content: content,
			trigger: nil
		)

		addNotification(request: request, completion: completion)
	}

	private func scheduleCertificateReissuanceNotification(
		personIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule certificate reissuance notification for person with id: \(private: personIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateReissuance.rawValue + "\(personIdentifier)",
			content: content,
			trigger: nil
		)

		addNotification(request: request, completion: completion)
	}
	
	private func scheduleAdmissionStateChangeNotification(
		personIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule AdmissionState change notification for person with id: \(private: personIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateGenericBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.admissionStateChange.rawValue + "\(personIdentifier)",
			content: content,
			trigger: nil
		)

		addNotification(request: request, completion: completion)
	}

	private func addNotification(
		request: UNNotificationRequest,
		completion: @escaping () -> Void
	) {
		_ = notificationCenter.getPendingNotificationRequests { [weak self] requests in
			guard !requests.contains(request) else {
				Log.info(
					"Did not schedule notification: \(private: request.identifier) because it is already scheduled.",
					log: .vaccination
				)
				completion()

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

				completion()
			}
		}
	}

}
