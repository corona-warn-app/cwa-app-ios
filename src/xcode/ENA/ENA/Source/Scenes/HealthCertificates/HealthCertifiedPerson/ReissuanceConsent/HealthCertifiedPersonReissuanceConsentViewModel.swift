//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// Error and ViewModel are dummies for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///
enum HealthCertifiedPersonUpdateError: Error {
	case updateFailedError
	case restServiceError(ServiceError<DCCReissuanceResourceError>)
}


class HealthCertifiedPersonReissuanceConsentViewModel {

	// MARK: - Init
	
	init(
		person: HealthCertifiedPerson,
		appConfigProvider: AppConfigurationProviding,
		restServiceProvider: RestServiceProviding
	) {
		self.healthCertifiedPerson = person
		self.appConfigProvider = appConfigProvider
		self.restServiceProvider = restServiceProvider
	}

	// MARK: - Internal

	func submit(completion: @escaping (Result<Void, HealthCertifiedPersonUpdateError>) -> Void) {
			appConfigProvider.appConfiguration()
				.sink { [weak self] appConfig in
					guard let self = self else {
						completion(.failure(.updateFailedError))
						return
					}
					
					let publicKeyHash = appConfig.dgcParameters.reissueServicePublicKeyDigest.sha256String()
					
					let trustEvaluation = DefaultTrustEvaluation(publicKeyHash: publicKeyHash)
					
					guard let certificateToReissue = self.healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.certificateToReissue.certificateRef.barcodeData else {
						completion(.failure(.updateFailedError))
						return
					}
					
					let accompanyingCertificates = self.healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.accompanyingCertificates.compactMap { $0.certificateRef.barcodeData } ?? []
					
					let certificates = [certificateToReissue] + accompanyingCertificates
					let sendModel = DCCReissuanceSendModel(certificates: certificates)
					let resource = DCCReissuanceResource(
						sendModel: sendModel,
						trustEvaluation: trustEvaluation
					)
					
					self.restServiceProvider.load(resource) { [weak self] result in
						switch result {
						case .success(let receiveModel):
							
							break
						case .failure(let error):
							completion(.failure(.restServiceError(error)))
						}
					}
					
					
			 }
			 .store(in: &subscriptions)
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let appConfigProvider: AppConfigurationProviding
	private let restServiceProvider: RestServiceProviding
	private var subscriptions = Set<AnyCancellable>()
	
}
