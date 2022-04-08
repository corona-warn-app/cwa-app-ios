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
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
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
	func extract(_ prefix: String, from: String, completion: @escaping ((HealthCertifiedPerson, HealthCertificate)?) -> Void) {
		findHealthCertificate(String(from.dropFirst(prefix.count)), completion: { result in
			completion(result)
		})
	}

	func extractPerson(_ prefix: String, from: String, completion: @escaping (HealthCertifiedPerson?) -> Void) {
		return findHealthCertifiedPerson(String(from.dropFirst(prefix.count)), completion: { result in
			completion(result)
		})
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
		
	private func checkForLocalNotificationsActions(_ incomingIdentifier: String) {
		guard let certificateIdentifier = LocalNotificationIdentifier.allCases.first(where: {
			incomingIdentifier.hasPrefix($0.rawValue)
		}) else {
			return
		}
		
		switch certificateIdentifier {
		case .certificateExpired, .certificateExpiringSoon, .certificateBlocked, .certificateInvalid:
			extract(certificateIdentifier.rawValue, from: incomingIdentifier, completion: { [weak self] result in
				if let (certifiedPerson, healthCertificate) = result {
					let route = Route(
						healthCertifiedPerson: certifiedPerson,
						healthCertificate: healthCertificate
					)
					Log.debug("Received \(certificateIdentifier.rawValue) notification")
					self?.showHealthCertificate(route)
				}
			})
		case .boosterVaccination, .certificateReissuance, .admissionStateChange:
			extractPerson(certificateIdentifier.rawValue, from: incomingIdentifier, completion: { [weak self] result in
				if let certifiedPerson = result {
					let route = Route(healthCertifiedPerson: certifiedPerson)
					Log.debug("Received \(certificateIdentifier.rawValue) notification")
					self?.showHealthCertifiedPerson(route)
				}
			})
		case .checkout:
			break
		}
	}
	
	private func findHealthCertificate(_ identifier: String, completion: @escaping((HealthCertifiedPerson, HealthCertificate)?) -> Void) {
		healthCertificateService.setup(updatingWalletInfos: true) { [weak self] in
			guard let self = self else {
				completion(nil)
				return
			}
			for person in self.healthCertificateService.healthCertifiedPersons {
				if let certificate = person.$healthCertificates.value
					.first(where: { $0.uniqueCertificateIdentifier == identifier }) {
					completion((person, certificate))
					return
				}
			}
			completion(nil)
		}
	}
	
	
	private func findHealthCertifiedPerson(_ identifier: String, completion: @escaping(HealthCertifiedPerson?) -> Void) {
		healthCertificateService.setup(updatingWalletInfos: true) { [weak self] in
			guard let self = self else {
				completion(nil)
				return
			}
			let person = self.healthCertificateService.healthCertifiedPersons
				.first {
					$0.identifier == identifier
				}
			completion(person)
		}
	}
}
