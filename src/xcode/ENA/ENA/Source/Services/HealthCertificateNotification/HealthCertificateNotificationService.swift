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
					Log.error("Could not schedule notification due to invalid uniqueCertificateIdentifier")
					return
				}
				
				let expirationThresholdInDays = appConfig.dgcParameters.expirationThresholdInDays
				let expiringSoonDate = Calendar.current.date(
					byAdding: .day,
					value: -Int(expirationThresholdInDays),
					to: healthCertificate.expirationDate
				)
				
				let expirationDate = healthCertificate.expirationDate
				
				self.triggerNotificationForExpiredSoon(id: id, date: expiringSoonDate)
				self.triggerNotificationForExpired(id: id, date: expirationDate)
				
			}
			.store(in: &subscriptions)
	}

	
	func scheduleNotificationAfterDeletion(for healthCertificate: HealthCertificate) {
		Log.info("[EventCheckoutService] Cancel all notifications.", log: .checkin)

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
	
	private func triggerNotificationForExpiredSoon(
		id: String,
		date: Date?
	) {
		
//		Log.info("Trigger notification for certificate with id: \(healthCertificate.uniqueCertificateIdentifier) and endDate: \(healthCertificate.expirationDate)", log: .checkin)
//
//		let content = UNMutableNotificationContent()
//		content.title = AppStrings.Checkout.notificationTitle
//		content.body = AppStrings.Checkout.notificationBody
//		content.sound = .default
//
//		let checkinEndDateComponents = Calendar.current.dateComponents(
//			[.year, .month, .day, .hour, .minute, .second],
//			from: checkin.checkinEndDate
//		)
//
//		let trigger = UNCalendarNotificationTrigger(dateMatching: checkinEndDateComponents, repeats: false)
//
//		let request = UNNotificationRequest(
//			identifier: checkin.notificationIdentifier,
//			content: content,
//			trigger: trigger
//		)
//
//		notificationCenter.add(request) { error in
//			if error != nil {
//				Log.error("Checkout notification could not be scheduled.")
//			}
//		}
	
	}
	
	private func triggerNotificationForExpired(
		id: String,
		date: Date
	) {
		
	}
	
	private func removeNotificationForExpiredSoon() {
		
	}
	
	private func removeNotificationForExpired() {
		
	}
}
