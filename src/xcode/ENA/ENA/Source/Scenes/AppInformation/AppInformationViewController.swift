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

import UIKit

class AppInformationViewController: DynamicTableViewController {

	// MARK: - Properties
	private let model: [AppInformationDetailModel] = [
		.about,
		.faq,
		.terms,
		.privacy,
		.contact,
		.legal
	]

	override func loadView() {
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.backgroundColor = .preferredColor(for: .separator)

		self.view = tableView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		title = "Home_AppInformationCard_Title".localized

		dynamicTableViewModel = .init([
			.section(
				header: .space(height: 30),
				footer: .view(footerView()),
				separators: false,
				cells: self.model.map({ .body(text: $0.title) })
			)
		])

		tableView.dataSource = self
		tableView.delegate = self
    }

	func footerView() -> UIView {
		let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
		let bundleBuild = Bundle.main.infoDictionary?["CFBundleVersion"] ?? ""

		let footerView = UIView()

		let versionLabel = ENALabel()
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.text = "\(AppStrings.Home.appInformationVersion) \(bundleVersion) (\(bundleBuild))"
		versionLabel.textColor = UIColor.preferredColor(for: .textPrimary2)
		versionLabel.style = .footnote

		footerView.addSubview(versionLabel)

		versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10).isActive = true
		versionLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: 10).isActive = true

		return footerView
	}
}

extension AppInformationViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

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
}
