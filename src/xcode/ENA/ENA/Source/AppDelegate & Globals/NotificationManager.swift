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
			 ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier:
			showPositivePCRTestResultIfNeeded()

		case ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier:
			showPositiveAntigenTestResultIfNeeded()

		case ActionableNotificationIdentifier.testResult.identifier:
			let testIdentifier = ActionableNotificationIdentifier.testResult.identifier
			let testTypeIdentifier = ActionableNotificationIdentifier.testResultType.identifier

			guard let testResultRawValue = response.notification.request.content.userInfo[testIdentifier] as? Int,
				  let testResult = TestResult(serverResponse: testResultRawValue),
				  let testResultTypeRawValue = response.notification.request.content.userInfo[testTypeIdentifier] as? Int,
				  let testResultType = CoronaTestType(rawValue: testResultTypeRawValue) else {
				appDelegate?.showHome()
				return
			}

			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(with: testResultType)
			case .invalid:
				appDelegate?.showHome()
			case .expired, .pending:
				assertionFailure("Expired and Pending Test Results should not trigger the Local Notification")
			}

		default: break
		}

		completionHandler()
	}

	private func showPositivePCRTestResultIfNeeded() {
		if let pcrTest = appDelegate?.coronaTestService.pcrTest,
		   pcrTest.positiveTestResultWasShown {
			showTestResultFromNotification(with: .pcr)
		}
	}

	private func showPositiveAntigenTestResultIfNeeded() {
		if let antigenTest = appDelegate?.coronaTestService.antigenTest,
		   antigenTest.positiveTestResultWasShown {
			showTestResultFromNotification(with: .antigen)
		}
	}

	private func showTestResultFromNotification(with testType: CoronaTestType) {
		// we should show screens based on test result regardless wether positiveTestResultWasShown before or not
		appDelegate?.coordinator.showTestResultFromNotification(with: testType)
	}
}
