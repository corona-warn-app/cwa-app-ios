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

class NotificationSettingsViewController: UIViewController {
	@IBOutlet var illustrationImageView: UIImageView!
	@IBOutlet var titleLabel: DynamicTypeLabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var tableView: UITableView!

	@IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!

	let store: Store
	var viewModel = NotificationSettingsViewModel.notificationsOff()

	init?(coder: NSCoder, store: Store) {
		self.store = store

		super.init(coder: coder)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension
		setTableViewEstimatedRowHeight()

		navigationItem.title = AppStrings.NotificationSettings.navigationBarTitle
		navigationController?.navigationBar.prefersLargeTitles = true

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willEnterForeground),
			name: UIApplication.willEnterForegroundNotification,
			object: UIApplication.shared
		)

		notificationSettings()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.layoutIfNeeded()
		tableViewHeightConstraint.constant = tableView.contentSize.height
	}

	override func traitCollectionDidChange(_: UITraitCollection?) {
		setTableViewEstimatedRowHeight()
	}

	@objc
	private func willEnterForeground() {
		notificationSettings()
	}

	private func setTableViewEstimatedRowHeight() {
		tableView.estimatedRowHeight = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 260 : 60
	}

	private func notificationSettings() {
		let center = UNUserNotificationCenter.current()

		center.getNotificationSettings { [weak self] settings in
			guard let self = self else { return }

			let authorized = (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional)

			self.viewModel = authorized ? NotificationSettingsViewModel.notificationsOn(self.store) : NotificationSettingsViewModel.notificationsOff()

			DispatchQueue.main.async {
				self.setupView()
				self.tableView.reloadData()
			}
		}
	}

	private func setupView() {
		tableView.separatorStyle = viewModel.notificationsOn ? .singleLine : .none

		illustrationImageView.image = UIImage(named: viewModel.image)
		titleLabel.text = viewModel.title
		descriptionLabel.text = viewModel.description
	}
}

extension NotificationSettingsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in _: UITableView) -> Int {
		viewModel.sections.count
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		let section = viewModel.sections[section]

		switch section {
		case let .settingsOn(_, cells), let .settingsOff(cells):
			return cells.count
		case .openSettings:
			return 1
		}
	}

	func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let section = viewModel.sections[section]

		switch section {
		case .openSettings:
			return 0.5
		case .settingsOff:
			return 20
		case .settingsOn:
			return UITableView.automaticDimension
		}
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = tableView.headerView(forSection: section)
		let section = viewModel.sections[section]

		switch section {
		case .openSettings:
			return cellSeparatorView(tableView)
		case .settingsOn, .settingsOff:
			return headerView
		}
	}

	func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = viewModel.sections[section]

		switch section {
		case let .settingsOn(title, _):
			return title
		case .settingsOff, .openSettings:
			return ""
		}
	}

	func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let section = viewModel.sections[section]

		switch section {
		case .settingsOff:
			return 25
		case .openSettings:
			return 0.5
		case .settingsOn:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = tableView.footerView(forSection: section)
		let section = viewModel.sections[section]

		switch section {
		case .openSettings:
			return cellSeparatorView(tableView)
		case .settingsOff, .settingsOn:
			return footerView
		}
	}

	func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = viewModel.sections[indexPath.section]

		switch section {
		case let .settingsOn(_, cells), let .settingsOff(cells):
			let cellModel = cells[indexPath.row]
			return configureCell(cellModel, indexPath: indexPath)
		case let .openSettings(cell):
			return configureCell(cell, indexPath: indexPath)
		}
	}

	private func configureCell(_ cellModel: NotificationSettingsViewModel.SettingsItems, indexPath: IndexPath) -> UITableViewCell {
		switch cellModel {
		case let .riskChanges(item), let .testsStatus(item):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath) as? NotificationSettingsOnTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.viewModel = item
			cell.configure()

			return cell
		case let .navigateSettings(item), let .pickNotifications(item), let .enableNotifications(item):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath) as? NotificationSettingsOffTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.configure(viewModel: item)

			return cell
		case let .openSettings(identifier, title):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? LabelTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.titleLabel.text = title

			return cell
		}
	}

	private func cellSeparatorView(_ tableView: UITableView) -> UIView {
		let view = UIView()
		view.backgroundColor = tableView.separatorColor
		return view
	}

	func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = viewModel.sections[indexPath.section]

		switch section {
		case .openSettings:
			guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
				UIApplication.shared.canOpenURL(settingsURL) else {
				return
			}
			UIApplication.shared.open(settingsURL)
		case .settingsOn, .settingsOff:
			return
		}
	}
}
