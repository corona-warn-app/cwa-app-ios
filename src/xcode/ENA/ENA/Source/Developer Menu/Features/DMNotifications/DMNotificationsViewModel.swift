//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI

final class DMLocalNotificationsViewModel {

	// MARK: - Init

	init(healthCertificateService: HealthCertificateService) {
		self.healthCertificateService = healthCertificateService
		notificationSettings()
	}

	// MARK: - Internal
	var showAlert: (UIAlertController) -> Void = { _ in }

	enum Sections: Int, CaseIterable {
		case expired
	}

	var numberOfSections: Int {
		healthCertificateService.healthCertifiedPersons.count
	}

	func items(section: Int) -> Int {
		let persons = healthCertificateService.healthCertifiedPersons
		return persons[section].healthCertificates.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		let identifier = healthCertificateService.healthCertifiedPersons[indexPath.section].healthCertificates[indexPath.row].uniqueCertificateIdentifier

		return DMButtonCellViewModel(
			text: "Trigger notifications for person: \(indexPath.section) with certificate \(indexPath.row)",
			textColor: .enaColor(for: .textContrast),
			backgroundColor: .enaColor(for: .buttonPrimary),
			action: { [weak self] in
				self?.showSelectionAlert(id: identifier)
			}
		)
	}

	// MARK: - Private

	private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
	private let healthCertificateService: HealthCertificateService

	private func showSelectionAlert(id: String) {
		let alert = UIAlertController(
			title: "Schedule local notification",
			message: "This will end the app and schedule a local notification", preferredStyle: .alert
		)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let expiredAction = UIAlertAction(title: "Expired notification", style: .default) { [weak self] _ in
			self?.scheduleNotificationForExpired(id: id)
		}
		let expiredSoonAction = UIAlertAction(title: "Expiring soon notification", style: .default) { [weak self] _ in
			self?.scheduleNotificationForExpiringSoon(id: id)
		}
		let invalidAction = UIAlertAction(title: "Invalid notification", style: .default) { [weak self] _ in
			self?.scheduleNotificationForExpiringSoon(id: id)
		}
		alert.addAction(expiredAction)
		alert.addAction(expiredSoonAction)
		alert.addAction(invalidAction)
		alert.addAction(cancelAction)
		showAlert(alert)
	}

	private func scheduleNotificationForExpired(
		id: String
	) {
		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpired.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)
		addNotification(request: request)
	}

	private func scheduleNotificationForExpiringSoon(
		id: String
	) {
		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpiringSoon.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)

		addNotification(request: request)
	}
	private func scheduleNotificationForInvalid(
		id: String
	) {
		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateValidityBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateInvalid.rawValue + "\(id)",
			content: content,
			trigger: trigger
		)

		addNotification(request: request)
	}

	private func addNotification(request: UNNotificationRequest) {
		notificationCenter.getPendingNotificationRequests { [weak self] requests in
			guard !requests.contains(request) else {
				Log.info(
					"Did not schedule notification: \(private: request.identifier) because it is already scheduled.",
					log: .vaccination
				)
				return
			}
			self?.notificationCenter.add(request) { error in
				guard error == nil else {
					Log.error(
						"Could not schedule notification: \(private: request.identifier)",
						log: .vaccination,
						error: error
					)
					return
				}
				exit(0)
			}
		}
	}

	private func notificationSettings() {
		let center = UNUserNotificationCenter.current()

		center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
			guard granted else {
				Log.debug("notifications not allowed")
				return
			}
		}
	}

}

#endif
