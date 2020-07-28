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

import Foundation
import UIKit

class AppInformationDetailViewController: DynamicTableViewController {
	var separatorStyle: UITableViewCell.SeparatorStyle = .none { didSet { tableView?.separatorStyle = separatorStyle } }

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorColor = .enaColor(for: .hairline)
		tableView.allowsSelection = true
		tableView.separatorStyle = separatorStyle

		tableView.register(AppInformationLegalCell.self, forCellReuseIdentifier: CellReuseIdentifier.legal.rawValue)
		tableView.register(DynamicTableViewHtmlCell.self, forCellReuseIdentifier: CellReuseIdentifier.html.rawValue)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear

		if dynamicTableViewModel.cell(at: indexPath).tag == "phone" {
			cell.selectionStyle = .default
		} else {
			cell.selectionStyle = .none
		}

		return cell
	}
}


extension AppInformationDetailViewController {
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case legal = "legalCell"
		case html = "htmlCell"
	}
}

extension AppInformationDetailViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(withUrl: url, from: self)
		return false
	}
}
