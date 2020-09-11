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

extension EUSettingsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
		case roundedCell
		case switchCell
	}
}

extension DynamicCell {

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
