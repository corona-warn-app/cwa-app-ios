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

		let dispatchGroup = DispatchGroup()

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

		// Schedule a 'revoked' notification, if it was not scheduled before.
		if healthCertificate.validityState == .revoked && !healthCertificate.didShowRevokedNotification {
			dispatchGroup.enter()
			scheduleRevokedNotification(
				healthCertificateIdentifier: healthCertificateIdentifier,
				completion: {
					dispatchGroup.leave()
				}
			)
			healthCertificate.didShowRevokedNotification = true
		}
		
		dispatchGroup.notify(queue: .global()) {
			completion()
		}
	}
	
	func removeAllExpiringSoonAndExpiredNotifications(
		completion: @escaping () -> Void
	) {
		Log.info("Cancel all expiring soon and expired notifications", log: .vaccination)
		
		let expiringSoonId = LocalNotificationIdentifier.certificateExpiringSoon.rawValue
		let expiredId = LocalNotificationIdentifier.certificateExpired.rawValue

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
		guard let newCertificateReissuance = person.dccWalletInfo?.certificateReissuance,
			  let newIdentifier = newCertificateReissuance.reissuanceDivision.identifier,
			  let personIdentifier = person.identifier else {
			Log.info("No certificate reissuance found for person \(private: String(describing: name))", log: .vaccination)
			completion()
			
			return
		}
		
		guard let oldReissuance = previousCertificateReissuance else {
			Log.info("First time Scheduling reissuance notification for \(private: String(describing: name))", log: .vaccination)
			self.scheduleCertificateReissuanceNotification(personIdentifier: personIdentifier, completion: completion)

			return
		}
		
		if newIdentifier != oldReissuance.reissuanceDivision.identifier ?? "renew" {
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

	private func scheduleRevokedNotification(
		healthCertificateIdentifier: String,
		completion: @escaping () -> Void
	) {
		Log.info("Schedule revoked notification for certificate with id: \(private: healthCertificateIdentifier)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateRevoked.rawValue + "\(healthCertificateIdentifier)",
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
