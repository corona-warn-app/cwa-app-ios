////
// 🦠 Corona-Warn-App
//

import Foundation
import NotificationCenter

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	weak var appDelegate: AppDelegate?

	func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
			appDelegate?.showHome()

		case ActionableNotificationIdentifier.warnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.warnOthersReminder2.identifier:
			showPositiveTestResultIfNeeded()

		case ActionableNotificationIdentifier.testResult.identifier:
			let testIdenifier = ActionableNotificationIdentifier.testResult.identifier
			guard let testResultRawValue = response.notification.request.content.userInfo[testIdenifier] as? Int,
				  let testResult = TestResult(rawValue: testResultRawValue) else {
				appDelegate?.showHome()
				return
			}

			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(with: testResult)
			case .invalid:
				appDelegate?.showHome()
			case .expired, .pending:
				assertionFailure("Expired and Pending Test Results should not trigger the Local Notification")
			}

		default: break
		}

		completionHandler()
	}

	private func showPositiveTestResultIfNeeded() {
		guard let store = appDelegate?.store else {
			// this should be a unit test
			return
		}
		let warnOthersReminder = WarnOthersReminder(store: store)
		guard warnOthersReminder.positiveTestResultWasShown else {
			return
		}

		showTestResultFromNotification(with: .positive)
	}

	private func showTestResultFromNotification(with testResult: TestResult) {
		// we should show screens based on test result regardless wether positiveTestResultWasShown before or not
		appDelegate?.coordinator.showTestResultFromNotification(with: testResult)
	}
}
