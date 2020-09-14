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
	func configure(for euTracingSettings: EUTracingSettings)
}

class EuTracingTableViewCell: UITableViewCell, ConfigurableEuTracingSettingCell {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var countryList: UILabel!
	@IBOutlet var stateLabel: UILabel!

	weak var delegate: ActionTableViewCellDelegate?
	
	var state: ENStateHandler.State?
	var viewModel: ENSettingEuTracingViewModel! {
		didSet {
			self.titleLabel.text = viewModel.title
			self.countryList.text = viewModel.countryListLabel
			self.stateLabel.text = viewModel.allCountriesEnbledStateLabel
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	func configure(for euTracingSettings: EUTracingSettings) {
		viewModel = ENSettingEuTracingViewModel(euTracingSettings: euTracingSettings)
	}
	
	func configure(for state: ENStateHandler.State) {
		self.state = state
	}
	
	func configure(
		for state: ENStateHandler.State,
		delegate: ActionTableViewCellDelegate
	) {
		self.delegate = delegate
		configure(for: state)
	}
}
