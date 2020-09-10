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

// TODO (KGA): Rethink ActionCell inheritance, not implemented for the moment
class EuTracingTableViewCell: UITableViewCell, ConfigurableENSettingCell {
	
	
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var countryList: UILabel!
	@IBOutlet var stateLabel: UILabel!

	weak var delegate: ActionTableViewCellDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func configure(for state: ENStateHandler.State) {
		self.titleLabel.text = "!!!Europaweite Risiko-Ermittlung"
		self.countryList.text = "!!!! DUMMY: Spanien, Griechenland, Italien"
		self.stateLabel.text = "NN"
	}

}
