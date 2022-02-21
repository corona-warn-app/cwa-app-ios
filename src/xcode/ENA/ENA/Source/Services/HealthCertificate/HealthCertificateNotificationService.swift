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

	func createNotifications(for healthCertificate: HealthCertificate) {
		Log.info("Create notifications.")

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
	
	func removeAllNotifications(
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

	func recreateNotifications(for healthCertificate: HealthCertificate) {
		// No notifications for test certificates
		if healthCertificate.type == .recovery || healthCertificate.type == .vaccination {
			removeAllNotifications(for: healthCertificate, completion: { [weak self] in
				self?.createNotifications(for: healthCertificate)
			})
		}
	}

	func scheduleBoosterNotificationIfNeeded(
		for person: HealthCertifiedPerson,
		previousBoosterNotificationIdentifier: String?,
		completion: (() -> Void)? = nil
	) {
		let name = person.name?.standardizedName
		guard let newBoosterNotificationIdentifier = person.dccWalletInfo?.boosterNotification.identifier else {
			Log.info("No booster notification identifier found for person \(private: String(describing: name))", log: .vaccination)
			completion?()

			return
		}

		if newBoosterNotificationIdentifier != previousBoosterNotificationIdentifier {
			// we need to have an ID for the notification and since the certified person doesn't have this property "unlike the certificates" we will compute it as the hash of the string of the standardizedName + dateOfBirth
			guard let name = name, let dateOfBirth = person.dateOfBirth else {
				Log.error("standardizedName or dateOfBirth is nil, will not trigger booster notification", log: .vaccination)
				completion?()

				return
			}

			Log.info("Scheduling booster notification for \(private: String(describing: name))", log: .vaccination)

			let id = ENAHasher.sha256(name + dateOfBirth)
			self.scheduleBoosterNotification(id: id, completion: completion)
		} else {
			Log.debug("Booster notification identifier \(private: newBoosterNotificationIdentifier) unchanged, no booster notification scheduled", log: .vaccination)
			completion?()
		}
	}

	// MARK: - Private

	private let appConfiguration: AppConfigurationProviding
	private let notificationCenter: UserNotificationCenter
	
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
	
	private func addNotification(request: UNNotificationRequest, completion: (() -> Void)? = nil) {
		_ = notificationCenter.getPendingNotificationRequests { [weak self] requests in
			guard !requests.contains(request) else {
				Log.info(
					"Did not schedule notification: \(private: request.identifier) because it is already scheduled.",
					log: .vaccination
				)
				completion?()

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

				completion?()
			}
		}
	}
	
	private func scheduleBoosterNotification(id: String, completion: (() -> Void)? = nil) {
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

		addNotification(request: request, completion: completion)
	}

}
