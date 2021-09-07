//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

import class CertLogic.Rule
import class CertLogic.CertLogicEngine
import class CertLogic.ValidationResult

protocol BoosterNotificationsServiceProviding {
	func applyRulesForCertificates(
		certificates: [DigitalCovidCertificateWithHeader],
		completion: @escaping (Result<ValidationResult, BoosterNotificationRuleValidationError>) -> Void
	)
}

/*
This service is responsible for handling the logic for the Booster Notifications rules
Currently it is using the rules download service to fetch the latest Booster Notifications rules
*/

class BoosterNotificationsService {
	
	// MARK: - Init
	
	init(rulesDownloadService: RulesDownloadServiceProviding) {
		self.rulesDownloadService = rulesDownloadService
	}
	
	// MARK: - Protocol BoosterNotificationsServiceProviding
	
	func downloadBoosterNotifications(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		self.rulesDownloadService.downloadRules(
			ruleType: .boosterNotification,
			completion: { result in
				completion(result)
			}
		)
	}
	
	// MARK: - Private
	
	private let rulesDownloadService: RulesDownloadServiceProviding
}
