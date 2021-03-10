//
// 🦠 Corona-Warn-App
//

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
				separators: .none,
				cells: Category.allCases.compactMap { Self.model[$0] }.map { .body(text: $0.text, accessibilityIdentifier: $0.accessibilityIdentifier) }
			)
		])
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// navigationbar is a shared property - so we need to trigger a resizing because others could have set it to false
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}

}

extension AppInformationViewController {
	enum Category: Int, Hashable, CaseIterable {
		case versionInfo
		case about
		case faq
		case terms
		case privacy
		case legal
		case contact
		case errorReport
		case imprint
	}
}

extension AppInformationViewController {
	private func footerView() -> UIView {
		let versionLabel = ENALabel()
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.textColor = .enaColor(for: .textPrimary2)
		versionLabel.style = .footnote

		let bundleVersion = Bundle.main.appVersion
		let bundleBuild = Bundle.main.appBuildNumber
		versionLabel.text = "\(AppStrings.Home.appInformationVersion) \(bundleVersion) (\(bundleBuild))"

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
