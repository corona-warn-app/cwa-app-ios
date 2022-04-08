////
// 🦠 Corona-Warn-App
//

import Foundation
import NotificationCenter

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	
	// MARK: - Init
	
	init(
		coronaTestService: CoronaTestServiceProviding,
		eventCheckoutService: EventCheckoutService,
		healthCertificateService: HealthCertificateService,
		showHome: @escaping () -> Void,
		showTestResultFromNotification: @escaping (Route) -> Void,
		showFamilyMemberTests: @escaping (Route) -> Void,
		showHealthCertificate: @escaping (Route) -> Void,
		showHealthCertifiedPerson: @escaping (Route) -> Void
	) {
		self.coronaTestService = coronaTestService
		self.eventCheckoutService = eventCheckoutService
		self.healthCertificateService = healthCertificateService
		self.showHome = showHome
		self.showTestResultFromNotification = showTestResultFromNotification
		self.showFamilyMemberTests = showFamilyMemberTests
		self.showHealthCertificate = showHealthCertificate
		self.showHealthCertifiedPerson = showHealthCertifiedPerson
	}
		
	// MARK: - Protocol UNUserNotificationCenterDelegate
	
	func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		// Checkout overdue checkins.
		if notification.request.identifier.contains(LocalNotificationIdentifier.checkout.rawValue) {
			eventCheckoutService.checkoutOverdueCheckins()
		}
		
		if #available(iOS 14.0, *) {
			completionHandler([.banner, .alert, .badge, .sound])
		} else {
			completionHandler([.alert, .badge, .sound])
		}
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier,
			 DeadmanNotificationManager.deadmanNotificationIdentifier:
			showHome()

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
				  let testResult = TestResult(rawValue: testResultRawValue),
				  let testResultTypeRawValue = response.notification.request.content.userInfo[testTypeIdentifier] as? Int,
				  let testResultType = CoronaTestType(rawValue: testResultTypeRawValue) else {
				showHome()
				return
			}

			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(.testResultFromNotification(testResultType))
			case .invalid:
				showHome()
			case .expired, .pending:
				assertionFailure("Expired and Pending Test Results should not trigger the Local Notification")
			}
		case ActionableNotificationIdentifier.familyTestResult.identifier:
			showFamilyMemberTests(.familyMemberTestResultFromNotification)
		default:
			// special action where we need to extract data from identifier
			checkForLocalNotificationsActions(response.notification.request.identifier)
		}
		completionHandler()
	}

	// MARK: - Internal
	
	// Internal for testing
	func extract(_ prefix: String, from: String) -> (HealthCertifiedPerson, HealthCertificate)? {
		guard from.hasPrefix(prefix) else {
			return nil
		}
		return findHealthCertificate(String(from.dropFirst(prefix.count)))
	}
	
	func extractPerson(_ prefix: String, from: String) -> HealthCertifiedPerson? {
		guard from.hasPrefix(prefix) else {
			return nil
		}
			return findHealthCertifiedPerson(String(from.dropFirst(prefix.count)))
	}
	// MARK: - Private
	
	private let coronaTestService: CoronaTestServiceProviding
	private let eventCheckoutService: EventCheckoutService
	private let healthCertificateService: HealthCertificateService
	private let showHome: () -> Void
	private let showFamilyMemberTests: (Route) -> Void
	private let showTestResultFromNotification: (Route) -> Void
	private let showHealthCertificate: (Route) -> Void
	private let showHealthCertifiedPerson: (Route) -> Void

	private func showPositivePCRTestResultIfNeeded() {
		if let pcrTest = coronaTestService.pcrTest.value,
		   pcrTest.positiveTestResultWasShown {
			showTestResultFromNotification(.testResultFromNotification(.pcr))
		}
	}

	private func showPositiveAntigenTestResultIfNeeded() {
		if let antigenTest = coronaTestService.antigenTest.value,
		   antigenTest.positiveTestResultWasShown {
			showTestResultFromNotification(.testResultFromNotification(.antigen))
		}
	}

	private func checkForLocalNotificationsActions(_ identifier: String) {
		if let (certifiedPerson, healthCertificate) = extract(LocalNotificationIdentifier.certificateExpired.rawValue, from: identifier) {
			let route = Route(
				healthCertifiedPerson: certifiedPerson,
				healthCertificate: healthCertificate
			)
			Log.debug("Received certificateExpired notification")
			showHealthCertificate(route)
		} else if let (certifiedPerson, healthCertificate) = extract(LocalNotificationIdentifier.certificateExpiringSoon.rawValue, from: identifier) {
			let route = Route(
				healthCertifiedPerson: certifiedPerson,
				healthCertificate: healthCertificate
			)
			Log.debug("Received certificateExpiringSoon notification")
			showHealthCertificate(route)
		} else if let (certifiedPerson, healthCertificate) = extract(LocalNotificationIdentifier.certificateInvalid.rawValue, from: identifier) {
			let route = Route(
				healthCertifiedPerson: certifiedPerson,
				healthCertificate: healthCertificate
			)
			Log.debug("Received certificateInvalid notification")
			showHealthCertificate(route)
		} else if let (certifiedPerson) = extractPerson(LocalNotificationIdentifier.boosterVaccination.rawValue, from: identifier) {
			let route = Route(healthCertifiedPerson: certifiedPerson)
			Log.debug("Received boosterVaccination notification")
			showHealthCertifiedPerson(route)
		} else if let (certifiedPerson) = extractPerson(LocalNotificationIdentifier.certificateReissuance.rawValue, from: identifier) {
			let route = Route(healthCertifiedPerson: certifiedPerson)
			Log.debug("Received certificateReissuance notification")
			showHealthCertifiedPerson(route)
		} else if let (certifiedPerson) = extractPerson(LocalNotificationIdentifier.admissionStateChange.rawValue, from: identifier) {
			let route = Route(healthCertifiedPerson: certifiedPerson)
			Log.debug("Received admissionStateChange notification")
			showHealthCertifiedPerson(route)
		} else if let (certifiedPerson, healthCertificate) = extract(LocalNotificationIdentifier.certificateBlocked.rawValue, from: identifier) {
			let route = Route(
				healthCertifiedPerson: certifiedPerson,
				healthCertificate: healthCertificate
			)
			Log.debug("Received Certificate blocked notification")
			showHealthCertificate(route)
		}
	}
	
	private func findHealthCertificate(_ identifier: String) -> (HealthCertifiedPerson, HealthCertificate)? {
		for person in healthCertificateService.healthCertifiedPersons {
			if let certificate = person.$healthCertificates.value
				.first(where: { $0.uniqueCertificateIdentifier == identifier }) {
				return (person, certificate)
			}
		}
		return nil
	}
	
	private func findHealthCertifiedPerson(_ identifier: String) -> (HealthCertifiedPerson)? {
		return healthCertificateService.healthCertifiedPersons
			.first {
				$0.identifier == identifier
			}
	}
}
