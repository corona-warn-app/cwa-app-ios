//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import UIKit

class EUSettingsViewController: DynamicTableViewController, EUSettingsDelegate {

	// MARK: - Attributes.

	fileprivate var viewModel: EUSettingsViewModel {
		EUSettingsViewModel(
			countries: [
				Country(countryCode: "DE"),
				Country(countryCode: "IT"),
				Country(countryCode: "UK")
				].compactMap { $0 }
		)
	}

	@Published var test: Bool = false

	// MARK: - View life cycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}

	// MARK: - View setup methods.

	private func setUp() {
		// title = "### Europaweite Risiko-Ermittlung"
		view.backgroundColor = .enaColor(for: .background)

		setupTableView()
		setupBackButton()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = .euSettingsModel(for: self)
		
		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionStepCell.self),
				bundle: nil
			),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue
		)
		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		tableView.register(
			SwitchCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.switchCell.rawValue
		)
	}

	// MARK: - Helper methods.

	func setAllCountries(to: Bool) {
		for row in 0..<tableView.numberOfRows(inSection: 3) {
			guard let switchCell = tableView.cellForRow(at: IndexPath(row: row, section: 3)) as? SwitchCell else { return }
			switchCell.set(to: to)
		}
	}

	private func show14DaysErrorAlert() {
		let alert = setupErrorAlert(
			title: AppStrings.ExposureNotificationSetting.eu14DaysAlertTitle,
			message: AppStrings.ExposureNotificationSetting.eu14DaysAlertDescription,
			okTitle: AppStrings.ExposureNotificationSetting.eu14DaysAlertDeactivateTitle,
			secondaryActionTitle: AppStrings.ExposureNotificationSetting.eu14DaysAlertBackTitle,
			completion: nil,
			secondaryActionCompletion: nil
		)
		present(alert, animated: true, completion: nil)
	}
}

private extension EUSettingsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
		case roundedCell
		case switchCell
	}
}

private protocol EUSettingsDelegate: class {
	var viewModel: EUSettingsViewModel { get }
	func setAllCountries(to: Bool)
}

private extension DynamicTableViewModel {

	static func euSettingsModel(for delegate: EUSettingsDelegate) -> DynamicTableViewModel {
		DynamicTableViewModel([
			.section(cells: [
				.title1(
					text: AppStrings.ExposureNotificationSetting.euTitle,
					accessibilityIdentifier: ""
				),
				.headline(
					text: AppStrings.ExposureNotificationSetting.euDescription,
					accessibilityIdentifier: ""
				)
			]),
			.section(
				separators: true,
				cells: [
					.switchCell(text: AppStrings.ExposureNotificationSetting.euAllCountries, isOn: delegate.viewModel.allCountriesEnabled) {
						delegate.viewModel.setAllCountries(to: $0)
						delegate.setAllCountries(to: $0)
					}
				]
			),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euDataTrafficDescription,
					accessibilityIdentifier: ""
				),
				.space(height: 16)
			]),
			.countrySwitchSection(from: delegate.viewModel),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euRegionDescription,
					accessibilityIdentifier: ""
				),
				.stepCell(
					title: AppStrings.ExposureNotificationSetting.euGermanRiskTitle,
					description: AppStrings.ExposureNotificationSetting.euGermanRiskDescription,
					icon: UIImage(named: "Icons_Grey_1"),
					hairline: .none
				),
				.custom(withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.roundedCell,
						configure: { _, cell, _ in
							guard let privacyStatementCell = cell as? DynamicTableViewRoundedCell else { return }
							privacyStatementCell.configure(
								title: NSMutableAttributedString(
									string: AppStrings.ExposureNotificationSetting.euPrivacyTitle
								),
								body: NSMutableAttributedString(
									string: AppStrings.ExposureNotificationSetting.euPrivacyDescription
								),
								textStyle: .textPrimary1,
								backgroundStyle: .separator
							)
					})
			])
		])
	}
}

private class EUSettingsViewModel {

	let countries: [Country]
	var enabled = [Country: Bool]()
	private(set) var allCountriesEnabled = false

	func setAllCountries(to state: Bool) {
		countries.forEach { enabled[$0] = state }
		allCountriesEnabled = state
	}

	init(countries: [Country]) {
		self.countries = countries
		setAllCountries(to: false)
	}
}

private extension DynamicSection {
	static func countrySwitchSection(from model: EUSettingsViewModel) -> DynamicSection {
		.section(
			separators: true,
			cells: model.countries.map { country in
				DynamicCell.switchCell(
					text: country.localizedName,
					icon: country.flag,
					isOn: model.enabled[country] ?? false) {
						model.enabled[country] = $0
						print("Set \(country.localizedName) to \(model.enabled[country]!)")
				}
			}
		)
	}
}

private extension DynamicCell {

	static func switchCell(text: String, icon: UIImage? = nil, isOn: Bool = false, onToggle: SwitchCell.ToggleHandler? = nil) -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell,
			action: .none,
			accessoryAction: .none
		) { _, cell, _ in
			guard let cell = cell as? SwitchCell else { return }
			cell.configure(text: text, icon: icon, isOn: isOn, onToggle: onToggle)
		}
	}
}

// TODO: Move to separate file.

private class SwitchCell: UITableViewCell {

	typealias ToggleHandler = (Bool) -> Void

	// MARK: - Private attributes.

	private let uiSwitch: UISwitch
	private var onToggleAction: ToggleHandler?

	// MARK: - Initializers.

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		uiSwitch = UISwitch()
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setUpSwitch()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Helpers.

	private func setUpSwitch() {
		accessoryView = uiSwitch
		uiSwitch.onTintColor = .enaColor(for: .tint)
		uiSwitch.addTarget(self, action: #selector(onToggle), for: .touchUpInside)
	}

	@objc
	private func onToggle() {
		onToggleAction?(uiSwitch.isOn)
	}

	// MARK: - Public API.

	func set(to on: Bool) {
		uiSwitch.setOn(on, animated: true)
		onToggle()
	}

	func configure(text: String, icon: UIImage? = nil, isOn: Bool = false, onToggle: ToggleHandler? = nil) {
		imageView?.image = icon
		textLabel?.text = text
		uiSwitch.isOn = isOn
		onToggleAction = onToggle
	}
}

// MARK: - Delete this...

/// A simple data countainer representing a country or political region.
struct Country: Equatable, Hashable {

	typealias ID = String

	/// The country identifier. Equals the initializing country code.
	let id: ID

	/// The localized name of the country using the current locale.
	let localizedName: String

	/// The flag of the current country, if present.
	let flag: UIImage?

	/// Initialize a country with a given. If no valid `countryCode` is given the initalizer returns `nil`.
	///
	/// - Parameter countryCode: An [ISO 3166 (Alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements) country two-digit code. Examples: "DE", "FR"
	init?(countryCode: ID) {
		// Check if this is a valid country
		guard let name = Locale.current.regionName(forCountryCode: countryCode) else { return nil }

		id = countryCode
		localizedName = name
		flag = UIImage(named: "flag.\(countryCode.lowercased())") ?? UIImage.checkmark
	}

	static func defaultCountry() -> Country {
		// swiftlint:disable:next force_unwrapping
		return Country(countryCode: "DE")!
	}
}

extension Locale {
	func regionName(forCountryCode code: String) -> String? {
		var identifier: String
		// quick solution for the EU scenario
		switch code.lowercased() {
		case "el":
			identifier = "gr"
		case "no":
			identifier = "nb_NO"
		default:
			identifier = code
		}
		let target = Locale(identifier: identifier)

		// catch cases where multiple languages per region might appear, e.g. Norway
		guard let regionCode = target.identifier.components(separatedBy: "_").last else {
			return nil
		}
		return localizedString(forRegionCode: regionCode)
	}
}
