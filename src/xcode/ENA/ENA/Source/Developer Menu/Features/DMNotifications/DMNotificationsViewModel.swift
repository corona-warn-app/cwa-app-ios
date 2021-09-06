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

	enum Sections: Int, CaseIterable {
		case expired
	}

	var numberOfSections: Int {
		healthCertificateService.healthCertifiedPersons.value.count
	}

	func items(section: Int) -> Int {
		let persons = healthCertificateService.healthCertifiedPersons.value
		return persons[section].healthCertificates.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {

		guard let identifier = healthCertificateService.healthCertifiedPersons.value[indexPath.section].healthCertificates[indexPath.row].uniqueCertificateIdentifier else {
			fatalError("Failed to find matching identifier")
		}

		return DMButtonCellViewModel(
			text: "Trigger expired notification for person: \(indexPath.section), healthCertificate \(indexPath.row)",
			textColor: .enaColor(for: .textContrast),
			backgroundColor: .enaColor(for: .buttonPrimary),
			action: { [weak self] in
				self?.scheduleNotificationForExpired(id: identifier)
			}
		)
	}

	// MARK: - Private

	private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
	private let healthCertificateService: HealthCertificateService

	private func scheduleNotificationForExpired(
		id: String
	) {
		let content = UNMutableNotificationContent()
		content.title = AppStrings.LocalNotifications.certificateGenericTitle
		content.body = AppStrings.LocalNotifications.certificateGenericBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		let request = UNNotificationRequest(
			identifier: LocalNotificationIdentifier.certificateExpired.rawValue + "\(id)",
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
