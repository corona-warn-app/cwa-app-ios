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

class EUSettingsViewController: DynamicTableViewController {

	// MARK: - Public Attributes.

	var client: Client?

	// MARK: - Private Attributes

	private var viewModel = EUSettingsViewModel(countries: [])

	// MARK: - View life cycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	// MARK: - View setup methods.

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		setupDataSource()
		setupTableView()
		setupBackButton()
	}

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.euSettingsModel()
		tableView.register(
			DynamicTableViewIconCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.flagCell.rawValue
		)
	}

	// MARK: Data Source setup methods.

	private func setupDataSource() {
		client?.supportedCountries(completion: { [weak self] result in
			switch result {
			case .failure:
				// TODO: We have not defined any behaviour yet for a failed country list download.
				logError(message: "The country list could not be loaded.")
				self?.viewModel = EUSettingsViewModel(countries: [])
			case .success(let countries):
				self?.viewModel = EUSettingsViewModel(countries: countries)
			}
			self?.reloadData()
		})
	}

	private func reloadData() {
		dynamicTableViewModel = viewModel.euSettingsModel()
		tableView.reloadData()
	}
}

extension EUSettingsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case flagCell
	}
}

extension DynamicCell {
	static func euCell(cellModel: EUSettingsViewModel.CountryModel) -> Self {
		.icon(cellModel.country.flag,
			  text: cellModel.country.localizedName,
			  tintColor: nil,
			  style: .body,
			  iconWidth: 32,
			  action: .none,
			  configure: { _, cell, _ in
			cell.contentView.layoutMargins.left = 32
			cell.contentView.layoutMargins.right = 32
			cell.selectionStyle = .none
		})
	}
}
