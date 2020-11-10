// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

#if !RELEASE

import UIKit

class DMSwitchTableViewCell: UITableViewCell {

	// MARK: - Init

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		toggleSwitch.addTarget(self, action: #selector(toggleHit), for: .valueChanged)
	}

	// MARK: - Public

	// MARK: - Internal

	func configure(cellViewModel: DMSwitchCellViewModel) {
		infoLabel.text = cellViewModel.labelText
		toggleSwitch.isOn = cellViewModel.isEnabled()
		self.cellViewModel = cellViewModel
	}

	// MARK: - Private

	@IBOutlet private weak var infoLabel: UILabel!
	@IBOutlet private weak var toggleSwitch: UISwitch!

	private var cellViewModel: DMSwitchCellViewModel?

	@objc
	private func toggleHit() {
		cellViewModel?.toggle()
		setSelected(false, animated: true)
	}

}

#endif
