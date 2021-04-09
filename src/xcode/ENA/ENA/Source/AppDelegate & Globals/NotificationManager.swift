////
// 🦠 Corona-Warn-App
//

import Foundation
import NotificationCenter

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

	weak var appDelegate: AppDelegate?

	func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Checkout a event checkin.
		if notification.request.identifier.contains(EventCheckoutService.notificationIdentifierPrefix) {
			appDelegate?.eventCheckoutService.checkoutOverdueCheckins()
		}

		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
			appDelegate?.showHome()

		case ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier,
			 ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier:
			showPositiveTestResultIfNeeded()

		case ActionableNotificationIdentifier.testResult.identifier:
			let testIdentifier = ActionableNotificationIdentifier.testResult.identifier
			guard let testResultRawValue = response.notification.request.content.userInfo[testIdentifier] as? Int,
				  let testResult = TestResult(serverResponse: testResultRawValue) else {
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
		guard
			let coronaTestService = appDelegate?.coronaTestService,
			coronaTestService.pcrTest?.positiveTestResultWasShown == true || coronaTestService.antigenTest?.positiveTestResultWasShown == true
		else {
			return
		}

		showTestResultFromNotification(with: .positive)
	}

	private func showTestResultFromNotification(with testResult: TestResult) {
		// we should show screens based on test result regardless wether positiveTestResultWasShown before or not
		appDelegate?.coordinator.showTestResultFromNotification(with: testResult)
	}
}
