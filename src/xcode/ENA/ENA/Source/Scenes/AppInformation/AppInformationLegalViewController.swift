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

class AppInformationLegalViewController: UITableViewController {
	var model: AppInformationLegalModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = 80.0
		tableView.rowHeight = UITableView.automaticDimension
		self.registerTableViewCells()
        tableView.reloadData()
	}
	
	override func numberOfSections(in _: UITableView) -> Int {
		1
	}

	override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		model.numberOfLegalEntries
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let legalEntry = model.legalEntry(indexPath.row)

		if let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.legalEntry.rawValue, for: indexPath) as? AppInformationLegalEntryViewCell {
			cell.labelTitle?.text = legalEntry.title
			cell.labelLicensor?.text = legalEntry.licensor
			cell.textviewLicense?.text = legalEntry.fullLicense
			cell.textviewLicense.contentInset = .zero
			cell.textviewLicense.textContainer.lineFragmentPadding = 0
			return cell
		}
		
		return UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return UITableView.automaticDimension
		} else {
			return 44.0
		}
	}
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return UITableView.automaticDimension
		} else {
			return 44.0
		}
	}
	
	private func registerTableViewCells() {
		let textFieldCell = UINib(nibName: "AppInformationLegalEntryViewCell", bundle: nil)
		self.tableView.register(textFieldCell, forCellReuseIdentifier: ReusableCellIdentifier.legalEntry.rawValue)
	}
}

extension AppInformationLegalViewController {
	enum SegueIdentifier: String {
		case detail = "legalSegue"
	}
}

extension AppInformationLegalViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case legalEntry = "legalEntryCell"
	}
}
