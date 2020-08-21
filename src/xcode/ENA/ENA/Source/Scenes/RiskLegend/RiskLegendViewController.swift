//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

class RiskLegendViewController: DynamicTableViewController {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = AppStrings.RiskLegend.title

		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.AccessibilityLabel.close
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		dynamicTableViewModel = model
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}

	@IBAction func close() {
		dismiss(animated: true)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		navigationItem.rightBarButtonItem?.image = UIImage(named: "Icons - Close")
	}
}

extension RiskLegendViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case numberedTitle = "numberedTitleCell"
		case dotBody = "dotBodyCell"
	}
}
