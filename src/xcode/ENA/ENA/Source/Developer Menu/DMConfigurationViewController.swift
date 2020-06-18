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

#if !RELEASE

import UIKit

final class DMConfigurationViewController: UITableViewController, RequiresAppDependencies {

	// MARK: Creating a Configuration View Controller

	init(distributionURL: String?, submissionURL: String?, verificationURL: String?) {
		self.distributionURL = distributionURL
		self.submissionURL = submissionURL
		self.verificationURL = verificationURL
		super.init(style: .plain)
		title = "⚙️ Configuration"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties

	private let distributionURL: String?
	private let submissionURL: String?
	private let verificationURL: String?

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(
			DMConfigurationCell.self,
			forCellReuseIdentifier: DMConfigurationCell.reuseIdentifier
		)
		tableView.sectionFooterHeight = UITableView.automaticDimension
		tableView.estimatedSectionFooterHeight = 20
		tableView.tableFooterView = UIView()
	}

	// MARK: UITableViewController

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DMConfigurationCell.reuseIdentifier, for: indexPath)
		let title: String?
		let subtitle: String?
		switch indexPath.row {
		case 0:
			title = "Distribution URL"
			subtitle = distributionURL ?? "<none>"
		case 1:
			title = "Submission URL"
			subtitle = submissionURL ?? "<none>"
		case 2:
			title = "Verification URL"
			subtitle = verificationURL ?? "<none>"
		case 3:
			title = "Last Risk Calculation"
			subtitle = lastRiskCalculation
		default:
			title = nil
			subtitle = nil
		}
		cell.textLabel?.text = title
		cell.detailTextLabel?.text = subtitle
		cell.detailTextLabel?.numberOfLines = 0
		return cell
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		4
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView()
		footerView.backgroundColor = .enaColor(for: .background)

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Hourly Fetching:"
		label.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 15, weight: .regular)
		label.textColor = .enaColor(for: .textPrimary1)

		footerView.addSubview(label)
		label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 15).isActive = true
		label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		label.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true

		let toggle = UISwitch()
		toggle.translatesAutoresizingMaskIntoConstraints = false
		toggle.isOn = store.hourlyFetchingEnabled
		toggle.addTarget(self, action: #selector(self.changeHourlyFetching), for: .valueChanged)

		footerView.addSubview(toggle)
		toggle.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		toggle.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true

		footerView.sizeToFit()

		return footerView
	}

	@objc
	func changeHourlyFetching(_ toggle: UISwitch) {
		store.hourlyFetchingEnabled = toggle.isOn
	}
}

private class DMConfigurationCell: UITableViewCell {
	static var reuseIdentifier = "DMConfigurationCell"
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

#endif
