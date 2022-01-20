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
		case .downloadOfBoosterRules:
			return DMButtonCellViewModel(
				text: "download Booster Rules",
				textColor: .enaColor(for: .textContrast),
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: {
					self.healthCertificateService.checkIfBoosterRulesShouldBeFetched(completion: { errorMessage in
						if let message = errorMessage, let currentPersonName = self.healthCertifiedPerson.name?.standardizedName {
							/*
							we get error messages for all persons who didn't pass a rule so we check and show
							an alert only if:
							- an error occurred to the person that we selected in the previous screen
							- a an error that has the word "general" in the message, for example if the rules were already
							downloaded today, this is a general error for all persons
							*/
							if message.contains(currentPersonName) || message.contains("general") {
								self.createAlert(message: message)
							}
						} else {
							self.refreshTableView(
								[
									TableViewSections.lastDownloadDate.rawValue ,
									TableViewSections.cachedPassedBoosterRule.rawValue
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
		case downloadOfBoosterRules
		case clearLastDownloadDate
		case clearCurrentPersonBoosterRule
	}
	
	// MARK: - Private

	private let store: Store
	private let healthCertificateService: HealthCertificateService
	private let healthCertifiedPerson: HealthCertifiedPerson

}
#endif
