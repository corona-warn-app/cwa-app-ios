//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class HealthCertificateReissuanceConsentViewModel {

	// MARK: - Init

	init(
		cclService: CCLServable,
		certifiedPerson: HealthCertifiedPerson,
		appConfigProvider: AppConfigurationProviding,
		restServiceProvider: RestServiceProviding,
		healthCertificateService: HealthCertificateServiceServable,
		onDisclaimerButtonTap: @escaping () -> Void,
		onAccompanyingCertificatesButtonTap: @escaping ([HealthCertificate]) -> Void
	) {
		self.cclService = cclService
		self.certifiedPerson = certifiedPerson
		self.appConfigProvider = appConfigProvider
		self.restServiceProvider = restServiceProvider
		self.healthCertificateService = healthCertificateService
		self.onDisclaimerButtonTap = onDisclaimerButtonTap
		self.onAccompanyingCertificatesButtonTap = onAccompanyingCertificatesButtonTap
		
		certifiedPerson.$dccWalletInfo
			.sink { [weak self] wallet in
				guard let self = self else { return }
				guard let certificates = wallet?.certificateReissuance?.certificates else {
					Log.error("CertificateReissuance not found - stop here")
					return
				}
				self.filteredAccompanyingCertificates = self.filterAccompanyingCertificates(
					certificates: certificates,
					certifiedPerson: certifiedPerson
				)
				self.reissuanceCertificates = certificates.compactMap({
					certifiedPerson.healthCertificate(for: $0.certificateToReissue.certificateRef)
				})
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Reissuance.Consent.title

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						listTitleDynamicCell
					]
					.compactMap({ $0 })
				)
			)
			for certificate in reissuanceCertificates {
				$0.add(
					.section(
						cells: [
							.certificate(certificate, certifiedPerson: certifiedPerson)
						]
						.compactMap({ $0 })
					)
				)
			}
			$0.add(
				.section(
					cells: [
						.space(height: 14)
					]
				)
			)
			if !filteredAccompanyingCertificates.isEmpty {
				$0.add(
					.section(
						separators: .all,
						cells: [
							.body(
								text: AppStrings.HealthCertificate.Reissuance.Consent.accompanyingCertificatesTitle,
								style: DynamicCell.TextCellStyle.label,
								accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Reissuance.accompanyingCertificatesTitle,
								accessibilityTraits: UIAccessibilityTraits.link,
								action: .execute { [weak self] _, _ in
									self?.onAccompanyingCertificatesButtonTap(self?.filteredAccompanyingCertificates ?? [])
								},
								configure: { _, cell, _ in
									cell.accessoryType = .disclosureIndicator
									cell.selectionStyle = .default
								}
							)
						]
					)
				)
			}
			$0.add(
				.section(
					cells: [
						.space(height: 10),
						titleDynamicCell,
						subtitleDynamicCell,
						longTextDynamicCell,
						.icon(
							UIImage(imageLiteralResourceName: "more_recycle_bin"),
							text: .string(AppStrings.HealthCertificate.Reissuance.Consent.deleteNotice),
							alignment: .top
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_Certificates_01"),
							text: .string(AppStrings.HealthCertificate.Reissuance.Consent.cancelNotice),
							alignment: .top
						)
				    ]
				    .compactMap({ $0 })
			   )
			)
			$0.add(
				.section(
					cells: [
						.legalExtended(
							title: NSAttributedString(string: AppStrings.HealthCertificate.Reissuance.Consent.legalTitle),
							subheadline1: attributedStringWithRegularText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalSubtitle),
							bulletPoints1: [
								attributedStringWithBoldText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalBullet1),
								attributedStringWithBoldText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalBullet2)
							],
							subheadline2: nil
						),
						.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_1),
						.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_2),
						.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_3),
						.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_4),
						.space(height: 8.0),
						faqLinkDynamicCell,
						.space(height: 8.0)
					]
					.compactMap({ $0 })
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: [
						.body(
							text: AppStrings.HealthCertificate.Validation.body4,
							style: DynamicCell.TextCellStyle.label,
							accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle,
							accessibilityTraits: UIAccessibilityTraits.link,
							action: .execute { [weak self] _, _ in
								self?.onDisclaimerButtonTap()
							},
							configure: { _, cell, _ in
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
							}
						)
					]
				)
			)
		}
	}

	func markCertificateReissuanceAsSeen() {
		certifiedPerson.isNewCertificateReissuance = false
	}
	
	// swiftlint:disable cyclomatic_complexity
	func submit(completion: @escaping (Result<Void, HealthCertificateReissuanceError>) -> Void) {
		Log.info("Submit certificate for reissuance...", log: .vaccination)

		#if DEBUG
		if isUITesting {
			if LaunchArguments.healthCertificate.hasCertificateReissuance.boolValue {
				completion(.success(()))
				return
			}
		}
		#endif
		
		appConfigProvider.appConfiguration()
			.sink { [weak self] appConfig in
				guard let self = self else {
					completion(.failure(.submitFailedError))
					Log.error("App config fetch during reissuance failed due to self being nil", log: .vaccination)
					return
				}
				
				let trustEvaluation = DefaultTrustEvaluation(
					publicKeyHash: appConfig.dgcParameters.reissueServicePublicKeyDigest,
					certificatePosition: 0
				)
				guard let certificateReissuance = self.certifiedPerson.dccWalletInfo?.certificateReissuance else {
					Log.error("Reissuance request failed due to dccWalletInfo.certificateReissuance being nil", log: .vaccination)
					return
				}
				let currentCertificates: [DCCReissuanceCertificateContainer]
				if let certificates = certificateReissuance.certificates {
					Log.debug("Reissuance request use updated CCL parameters", log: .vaccination)
					currentCertificates = certificates
				} else if let reissuanceCertificate = certificateReissuance.certificateToReissue,
						  let accompanyingCertificates = certificateReissuance.accompanyingCertificates {
					Log.debug("Reissuance request Fall back to old CCL parameters", log: .vaccination)
					let certificate = DCCReissuanceCertificateContainer(
						certificateToReissue: reissuanceCertificate,
						accompanyingCertificates: accompanyingCertificates,
						action: "renew"
					)
					currentCertificates = [certificate]
				} else {
					currentCertificates = []
					Log.error("Reissuance request failed due to certificates being nil", log: .vaccination)
				}
				/*
				 We need a dispatchGroup since we iterate async over an array of
				 certificates and the completion result will trigger a UI change "push a new screen"
				 if we don't do this a screen will be pushed multiple times with each closure call
				*/
				let dispatchGroup = DispatchGroup()
				var submissionErrors = [HealthCertificateReissuanceError]()
				
				for certificate in currentCertificates {
					dispatchGroup.enter()
					guard let certificateToReissue = certificate.certificateToReissue.certificateRef.barcodeData else {
						completion(.failure(.certificateToReissueMissing))
						Log.error("Certificate reissuance failed: certificateToReissue.barcodeData is nil", log: .vaccination)
						return
					}
					
					let accompanyingCertificates = certificate.accompanyingCertificates.compactMap { $0.certificateRef.barcodeData }
					
					let requestCertificates = [certificateToReissue] + accompanyingCertificates
					let sendModel = DCCReissuanceSendModel(action: certificate.action, certificates: requestCertificates)
					let resource = DCCReissuanceResource(
						sendModel: sendModel,
						trustEvaluation: trustEvaluation
					)
					self.submit(
						with: resource,
						requestCertificates: requestCertificates,
						completion: { result in
							switch result {
							case.success:
								break
							case .failure(let error):
								submissionErrors.append(error)
							}
							dispatchGroup.leave()
						}
					)
				}
				dispatchGroup.notify(queue: .main) {
					if let error = submissionErrors.first {
						completion(.failure(error))
					} else {
						completion(.success(()))
					}
				}

			}
			.store(in: &subscriptions)
	}
	
	@OpenCombine.Published private(set) var reissuanceCertificates = [HealthCertificate]()

	// MARK: - Private

	private let cclService: CCLServable
	private let certifiedPerson: HealthCertifiedPerson
	private let onDisclaimerButtonTap: () -> Void
	private let onAccompanyingCertificatesButtonTap: ([HealthCertificate]) -> Void
	private let appConfigProvider: AppConfigurationProviding
	private let restServiceProvider: RestServiceProviding
	private let healthCertificateService: HealthCertificateServiceServable
	private var subscriptions = Set<AnyCancellable>()
	private (set) var filteredAccompanyingCertificates = [HealthCertificate]()

	private func submit(
		with resource: DCCReissuanceResource,
		requestCertificates: [String],
		completion: @escaping (Result<Void, HealthCertificateReissuanceError>) -> Void
	) {
		self.restServiceProvider.load(resource) { [weak self] result in
			guard let self = self else {
				completion(.failure(.submitFailedError))
				Log.error("Reissuance request failed due to self being nil", log: .vaccination)
				return
			}
			
			switch result {
			case .success(let certificates):
				do {
					try self.healthCertificateService.replaceHealthCertificate(
						requestCertificates: requestCertificates,
						with: certificates,
						for: self.certifiedPerson,
						markAsNew: true,
						completedNotificationRegistration: { }
					)
					completion(.success(()))
					Log.debug("Certificate reissuance was successful.", log: .vaccination)
				} catch {
					completion(.failure(.replaceHealthCertificateError(error)))
					Log.error("Replacing the certificate with a reissued certificate failed in service", log: .vaccination, error: error)
				}
				
			case .failure(let error):
				completion(.failure(.restServiceError(error)))
				Log.error("Reissuance request failed", log: .vaccination, error: error)
			}
		}
	}
	
	private func filterAccompanyingCertificates(
		certificates: [DCCReissuanceCertificateContainer],
		certifiedPerson: HealthCertifiedPerson
	) -> [HealthCertificate] {
		var finalArray = [DCCCertificateContainer]()
		let reissuanceCertificates = certificates.map({ $0.certificateToReissue })
		for certificate in certificates {
			for accompanyingCertificate in certificate.accompanyingCertificates {
				if !reissuanceCertificates.contains(accompanyingCertificate) && !finalArray.contains(accompanyingCertificate) {
					finalArray.append(accompanyingCertificate)
				}
			}
		}
		return finalArray.compactMap({
			certifiedPerson.healthCertificate(for: $0.certificateRef)
		}).sorted(by: >)
	}
	
	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]

	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]

	private func attributedStringWithRegularText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: normalTextAttribute)
	}

	private func attributedStringWithBoldText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: boldTextAttribute)
	}

	private var listTitleDynamicCell: DynamicCell? {
		guard let listTitle = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.listTitleText?.localized(cclService: cclService) else {
			Log.info("listTitle missing")
			return nil
		}
		return DynamicCell.body(text: listTitle, color: .enaColor(for: .textPrimary2)) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.top = 0
			
			guard #available(iOS 13, *) else {
				cell.contentView.layoutMargins.top = 20
				return
			}
		}
	}
	
	private var titleDynamicCell: DynamicCell? {
		guard let title = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.titleText?.localized(cclService: cclService) else {
			Log.info("title missing")
			return nil
		}
		return DynamicCell.title2(text: title)
	}

	private var subtitleDynamicCell: DynamicCell? {
		if let consentSubtitleText = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.consentSubtitleText?.localized(cclService: cclService) {
			return DynamicCell.subheadline(text: consentSubtitleText, color: .enaColor(for: .textPrimary2)) { _, cell, _ in
				cell.contentView.preservesSuperviewLayoutMargins = false
				cell.contentView.layoutMargins.top = 0
			}
		} else if let subtitle = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.subtitleText?.localized(cclService: cclService) {
			return DynamicCell.subheadline(text: subtitle, color: .enaColor(for: .textPrimary2)) { _, cell, _ in
				cell.contentView.preservesSuperviewLayoutMargins = false
				cell.contentView.layoutMargins.top = 0
			}
		} else {
			return nil
		}
	}

	private var longTextDynamicCell: DynamicCell? {
		guard let longtext = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.longText?.localized(cclService: cclService) else {
			Log.info("long text missing")
			return nil
		}
		return DynamicCell.body(text: longtext)
	}

	private var faqLinkDynamicCell: DynamicCell? {
		guard let faqAnchor = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.faqAnchor else {
			Log.info("long text missing")
			return nil
		}
		return DynamicCell.link(
			text: AppStrings.HealthCertificate.Person.faq,
			url: URL(string: LinkHelper.urlString(suffix: faqAnchor, type: .faq))
		)
	}

}

private extension DynamicCell {
	static func certificate(_ certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) -> Self {
		.custom(withIdentifier: HealthCertificateCell.dynamicTableViewCellReuseIdentifier) { _, cell, _ in
			guard let cell = cell as? HealthCertificateCell else {
				return
			}
			cell.configure(
				HealthCertificateCellViewModel(
					healthCertificate: certificate,
					healthCertifiedPerson: certifiedPerson,
					details: .overviewPlusName
				),
				withDisclosureIndicator: false
			)
		}
	}
}
