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

class RiskLegendTableViewController: UITableViewController {
	private let tableViewCellHeight: CGFloat = 200
	
	let riskLegend = RiskLegendFactory.getSharedRiskLegendFactory().getRiskLegend()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.allowsSelection = false
		tableView.estimatedRowHeight = tableViewCellHeight
		tableView.rowHeight = UITableView.automaticDimension
	}
	
	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		riskLegend.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: RiskLegendTableViewCell.identifier) as? RiskLegendTableViewCell else {
			return UITableViewCell()
		}
		cell.titleLabel.text = riskLegend[indexPath.row].title
		cell.detailTextView.text = riskLegend[indexPath.row].description
		cell.detailTextView.contentInset = .zero
		cell.detailTextView.textContainer.lineFragmentPadding = 0
		cell.iconImageView.image = UIImage(systemName: riskLegend[indexPath.row].imageName)
		cell.iconBackgroundView.backgroundColor = riskLegend[indexPath.row].backgroundColor
		
		return cell
	}
}
