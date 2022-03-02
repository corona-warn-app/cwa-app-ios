//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class HealthCertificateReissuanceConsentViewModel {

	// MARK: - Init

	init(
		cclService: CCLServable,
		certificate: HealthCertificate,
		certifiedPerson: HealthCertifiedPerson,
		appConfigProvider: AppConfigurationProviding,
		restServiceProvider: RestServiceProviding,
		healthCertificateService: HealthCertificateServiceServable,
		onDisclaimerButtonTap: @escaping () -> Void
	) {
		self.cclService = cclService
		self.certificate = certificate
		self.certifiedPerson = certifiedPerson
		self.appConfigProvider = appConfigProvider
		self.restServiceProvider = restServiceProvider
		self.healthCertificateService = healthCertificateService
		self.onDisclaimerButtonTap = onDisclaimerButtonTap
	}

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Reissuance.Consent.title

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel(
			[
				.section(
					cells: [
						.certificate(certificate, certifiedPerson: certifiedPerson),
						titleDynamicCell,
						subtileDynamicCell,
						longTextDynamicCell
					]
						.compactMap({ $0 })
				),
				.section(
					cells: [
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
				),
				.section(
					cells:
						[
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
							.space(height: 8.0),
							faqLinkDynamicCell,
							.space(height: 8.0)
						]
						.compactMap({ $0 })
				),
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
			]
		)
	}

	func markCertificateReissuanceAsSeen() {
		certifiedPerson.isNewCertificateReissuance = false
	}

	func submit(completion: @escaping (Result<Void, HealthCertificateReissuanceError>) -> Void) {
			appConfigProvider.appConfiguration()
				.sink { [weak self] appConfig in
					guard let self = self else {
						completion(.failure(.submitFailedError))
						Log.error("App config fetch during reissuance failed due to self being nil", log: .vaccination)
						return
					}
					
					let publicKeyHash = appConfig.dgcParameters.reissueServicePublicKeyDigest.sha256String()
					let trustEvaluation = DefaultTrustEvaluation(publicKeyHash: publicKeyHash)
					
					guard let certificateToReissue = self.certifiedPerson.dccWalletInfo?.certificateReissuance?.certificateToReissue.certificateRef.barcodeData,
						let certificateToReissueRef = self.certifiedPerson.dccWalletInfo?.certificateReissuance?.certificateToReissue.certificateRef else {
						completion(.failure(.certificateToReissueMissing))
						Log.error("Certificate reissuance failed: certificate to reissue is missing", log: .vaccination)
						return
					}
					
					let accompanyingCertificates = self.certifiedPerson.dccWalletInfo?.certificateReissuance?.accompanyingCertificates.compactMap {
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
							Log.error("Reissuance request failed due to self being nil", log: .vaccination)
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
								Log.error("Replacing the certificate with a reissued certificate failed, no relation found", log: .vaccination)
								return
							}
							
							do {
								try self.healthCertificateService.replaceHealthCertificate(
									oldCertificateRef: certificateToReissueRef,
									with: certificate.certificate,
									for: self.certifiedPerson
								)
								completion(.success(()))
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
			 .store(in: &subscriptions)
	}

	// MARK: - Private

	private let cclService: CCLServable
	private let certificate: HealthCertificate
	private let certifiedPerson: HealthCertifiedPerson
	private let onDisclaimerButtonTap: () -> Void
	private let appConfigProvider: AppConfigurationProviding
	private let restServiceProvider: RestServiceProviding
	private let healthCertificateService: HealthCertificateServiceServable
	private var subscriptions = Set<AnyCancellable>()
	
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

	private var titleDynamicCell: DynamicCell? {
		guard let title = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.titleText?.localized(cclService: cclService) else {
			Log.info("title missing")
			return nil
		}
		return DynamicCell.title2(text: title)
	}

	private var subtileDynamicCell: DynamicCell? {
		guard let subtitle = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.subtitleText?.localized(cclService: cclService) else {
			Log.info("subtitle missing")
			return nil
		}
		return DynamicCell.subheadline(text: subtitle)
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
