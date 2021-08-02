////
// 🦠 Corona-Warn-App
//

import Foundation
import NotificationCenter

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	
	// MARK: - Init
	
	init(
		coronaTestService: CoronaTestService,
		eventCheckoutService: EventCheckoutService,
		healthCertificateService: HealthCertificateService,
		showHome: @escaping (Route?) -> Void,
		showTestResultFromNotification: @escaping (CoronaTestType) -> Void
	) {
		self.coronaTestService = coronaTestService
		self.eventCheckoutService = eventCheckoutService
		self.healthCertificateService = healthCertificateService
		self.showHome = showHome
		self.showTestResultFromNotification = showTestResultFromNotification
	}
		
	// MARK: - Protocol UNUserNotificationCenterDelegate
	
	func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Checkout overdue checkins.
		if notification.request.identifier.contains(LocalNotificationIdentifier.checkout.rawValue) {
			eventCheckoutService.checkoutOverdueCheckins()
		}
		
		// Show badge on certificates tab when certificate is expired.
		if notification.request.identifier.contains(LocalNotificationIdentifier.certificateExpired.rawValue) {
			healthCertificateService.unseenTestCertificateCount.value += 1
		}
		
		// Show badge on certificates tab when certificate expires soon.
		if notification.request.identifier.contains(LocalNotificationIdentifier.certificateExpiringSoon.rawValue) {
			healthCertificateService.unseenTestCertificateCount.value += 1
		}

		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
			showHome(nil)

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
				showHome(nil)
				return
			}

			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(testResultType)
			case .invalid:
				showHome(nil)
			case .expired, .pending:
				assertionFailure("Expired and Pending Test Results should not trigger the Local Notification")
			}

		default: break
		}

		completionHandler()
	}
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let coronaTestService: CoronaTestService
	private let eventCheckoutService: EventCheckoutService
	private let healthCertificateService: HealthCertificateService
	private let showHome: (Route?) -> Void
	private let showTestResultFromNotification: (CoronaTestType) -> Void
	
	private func showPositivePCRTestResultIfNeeded() {
		if let pcrTest = coronaTestService.pcrTest,
		   pcrTest.positiveTestResultWasShown {
			showTestResultFromNotification(.pcr)
		}
	}

	private func showPositiveAntigenTestResultIfNeeded() {
		if let antigenTest = coronaTestService.antigenTest,
		   antigenTest.positiveTestResultWasShown {
			showTestResultFromNotification(.antigen)
		}
	}
}
