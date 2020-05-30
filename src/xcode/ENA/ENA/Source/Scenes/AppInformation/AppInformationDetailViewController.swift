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

class AppInformationDetailViewController: UITableViewController {
	var model: AppInformationDetailModel!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationItem.title = model.title
		
		if let headerImage = model.headerImage {
			(tableView.tableHeaderView as? UIImageView)?.image = headerImage
		} else {
			tableView.tableHeaderView = nil
		}
	}
	
	override func numberOfSections(in _: UITableView) -> Int {
		1
	}
	
	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		model.content.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellContent = model.content[indexPath.item]
		
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellContent.cellType.rawValue, for: indexPath)
		
		switch cellContent {
		case let .headline(text):
			cell.textLabel?.text = text
		case let .body(text):
			cell.textLabel?.text = text
		case let .bold(text):
			cell.textLabel?.text = text
		case let .small(text):
			cell.textLabel?.text = text
		case let .tiny(text):
			cell.textLabel?.text = text
		case let .phone(text, _):
			cell.textLabel?.text = text
		case .seperator:
			break
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let cellContent = model.content[indexPath.item]
		
		switch cellContent {
		case let .phone(_, number):
			if let url = URL(string: "tel://\(number)") {
				UIApplication.shared.open(url)
			}
		default:
			break
		}
	}
}

extension AppInformationDetailViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case headline = "headlineCell"
		case body = "bodyCell"
		case bold = "boldCell"
		case small = "smallCell"
		case tiny = "tinyCell"
		case phone = "phoneCell"
		case seperator = "separatorCell"
	}
}

private extension AppInformationDetailModel.Content {
	var cellType: AppInformationDetailViewController.ReusableCellIdentifier {
		switch self {
		case .headline:
			return .headline
		case .body:
			return .body
		case .bold:
			return .bold
		case .small:
			return .small
		case .tiny:
			return .tiny
		case .phone:
			return .phone
		case .seperator:
			return .seperator
		}
	}
}
