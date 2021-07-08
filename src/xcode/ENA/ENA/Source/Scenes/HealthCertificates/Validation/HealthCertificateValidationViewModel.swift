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
					.space(height: 8),
					.body(
						text: "Prüfen Sie vorab, ob Ihr Zertifikat im Reiseland zum Zeitpunkt der Reise gültig ist. Hierfür werden die geltenden Einreiseregeln des gewählten Reiselandes berücksichtigt.",
						accessibilityIdentifier: ""
					),
					.space(height: 8),
					.headline(
						text: "Prüfen für",
						accessibilityIdentifier: ""
					),
					countrySelectionCell(),
					.space(height: 8),
					validationDateSelectionCell(),
					.space(height: 8),
					.body(
						text: "Ein COVID-Zertifikat gilt bei Reisen innerhalb der EU als Nachweis.",
						accessibilityIdentifier: ""
					),
					.headline(
						text: "Hinweis",
						accessibilityIdentifier: ""
					),
					.bulletPoint(text: "Beachten Sie, dass sich die Einreiseregeln ändern können. Prüfen Sie daher das Zertifikat kurz vor der Einreise (max. 48 Stunden)."),
					.space(height: 8),
					.bulletPoint(text: "Es können in einzelnen Regionen weitere Regeln oder Einschränkungen gelten."),
					.space(height: 8),
					.bulletPoint(text: "Um die Echtheit eines Zertifikats sicherzustellen, wird jedes Zertifikat mit einer digitalen Signatur ausgestellt. Diese Signatur wird nur in einer Prüf-Anwendung validiert."),
					.space(height: 8),
					.bulletPoint(text: "Ob die im Zertifikat eingetragenen Daten richtig sind, wird in der Corona-Warn-App nicht geprüft."),
					.space(height: 8),
					.body(
						text: "Mehr Informationen finden Sie in den FAQ und unter https://reopen.europa.eu/de.",
						style: .textView(.link),
						accessibilityIdentifier: ""
					),
					.legal(title: NSAttributedString(string: "Datenschutz und Datensicherheit"), description: NSAttributedString(string: "Die aktuellen Einreiseregeln werden von den Servern des RKI heruntergeladen. Hierfür ist eine Verbindung zum Internet erforderlich und es werden Zugriffsdaten an das RKI übermittelt."), textBlocks: []),
					.space(height: 16)
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
						}
					),
					.space(height: 16)
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
					self?.selectedArrivalCountry = country
				}

				countrySelectionCell.countries = self.countries
				countrySelectionCell.selectedCountry = self.selectedArrivalCountry
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
					self?.selectedArrivalDate = date
				}

				validationDateSelectionCell.selectedDate = self.selectedArrivalDate
				validationDateSelectionCell.isCollapsed = self.validationDateSelectionCollapsed
			}
		}
	}
}
