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
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// TODO: Refactor into DynamicTableViewController
		tableView.register(DynamicTableViewSpaceCell.self, forCellReuseIdentifier: CellReuseIdentifier.space.rawValue)
		tableView.register(DynamicTypeTableViewCell.Title1.self, forCellReuseIdentifier: CellReuseIdentifier.title1.rawValue)
		tableView.register(DynamicTypeTableViewCell.Title2.self, forCellReuseIdentifier: CellReuseIdentifier.title2.rawValue)
		tableView.register(DynamicTypeTableViewCell.Headline.self, forCellReuseIdentifier: CellReuseIdentifier.headline.rawValue)
		tableView.register(DynamicTypeTableViewCell.Subheadline.self, forCellReuseIdentifier: CellReuseIdentifier.subheadline.rawValue)
		tableView.register(DynamicTypeTableViewCell.Body.self, forCellReuseIdentifier: CellReuseIdentifier.body.rawValue)
		tableView.register(DynamicTypeTableViewCell.Footnote.self, forCellReuseIdentifier: CellReuseIdentifier.footnote.rawValue)

		titleLabel.text = AppStrings.RiskLegend.title
		subtitleLabel.text = AppStrings.RiskLegend.subtitle

		dynamicTableViewModel = model
	}

	@IBAction func close() {
		dismiss(animated: true)
	}
}

extension RiskLegendViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case numberedTitle = "numberedTitleCell"
		case dotBody = "dotBodyCell"

		// TODO: Refactor into DynamicTableViewController
		case space = "spaceCell"
		case title1 = "title1Cell"
		case title2 = "title2Cell"
		case headline = "headlineCell"
		case subheadline = "subheadlineCell"
		case body = "bodyCell"
		case footnote = "footnoteCell"
	}
}
