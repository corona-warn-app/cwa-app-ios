//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// Error and ViewModel are dummies for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///
enum HealthCertifiedPersonUpdateError: Error {
	case UpdateFailedError
}


class HealthCertifiedPersonReissuanceConsentViewModel {

	// MARK: - Init
	
	init(
		person: HealthCertifiedPerson,
		appConfigProvider: AppConfigurationProviding
	) {
		self.healthCertifiedPerson = person
		self.appConfigProvider = appConfigProvider
	}

	// MARK: - Internal

	func submit(completion: @escaping (Result<Void, HealthCertifiedPersonUpdateError>) -> Void) {
			appConfigProvider.appConfiguration()
				.sink { appConfig in
					let publicKeyHash =  appConfig.dgcParameters.reissueServicePublicKeyDigest.sha256String()
					
					let trustEvaluation = DefaultTrustEvaluation(publicKeyHash: publicKeyHash)
					
					
			 }
			 .store(in: &subscriptions)
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let appConfigProvider: AppConfigurationProviding
	private var subscriptions = Set<AnyCancellable>()


}
