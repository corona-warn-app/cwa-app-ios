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
import Combine

class EUSettingsViewController: DynamicTableViewController {

	// MARK: - Attributes.

	private var subscriptions = Set<AnyCancellable>()
	private var viewModel =
		EUSettingsViewModel(
			countries: [
				Country(countryCode: "DE"),
				Country(countryCode: "IT"),
				Country(countryCode: "UK")
				].compactMap { $0 }
		)


	// MARK: - View life cycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	// MARK: - View setup methods.

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		setupTableView()
		setupAllCountriesSwitch()
		setupBackButton()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.euSettingsModel()
		
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

	private func setupAllCountriesSwitch() {
		viewModel.errorChanges
			.sink { self.show14DaysErrorAlert(countries: $0) }
			.store(in: &subscriptions)
	}

	// MARK: - Helper methods.

	private func show14DaysErrorAlert(countries: [Country]) {
		let alert = setupErrorAlert(
			title: AppStrings.ExposureNotificationSetting.eu14DaysAlertTitle,
			message: AppStrings.ExposureNotificationSetting.eu14DaysAlertDescription,
			okTitle: AppStrings.ExposureNotificationSetting.eu14DaysAlertDeactivateTitle,
			secondaryActionTitle: AppStrings.ExposureNotificationSetting.eu14DaysAlertBackTitle,
			completion: nil,
			secondaryActionCompletion: {
				// Handle reset action, resets the switches to the state
				// before the user tapped on them.
				self.viewModel.countryModels
					.filter { countries.contains($0.country) }
					.forEach { $0.isOn = true }
			}
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


private class EUSettingsViewModel {

	// MARK: - Model.

	class CountryModel {
		let country: Country
		@Published var isOn: Bool = false

		init(_ country: Country) {
			self.country = country
		}
	}

	// MARK: - Attributes.

	private var subscriptions = Set<AnyCancellable>()
	@Published var allCountriesOn: Bool = false
	let countryModels: [CountryModel]
	let errorChanges = PassthroughSubject<[Country], Never>()

	// MARK: - Initializers.

	init(countries: [Country]) {
		self.countryModels = countries.map { CountryModel($0) }
		self.countryModels.forEach {
			$0.$isOn
				.receive(on: RunLoop.main)
				.sink { _ in self.allCountriesOn = self.countryModels.allSatisfy { $0.isOn } }
				.store(in: &subscriptions)
		}
	}

	// MARK: - DynamicTableViewModel.

	func countrySwitchSection() -> DynamicSection {
		DynamicSection.section(
			separators: true,
			cells: countryModels.map { model in
				DynamicCell.euSwitchCell(cellModel: model) { isOn in
					model.isOn = isOn
					// Send the current country.
					if !isOn { self.errorChanges.send([model.country]) }
				}
			}
		)
	}

	func euSettingsModel() -> DynamicTableViewModel {
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
					DynamicCell.switchCell(
						text: AppStrings.ExposureNotificationSetting.euAllCountries,
						isOn: allCountriesOn,
						onSwitch: self.$allCountriesOn,
						onToggle: { isOn in
							self.countryModels.forEach { $0.isOn = isOn }
							if !isOn {
								// This switch modifies all countries.
								self.errorChanges.send(self.countryModels.map { $0.country })
							}
					 })
				]
			),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euDataTrafficDescription,
					color: .enaColor(for: .textPrimary2),
					accessibilityIdentifier: ""
				),
				.space(height: 16)
			]),
			countrySwitchSection(),
			.section(cells: [
				.footnote(
					text: AppStrings.ExposureNotificationSetting.euRegionDescription,
					color: .enaColor(for: .textPrimary2),
					accessibilityIdentifier: ""
				),
				.stepCell(
					title: AppStrings.ExposureNotificationSetting.euGermanRiskTitle,
					description: AppStrings.ExposureNotificationSetting.euGermanRiskDescription,
					icon: Country(countryCode: "de")?.flag,
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


private extension DynamicCell {

	static func switchCell(text: String, icon: UIImage? = nil, isOn: Bool = false, onSwitch: Published<Bool>.Publisher? = nil, onToggle: SwitchCell.ToggleHandler? = nil) -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell,
			action: .none,
			accessoryAction: .none
		) { _, cell, _ in
			guard let cell = cell as? SwitchCell else { return }
			cell.configure(
				text: text,
				icon: icon,
				isOn: isOn,
				onSwitchSubject: onSwitch,
				onToggle: onToggle
			)
		}
	}

	static func euSwitchCell(cellModel: EUSettingsViewModel.CountryModel, onToggle: SwitchCell.ToggleHandler?) -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell,
			action: .none,
			accessoryAction: .none
		) { _, cell, _ in
			guard let cell = cell as? SwitchCell else { return }
			cell.configure(
				text: cellModel.country.localizedName,
				icon: cellModel.country.flag,
				isOn: cellModel.isOn,
				onSwitchSubject: cellModel.$isOn,
				onToggle: onToggle
			)
		}
	}

}

// TODO: Move to separate file.

/// - NOTE: The implementation may raise a 'kCFRunLoopCommonModes' warning that is a known UIKit bug: https://developer.apple.com/forums/thread/132035
private class SwitchCell: UITableViewCell {

	typealias ToggleHandler = (Bool) -> Void

	// MARK: - Private attributes.

	private let uiSwitch: UISwitch
	private var onToggleAction: ToggleHandler?
	private var subscriptions = Set<AnyCancellable>()

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

	func configure(text: String, icon: UIImage? = nil, isOn: Bool = false, onSwitchSubject: Published<Bool>.Publisher? = nil, onToggle: ToggleHandler? = nil) {
		imageView?.image = icon
		textLabel?.text = text
		uiSwitch.isOn = isOn
		onToggleAction = onToggle
		onSwitchSubject?
			.sink { self.uiSwitch.setOn($0, animated: true) }
			.store(in: &subscriptions)
	}
}
