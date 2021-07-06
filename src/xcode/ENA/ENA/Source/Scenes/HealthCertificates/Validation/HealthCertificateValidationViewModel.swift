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
		onValidationButtonTap: @escaping (Country, Date) -> Void
	) {
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.onValidationButtonTap = onValidationButtonTap
	}

	// MARK: - Internal

	var selectedArrivalCountry = Country.defaultCountry()
	var selectedArrivalDate = Date()

	func validate() {
		onValidationButtonTap(selectedArrivalCountry, selectedArrivalDate)
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(
					UIImage(named: "Illu_EU_Interop"),
					accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
					height: 250
				),
				cells: [
					.space(height: 20),
					countrySelectionCell(),
					validationDateSelectionCell(),
					.space(height: 8),
					.title1(
						text: AppStrings.ExposureNotificationSetting.euTitle,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(
						text: AppStrings.ExposureNotificationSetting.euDescription1,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.body(
						text: AppStrings.ExposureNotificationSetting.euDescription2,
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: AppStrings.ExposureNotificationSetting.euDescription3,
						accessibilityIdentifier: ""
					),
					.space(height: 16)

			]),
			// country flags and names if available
			.section(
				separators: countries.isEmpty ? .none : .all,
				cells:
					countries.isEmpty
					? [.emptyCell()]
					: [.countries(countries: countries)]
			),
			.section(
				cells: [
					.space(height: 8),
					.body(
						text: AppStrings.ExposureNotificationSetting.euDescription4,
						accessibilityIdentifier: ""
					),
					.space(height: 16)
			])
		])
	}

	// MARK: - Private

	private enum CellIdentifiers: String, TableViewCellReuseIdentifiers {
		case countrySelectionCell = "CountrySelectionCell"
		case validationDateSelectionCell = "ValidationDateSelectionCell"
	}

	private let healthCertificate: HealthCertificate
	private let countries: [Country]
	private var selectedCountry: Country?
	private var selectedValidationDate: Date?
	private let store: HealthCertificateStoring
	private let onValidationButtonTap: (Country, Date) -> Void
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
					self?.selectedCountry = country
				}

				countrySelectionCell.countries = self.countries
				countrySelectionCell.selectedCountry = self.selectedCountry
				countrySelectionCell.toggle(state: self.countrySelectionCollapsed)
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
					self?.selectedValidationDate = date
				}

				validationDateSelectionCell.selectedDate = self.selectedValidationDate
				validationDateSelectionCell.toggle(state: self.validationDateSelectionCollapsed)
			}
		}
	}
}

private extension DynamicCell {

	static func emptyCell() -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.roundedCell,
			action: .none,
			accessoryAction: .none
		) { _, cell, _ in
			if let roundedCell = cell as? DynamicTableViewRoundedCell {
				roundedCell.configure(
					title: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorTitle),
					titleStyle: .title2,
					body: NSMutableAttributedString(string: AppStrings.ExposureNotificationSetting.euEmptyErrorDescription),
					textColor: .textPrimary1,
					bgColor: .separator,
					icons: [
						UIImage(named: "Icons_MobileDaten"),
						UIImage(named: "Icon_Wifi")]
						.compactMap { $0 },
					buttonTitle: AppStrings.ExposureNotificationSetting.euEmptyErrorButtonTitle) {
					LinkHelper.open(urlString: UIApplication.openSettingsURLString)
				}
			}
		}
	}
}

extension DynamicTableViewController {

}
