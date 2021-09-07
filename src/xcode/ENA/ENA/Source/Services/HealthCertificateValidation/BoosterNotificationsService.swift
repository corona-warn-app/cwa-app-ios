//
// 🦠 Corona-Warn-App
//

import Foundation
import class CertLogic.Rule

protocol BoosterNotificationsServiceProviding {
	func downloadBoosterNotificationRules(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
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
