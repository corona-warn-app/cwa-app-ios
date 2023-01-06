//
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class HealthCertificateValidationViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		countries: [Country],
		store: HealthCertificateStoring,
		onValidationButtonTap: @escaping (Country, Date) -> Void,
		onDisclaimerButtonTap: @escaping () -> Void,
		onInfoButtonTap: @escaping () -> Void
	) {
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.onValidationButtonTap = onValidationButtonTap
		self.onDisclaimerButtonTap = onDisclaimerButtonTap
		self.onInfoButtonTap = onInfoButtonTap
	}

	// MARK: - Internal

	enum CellIdentifiers: String, TableViewCellReuseIdentifiers {
		case countrySelectionCell = "CountrySelectionCell"
		case validationDateSelectionCell = "ValidationDateSelectionCell"
		case legalDetails = "DynamicLegalCell"
	}

	func validate() {
		onValidationButtonTap(
			store.lastSelectedValidationCountry,
			store.lastSelectedValidationDate
		)
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.space(height: 8),
					.body(
						text: AppStrings.HealthCertificate.Validation.body1,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.HealthCertificate.Validation.headline1,
						accessibilityIdentifier: ""
					),
					countrySelectionCell(),
					.space(height: 8),
					validationDateSelectionCell(),
					.space(height: 8),
					.body(
						text: AppStrings.HealthCertificate.Validation.body2,
						accessibilityIdentifier: ""
					),
					.headline(
						text: AppStrings.HealthCertificate.Validation.headline2,
						accessibilityIdentifier: ""
					),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet1, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet2, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.bullet4, spacing: .large),
					.textWithLinks(
						text: String(
							format: AppStrings.HealthCertificate.Validation.moreInformation,
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ, AppStrings.Links.healthCertificateValidationEU),
						links: [
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ: AppStrings.Links.healthCertificateValidationFAQ,
							AppStrings.Links.healthCertificateValidationEU: AppStrings.Links.healthCertificateValidationEU
						],
						linksColor: .enaColor(for: .textTint)
					),
					.legal(title: NSAttributedString(string: AppStrings.HealthCertificate.Validation.legalTitle), description: NSAttributedString(string: AppStrings.HealthCertificate.Validation.legalDescription), textBlocks: []),
					.space(height: 16)
			]),
			// Disclaimer cell
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
					),
					.space(height: 16)
				]
			)
		])
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let countries: [Country]
	private let store: HealthCertificateStoring
	private let onValidationButtonTap: (Country, Date) -> Void
	private let onDisclaimerButtonTap: () -> Void
	private let onInfoButtonTap: () -> Void
	private var countrySelectionCollapsed = true
	private var validationDateSelectionCollapsed = true

	private func countrySelectionCell() -> DynamicCell {
		DynamicCell.custom(
			withIdentifier: CellIdentifiers.countrySelectionCell,
			action: .execute(block: { controller, cell in
				if let countrySelectionCell = cell as? CountrySelectionCell,
				   let tableViewController = controller as? DynamicTableViewController {

					self.countrySelectionCollapsed = !self.countrySelectionCollapsed

					guard let indexPath = tableViewController.tableView.indexPath(for: countrySelectionCell) else {
						return
					}

					tableViewController.tableView.beginUpdates()
					tableViewController.tableView.reloadRows(at: [indexPath], with: .none)
					tableViewController.tableView.endUpdates()
				}
			}),
			accessoryAction: .none
		) { [weak self] _, cell, _ in
			guard let self = self else { return }

			if let countrySelectionCell = cell as? CountrySelectionCell {

				countrySelectionCell.didSelectCountry = { [weak self] country in
					self?.store.lastSelectedValidationCountry = country
				}

				countrySelectionCell.countries = self.countries.sortedByLocalizedName
				countrySelectionCell.selectedCountry = self.store.lastSelectedValidationCountry
				countrySelectionCell.isCollapsed = self.countrySelectionCollapsed
			}
		}
	}

	private func validationDateSelectionCell() -> DynamicCell {
		DynamicCell.custom(
			withIdentifier: CellIdentifiers.validationDateSelectionCell,
			action: .execute(block: { controller, cell in
				if let validationDateSelectionCell = cell as? ValidationDateSelectionCell,
				   let tableViewController = controller as? DynamicTableViewController {

					self.validationDateSelectionCollapsed = !self.validationDateSelectionCollapsed

					guard let indexPath = tableViewController.tableView.indexPath(for: validationDateSelectionCell) else {
						return
					}

					tableViewController.tableView.beginUpdates()
					tableViewController.tableView.reloadRows(at: [indexPath], with: .none)
					tableViewController.tableView.endUpdates()
				}
			}),
			accessoryAction: .none
		) { [weak self] _, cell, _ in
			guard let self = self else { return }

			if let validationDateSelectionCell = cell as? ValidationDateSelectionCell {

				validationDateSelectionCell.didSelectDate = { [weak self] date in
					self?.store.lastSelectedValidationDate = date
				}

				validationDateSelectionCell.didTapInfoButton = self.onInfoButtonTap
				validationDateSelectionCell.selectedDate = self.store.lastSelectedValidationDate
				validationDateSelectionCell.isCollapsed = self.validationDateSelectionCollapsed
			}
		}
	}
}
