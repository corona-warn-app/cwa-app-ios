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
		onDisclaimerButtonTap: @escaping () -> Void
	) {
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.onValidationButtonTap = onValidationButtonTap
		self.onDisclaimerButtonTap = onDisclaimerButtonTap
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
				cells: [
					.title1(
						text: "Gültigkeit des Zertifikates",
						accessibilityIdentifier: ""
					),
					.body(
						text: "Prüfen Sie vorab, ob Ihr Zertifikat im Reiseland zum Zeitpunkt der Reise gültig ist. Hierfür werden die geltenden Einreiseregeln des gewählten Reiselandes berücksichtigt.",
						accessibilityIdentifier: ""
					),
					.headline(
						text: "Prüfen für",
						accessibilityIdentifier: ""
					),
					countrySelectionCell(),
					validationDateSelectionCell(),
					.body(
						text: "Ein COVID-Zertifikat gilt bei Reisen innerhalb der EU als Nachweis.",
						accessibilityIdentifier: ""
					),
					.headline(
						text: "Hinweis",
						accessibilityIdentifier: ""
					),
					.bulletPoint(text: "Beachten Sie, dass sich die Einreiseregeln ändern können. Prüfen Sie daher das Zertifikat kurz vor der Einreise (max. 48 Stunden). Es können in einzelnen Regionen weitere Regeln oder Einschränkungen gelten."),
					.bulletPoint(text: "Um die Echtheit eines Zertifikats sicherzustellen, wird jedes Zertifikat mit einer digitalen Signatur ausgestellt. Diese Signatur wird nur in einer Prüf-Anwendung validiert."),
					.bulletPoint(text: "Ob die im Zertifikat eingetragenen Daten richtig sind, wird nicht geprüft."),
					.body(
						text: "Mehr Informationen finden Sie in den FAQ und unter https://reopen.europa.eu/de.",
						style: .textView(.link),
						accessibilityIdentifier: ""
					),
					.legal(title: NSAttributedString(string: "Datenschutz und Datensicherheit"), description: NSAttributedString(string: "Die aktuellen Einreiseregeln werden von den Servern des RKI heruntergeladen. Hierfür ist eine Verbindung zum Internet erforderlich und es werden Zugriffsdaten an das RKI übermittelt."), textBlocks: [])
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: "Ausführliche Hinweise zur Datenverarbeitung finden Sie in der Datenschutzerklärung",
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { [weak self] _, _ in
							self?.onDisclaimerButtonTap()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
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
	private let onDisclaimerButtonTap: () -> Void
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
				countrySelectionCell.isCollapsed(self.countrySelectionCollapsed)
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
