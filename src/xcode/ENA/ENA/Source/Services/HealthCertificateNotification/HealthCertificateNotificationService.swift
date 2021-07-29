////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

protocol HealthCertificateNotificationProviding {
	func scheduleNotificationAfterCreation(for healthCertificate: HealthCertificate)
	func scheduleNotificationAfterDeletion(for healthCertificate: HealthCertificate)
}

final class HealthCertificateNotificationService: HealthCertificateNotificationProviding {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.store = store
		self.notificationCenter = notificationCenter
		self.appConfiguration = appConfigurationProvider
		// trigger init check
		
		// register publisher for app config change
		
		appConfigurationProvider.currentAppConfig.sink { [weak self] _ in
			self?.refreshNotifications()
		}.store(in: &subscriptions)
		
	}
	
	// MARK: - Protocol HealthCertificateNotificationProviding
	
	func scheduleNotificationAfterCreation(for healthCertificate: HealthCertificate) {
		
		appConfiguration.currentAppConfig
			.sink { [weak self] appConfig in
				guard let self = self else {
					Log.error("Could not create strong self")
					return
				}
				
				guard let id = healthCertificate.uniqueCertificateIdentifier else {
					Log.error("Could not schedule notifications for certificate: \(private: healthCertificate) due to invalid uniqueCertificateIdentifier")
					return
				}
				
				let expirationThresholdInDays = appConfig.dgcParameters.expirationThresholdInDays
				let expiringSoonDate = Calendar.current.date(
					byAdding: .day,
					value: -Int(expirationThresholdInDays),
					to: healthCertificate.expirationDate
				)
				
				let expirationDate = healthCertificate.expirationDate
				
				self.scheduleNotificationForExpiredSoon(id: id, date: expiringSoonDate)
				self.scheduleNotificationForExpired(id: id, date: expirationDate)
				
			}
			.store(in: &subscriptions)
	}

	
	func scheduleNotificationAfterDeletion(for healthCertificate: HealthCertificate) {
//		Log.info("[EventCheckoutService] Cancel all notifications.", log: .checkin)

//		notificationCenter.getPendingNotificationRequests { [weak self] requests in
//			let notificationIds = requests.map {
//				$0.identifier
//			}.filter {
//				$0.contains(EventCheckoutService.notificationIdentifierPrefix)
//			}
//
//			self?.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIds)
//
//			completion()
//		}
	}
	
	// MARK: - Internal
	
	static let notificationIdentifierPrefix = "HealthCertificateNotification"
	
	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let notificationCenter: UserNotificationCenter
	private let appConfiguration: AppConfigurationProviding
	
	private var subscriptions = Set<AnyCancellable>()
	
	private func refreshNotifications() {
		
//		store.healthCertifiedPersons
//		store.unseenTestCertificateCount += 1
		
	}
	
	private func scheduleNotificationForExpiredSoon(
		id: String,
		date: Date?
	) {
		guard let date = date else {
			Log.error("Could not schedule expiring soon notification for certificate with id: \(id) because we have no expiringSoonDate.", log: .vaccination)
			return
		}
		
		Log.info("Schedule expiring soon notification for certificate with id: \(id) with expiringSoonDate: \(date)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.expireSoonTitle
		content.body = AppStrings.LocalNotifications.expireSoonBody
		content.sound = .default

		let expiringSoonDateComponents = Calendar.current.dateComponents(
			[.year, .month, .day, .hour, .minute, .second],
			from: date
		)

		let trigger = UNCalendarNotificationTrigger(dateMatching: expiringSoonDateComponents, repeats: false)

		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpired.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)

		notificationCenter.add(request) { error in
			if error != nil {
				Log.error(
					"Could not schedule expiring soon notification for certificate with id: \(id) with expiringSoonDate: \(date)",
					log: .vaccination,
					error: error
				)
			}
		}
	}
	
	private func scheduleNotificationForExpired(
		id: String,
		date: Date
	) {
		Log.info("Schedule expired notification for certificate with id: \(id) with expirationDate: \(date)", log: .vaccination)

		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.expiredTitle
		content.body = AppStrings.LocalNotifications.expiredBody
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

		notificationCenter.add(request) { error in
			if error != nil {
				Log.error(
					"Could not schedule expired notification for certificate with id: \(id) with expirationDate: \(date)",
					log: .vaccination,
					error: error
				)
			}
		}
	}
	
	private func removeNotificationForExpiredSoon() {
		
	}
	
	private func removeNotificationForExpired() {
		
	}
}
