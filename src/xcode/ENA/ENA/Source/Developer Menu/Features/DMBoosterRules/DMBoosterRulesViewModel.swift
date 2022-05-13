////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMBoosterRulesViewModel {

	// MARK: - Init

	init(
		store: Store,
		service: HealthCertificateService,
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.store = store
		self.healthCertificateService = service
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal
	
	var showAlert: (UIAlertController) -> Void = { _ in }
	var refreshTableView: (IndexSet) -> Void = { _ in }
	var numberOfSections: Int {
		TableViewSections.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		guard TableViewSections.allCases.indices.contains(section) else {
			return 0
		}
		// at the moment we assume one cell per section only
		return 1
	}
	
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}
		
		switch section {
		case .cachedPassedBoosterRule:
			return DMKeyValueCellViewModel(
				key: "Cached Passed Booster Rule",
				value: healthCertifiedPerson.dccWalletInfo?.boosterNotification.identifier ?? "no booster rule passed for this person"
			)
		case .clearCurrentPersonBoosterRule:
			return DMButtonCellViewModel(
				text: "clear current person booster rule",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					guard let dccWalletInfo = self.healthCertifiedPerson.dccWalletInfo else {
						return
					}

					self.healthCertifiedPerson.dccWalletInfo = DCCWalletInfo(
						admissionState: dccWalletInfo.admissionState,
						vaccinationState: dccWalletInfo.vaccinationState,
						boosterNotification: DCCBoosterNotification(visible: false, identifier: nil, titleText: nil, subtitleText: nil, longText: nil, faqAnchor: nil),
						mostRelevantCertificate: dccWalletInfo.mostRelevantCertificate,
						verification: dccWalletInfo.verification,
						validUntil: dccWalletInfo.validUntil,
						certificateReissuance: dccWalletInfo.certificateReissuance,
						certificatesRevokedByInvalidationRules: dccWalletInfo.certificatesRevokedByInvalidationRules
					)
					self.refreshTableView([TableViewSections.cachedPassedBoosterRule.rawValue])
				}
			)
		}
	}
	
	private func createAlert(message: String) {
		let alert = UIAlertController(
			title: "Booster Error",
			message: message,
			preferredStyle: .alert
		)
		let cancelAction = UIAlertAction(title: "OK", style: .cancel) { _ in
			alert.dismiss(animated: true, completion: nil)
		}
		alert.addAction(cancelAction)
		showAlert(alert)
	}

	enum TableViewSections: Int, CaseIterable {
		case cachedPassedBoosterRule
		case clearCurrentPersonBoosterRule
	}
	
	// MARK: - Private

	private let store: Store
	private let healthCertificateService: HealthCertificateService
	private let healthCertifiedPerson: HealthCertifiedPerson

}
#endif
