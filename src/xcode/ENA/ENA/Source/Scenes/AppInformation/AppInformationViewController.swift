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

import Foundation
import UIKit

class AppInformationViewController: DynamicTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.backgroundColor = .enaColor(for: .separator)
		tableView.separatorColor = .enaColor(for: .hairline)

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.Home.appInformationCardTitle

		dynamicTableViewModel = .init([
			.section(
				header: .space(height: 32),
				footer: .view(footerView()),
				separators: false,
				cells: Category.allCases.compactMap { Self.model[$0] }.map { .body(text: $0.text, accessibilityIdentifier: $0.accessibilityIdentifier) }
			)
		])
    }
}

extension AppInformationViewController {
	enum Category: Int, Hashable, CaseIterable {
		case about
		case faq
		case terms
		case privacy
		case legal
		case contact
		case imprint
	}
}

extension AppInformationViewController {
	private func footerView() -> UIView {
		let versionLabel = ENALabel()
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.textColor = .enaColor(for: .textPrimary2)
		versionLabel.style = .footnote

		if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"],
			let bundleBuild = Bundle.main.infoDictionary?["CFBundleVersion"] {
			versionLabel.text = "\(AppStrings.Home.appInformationVersion) \(bundleVersion) (\(bundleBuild))"
		} else {
			versionLabel.text = "\(AppStrings.Home.appInformationVersion) <unknown>"
			logError(message: "Unknown version. Should not happen!")
		}

		let footerView = UIView()
		footerView.addSubview(versionLabel)

		versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16).isActive = true
		versionLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: 16).isActive = true

		return footerView
	}
}

extension AppInformationViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.accessoryType = .disclosureIndicator
		cell.selectionStyle = .default

		cell.isAccessibilityElement = true
		cell.accessibilityLabel = cell.textLabel?.text
		if let category = Category(rawValue: indexPath.row),
			let accessibilityIdentifier = Self.model[category]?.accessibilityIdentifier {
			cell.accessibilityIdentifier = accessibilityIdentifier
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		if let category = Category(rawValue: indexPath.row),
			let action = Self.model[category]?.action {
			self.execute(action: action)
		}
	}
}

extension AppInformationViewController: NavigationBarOpacityDelegate {
	var preferredLargeTitleBackgroundColor: UIColor? { .enaColor(for: .background) }
}
