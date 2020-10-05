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

import UIKit

protocol ConfigurableEuTracingSettingCell: ConfigurableENSettingCell {
	func configure(using viewModel: ENSettingEuTracingViewModel)
}

class EuTracingTableViewCell: UITableViewCell, ConfigurableEuTracingSettingCell {

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var countryList: ENALabel!

	weak var delegate: ActionTableViewCellDelegate?

	var state: ENStateHandler.State?
	var viewModel: ENSettingEuTracingViewModel! {
		didSet {
			self.titleLabel.text = viewModel.title
			self.countryList.text = viewModel.countryListLabel
		}
	}

	func configure(using viewModel: ENSettingEuTracingViewModel = .init()) {
		self.viewModel = viewModel
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.clear
		self.selectedBackgroundView = backgroundView
	}

	func configure(for state: ENStateHandler.State) {
		self.state = state
		self.selectionStyle = .none
	}

	func configure(
		for state: ENStateHandler.State,
		delegate: ActionTableViewCellDelegate
	) {
		self.delegate = delegate
		configure(for: state)
	}
}
