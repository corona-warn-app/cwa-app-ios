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

class BoosterNotificationsService {
	// MARK: - Init
	init(store: Store, client: Client) {
		self.store = store
		self.client = client
	}
	
	// MARK: - Protocol BoosterNotificationsServiceProviding
	
	func downloadBoosterNotifications(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		self.rulesDownloadService = RulesDownloadService(store: self.store, client: self.client)
		self.rulesDownloadService?.downloadBoosterNotificationRules(completion: { result in
			Log.info("Rules has been downloaded, please do farther processing here")
		})
	}
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private var rulesDownloadService: BoosterNotificationsRulesDownloadServiceProviding?
}
