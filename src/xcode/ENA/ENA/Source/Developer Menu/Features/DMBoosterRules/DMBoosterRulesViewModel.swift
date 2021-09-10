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
	
	// swiftlint:disable cyclomatic_complexity
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}
		
		switch section {
		case .lastDownloadDate:
			let value: String
			if let unwrappedDate = store.lastBoosterNotificationsExecutionDate {
				value = DateFormatter.localizedString(from: unwrappedDate, dateStyle: .medium, timeStyle: .medium)
			} else {
				value = "No successful download so far"
			}
			return DMKeyValueCellViewModel(key: "Last Download Date", value: value)
			
		case .clearLastDownloadDate:
			return DMButtonCellViewModel(
				text: "clear last download date",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.store.lastBoosterNotificationsExecutionDate = nil
					self.refreshTableView([TableViewSections.lastDownloadDate.rawValue])
				}
			)
		case .cachedPassedBoosterRule:
			let value: String
			if let boosterRule = healthCertifiedPerson.boosterRule {
				value = boosterRule.description.first?.desc ?? "no booster rules description"
			} else {
				value = "no booster rule passed for this person"
			}
			return DMKeyValueCellViewModel(key: "Cached Passed Booster Rule", value: value)
			
		case .clearCurrentPersonBoosterRule:
			return DMButtonCellViewModel(
				text: "clear current person booster rule",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.healthCertifiedPerson.boosterRule = nil
					self.refreshTableView([TableViewSections.cachedPassedBoosterRule.rawValue])
				}
			)
		case .cachedDownloadedRules:
			let value: String
			if let cachedRules = self.store.boosterRulesCache?.validationRules {
				value = cachedRules.compactMap({ $0.description.first?.desc }).description
			} else {
				value = "no downloaded booster rules"
			}
			return DMKeyValueCellViewModel(key: "Cached Downloaded booster Rules", value: value)
			
		case .clearCachedDownloadedRules:
			return DMButtonCellViewModel(
				text: "clear downloaded rules",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.store.boosterRulesCache = nil
					self.refreshTableView([TableViewSections.cachedDownloadedRules.rawValue])
				}
			)
		case .downloadOfBoosterRules:
			return DMButtonCellViewModel(
				text: "download Booster Rules",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.healthCertificateService.checkIfBoosterRulesShouldBeFetched(completion: { errorMessage in
						if let message = errorMessage {
							self.createAlert(message: message)
						} else {
							self.refreshTableView(
								[
									TableViewSections.lastDownloadDate.rawValue ,
									TableViewSections.cachedPassedBoosterRule.rawValue,
									TableViewSections.cachedDownloadedRules.rawValue
								]
							)
						}
					})
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
		case lastDownloadDate
		case cachedPassedBoosterRule
		case cachedDownloadedRules
		case downloadOfBoosterRules
		case clearLastDownloadDate
		case clearCurrentPersonBoosterRule
		case clearCachedDownloadedRules
	}
	
	// MARK: - Private

	private let store: Store
	private let healthCertificateService: HealthCertificateService
	private let healthCertifiedPerson: HealthCertifiedPerson

}
#endif
