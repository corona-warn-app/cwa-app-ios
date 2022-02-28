//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// Error and ViewModel are dummies for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///
enum HealthCertifiedPersonUpdateError: Error {
	case submitFailedError
	case replaceHealthCertificateError(Error)
	case noRelation
	case certificateToReissueMissing
	case restServiceError(ServiceError<DCCReissuanceResourceError>)
}


class HealthCertifiedPersonReissuanceConsentViewModel {

	// MARK: - Init
	
	init(
		person: HealthCertifiedPerson,
		appConfigProvider: AppConfigurationProviding,
		restServiceProvider: RestServiceProviding,
		healthCertificateService: HealthCertificateServiceServable
	) {
		self.healthCertifiedPerson = person
		self.appConfigProvider = appConfigProvider
		self.restServiceProvider = restServiceProvider
		self.healthCertificateService = healthCertificateService
	}

	// MARK: - Internal

	func submit(completion: @escaping (Result<Void, HealthCertifiedPersonUpdateError>) -> Void) {
			appConfigProvider.appConfiguration()
				.sink { [weak self] appConfig in
					guard let self = self else {
						completion(.failure(.submitFailedError))
						return
					}
					
					let publicKeyHash = appConfig.dgcParameters.reissueServicePublicKeyDigest.sha256String()
					let trustEvaluation = DefaultTrustEvaluation(publicKeyHash: publicKeyHash)
					
					guard let certificateToReissue = self.healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.certificateToReissue.certificateRef.barcodeData,
						let certificateToReissueRef = self.healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.certificateToReissue.certificateRef else {
						completion(.failure(.certificateToReissueMissing))
						return
					}
					
					let accompanyingCertificates = self.healthCertifiedPerson.dccWalletInfo?.certificateReissuance?.accompanyingCertificates.compactMap {
						$0.certificateRef.barcodeData
					} ?? []
					
					let certificates = [certificateToReissue] + accompanyingCertificates
					let sendModel = DCCReissuanceSendModel(certificates: certificates)
					let resource = DCCReissuanceResource(
						sendModel: sendModel,
						trustEvaluation: trustEvaluation
					)
					
					self.restServiceProvider.load(resource) { [weak self] result in
						guard let self = self else {
							completion(.failure(.submitFailedError))
							return
						}
						
						switch result {
						case .success(let certificates):

							let certificate = certificates.first { certificate in
								return certificate.relations.contains { relation in
									relation.index == 0 && relation.action == "replace"
								}
							}
							
							guard let certificate = certificate else {
								completion(.failure(.noRelation))
								return
							}
							
							do {
								try self.healthCertificateService.replaceHealthCertificate(
									oldCertificateRef: certificateToReissueRef,
									with: certificate.certificate,
									for: self.healthCertifiedPerson
								)
								completion(.success(()))
							} catch {
								completion(.failure(.replaceHealthCertificateError(error)))
							}

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
	private let healthCertificateService: HealthCertificateServiceServable
	private var subscriptions = Set<AnyCancellable>()
	
}
