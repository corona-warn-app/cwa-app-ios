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
		completion: @escaping (Result<ValidationResult, BoosterNotificationServiceError>) -> Void
	)
}

/*
This service is responsible for handling the logic for the Booster Notifications rules
Currently it is using the rules download service to fetch the latest Booster Notifications rules
*/

class BoosterNotificationsService: BoosterNotificationsServiceProviding {
	
	// MARK: - Init
	
	init(
		rulesDownloadService: RulesDownloadServiceProviding,
		validationRulesAccess: BoosterRulesAccessing = ValidationRulesAccess()
	) {
		self.rulesDownloadService = rulesDownloadService
		self.validationRulesAccess = validationRulesAccess
	}

	// MARK: - Protocol BoosterNotificationsServiceProviding
	
	func applyRulesForCertificates(
		certificates: [DigitalCovidCertificateWithHeader],
		completion: @escaping (Result<ValidationResult, BoosterNotificationServiceError>) -> Void
	) {
		downloadBoosterNotificationRules { [weak self] downloadedRules in
			guard let self = self else { return }
			
			switch downloadedRules {
			case .success(let rules):
				let resultOfApplyingBoosterRules = self.validationRulesAccess.applyBoosterNotificationValidationRules(
					certificates: certificates,
					rules: rules,
					certLogicEngine: nil
				) { logs in
					Log.debug(logs)
				}
				switch resultOfApplyingBoosterRules {
				case .success(let validationResult):
					completion(.success(validationResult))
				case .failure(let boosterError):
					completion(.failure(.BOOSTER_VALIDATION_ERROR(boosterError)))
				}
			case .failure(let error):
				Log.error("Error downloading the booster notifications", log: .api, error: error)
				completion(.failure(.CERTIFICATE_VALIDATION_ERROR(.rulesDownloadError(error))))
			}
		}
	}

	// MARK: - Private
	
	private func downloadBoosterNotificationRules(completion: @escaping (Result<[Rule], DCCDownloadRulesError>) -> Void) {
		rulesDownloadService.downloadRules(
			ruleType: .boosterNotification,
			completion: { result in
				completion(result)
			}
		)
	}
	
	private let rulesDownloadService: RulesDownloadServiceProviding
	private let validationRulesAccess: BoosterRulesAccessing
	
}
