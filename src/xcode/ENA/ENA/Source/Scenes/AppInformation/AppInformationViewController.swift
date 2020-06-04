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

import UIKit

class AppInformationViewController: UITableViewController {

	// MARK: - Properties
	private let model: [AppInformationDetailModel] = [
		.about,
		.faq,
		.terms,
		.privacy,
		.contact,
		.legal
	]

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		title = "Home_AppInformationCard_Title".localized

        setupTableView()
    }

	private func setupTableView() {
		tableView.contentInset = .init(top: 30, left: 0, bottom: 0, right: 0)
		tableView.backgroundColor = .preferredColor(for: .backgroundSecondary)

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "appInformationCell")

		tableView.sectionFooterHeight = UITableView.automaticDimension
		tableView.estimatedSectionFooterHeight = 20
		tableView.tableFooterView = UIView()
	}

}

extension AppInformationViewController {

	override func numberOfSections(in _: UITableView) -> Int {
		1
	}

	override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		""
	}

	override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		model.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "appInformationCell", for: indexPath)
		cell.textLabel?.text = model[indexPath.row].title

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if indexPath.row == 1 {
			WebPageHelper.showWebPage(from: self)
		} else {
			let destination = AppStoryboard.appInformation.initiate(viewControllerType: AppInformationDetailViewController.self)
			destination.model = model[indexPath.row]

			tableView.deselectRow(at: indexPath, animated: true)

			navigationController?.pushViewController(
				destination,
				animated: true
			)
		}
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
		let bundleBuild = Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""

		let footerView = UIView()

		let versionLabel = UILabel()
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.text = "\(AppStrings.Home.appInformationVersion) \(bundleVersion) (\(bundleBuild))"
		versionLabel.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 13, weight: .semibold)
		versionLabel.textColor = UIColor.preferredColor(for: .textPrimary2)
		footerView.addSubview(versionLabel)
		versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10).isActive = true
		versionLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: 10).isActive = true

		return footerView
	}
}
