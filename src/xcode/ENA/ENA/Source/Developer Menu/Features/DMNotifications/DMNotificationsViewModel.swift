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

	init() {
		notificationSettings()
	}

	// MARK: - Internal

	enum Sections: Int, CaseIterable {
		case expired
	}

	let itemsCount: Int = 1

	var numberOfSections: Int {
		return Sections.allCases.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		guard let section = Sections(rawValue: indexPath.section) else {
			fatalError("Invalid tableview section")
		}
		switch section {

		case .expired:
			return DMButtonCellViewModel(
				text: "Trigger expired local notification",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					Log.debug("button hit")
					guard let in5Seconds = Calendar.current.date(byAdding: .second, value: 5, to: Date()) else {
						Log.error("Failed to schedule local notification")
						return
					}
					self?.scheduleNotificationForExpired(id: "expiredTest")
				}
			)

		}
	}

	// MARK: - Private

	let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

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

		center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
			guard granted else {
				Log.debug("notifications not allowed")
				return
			}
		}
	}

}

#endif
