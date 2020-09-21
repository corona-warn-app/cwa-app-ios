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
				Country(countryCode: "BE"),
				Country(countryCode: "BG"),
				Country(countryCode: "EL"),
				Country(countryCode: "UK"),
				Country(countryCode: "CZ"),
				Country(countryCode: "DK")
			].compactMap { $0 }/*,
			euTracingSettings: EUTracingSettings(
				isAllCountriesEnbled: false,
				enabledCountries: ["BE", "EL", "CZ"]
			)*/
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
		tableView.register(
			IconCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.iconCell.rawValue
		)
	}
}

extension EUSettingsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
		case roundedCell
		case switchCell
		case iconCell
	}
}

extension DynamicCell {
	static func iconCell(icon: UIImage, title: NSMutableAttributedString, body: NSMutableAttributedString, textStyle: ENAColor, backgroundStyle: ENAColor) -> Self {
		.custom(
		withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.iconCell
		) { _, cell, _ in
			guard let cell = cell as? IconCell else { return }
			cell.configure(
				icon: icon,
				title: title,
				body: body,
				textStyle: textStyle,
				backgroundStyle: backgroundStyle
			)
		}
	}

	static func euCell(cellModel: EUSettingsViewModel.CountryModel) -> Self {
		.custom(
			withIdentifier: EUSettingsViewController.CustomCellReuseIdentifiers.switchCell,
			action: .none,
			accessoryAction: .none
		) { _, cell, _ in
			guard let cell = cell as? SwitchCell else { return }
			cell.configure(
				text: cellModel.country.localizedName,
				icon: cellModel.country.flag
			)
		}
	}
}
