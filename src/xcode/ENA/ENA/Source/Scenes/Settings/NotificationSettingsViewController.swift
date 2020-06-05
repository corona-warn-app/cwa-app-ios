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
	@IBOutlet var titleLabel: ENALabel!

	@IBOutlet var infoView: UIView!
	@IBOutlet var infoViewTitleLabel: ENALabel!
	@IBOutlet var infoViewImage: UIImageView!
	@IBOutlet var infoViewDescriptionLabel: ENALabel!
	@IBOutlet var infoViewButton: ENAButton!

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
		tableView.separatorColor = .preferredColor(for: .hairline)

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

	@IBAction func openSettings(_ sender: Any) {
		guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else {
			return
		}

		UIApplication.shared.open(settingsURL)
	}

	@objc
	private func willEnterForeground() {
		notificationSettings()
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
		illustrationImageView.image = UIImage(named: viewModel.image)

		if let title = viewModel.title {
			titleLabel.isHidden = false
			titleLabel.text = title
		} else {
			titleLabel.isHidden = true
		}

		setupInfoView(viewModel.openSettings)
	}

	private func setupInfoView(_ viewModel: NotificationSettingsViewModel.OpenSettings?) {
		guard let viewModel = viewModel else {
			infoView.isHidden = true
			return
		}

		infoView.isHidden = false

		infoView.layer.cornerRadius = 14
		infoViewTitleLabel.text = viewModel.title
		infoViewImage.image = UIImage(named: viewModel.icon)
		infoViewDescriptionLabel.text = viewModel.description
		infoViewButton.setTitle(viewModel.openSettings, for: .normal)
		infoViewButton.titleLabel?.lineBreakMode = .byWordWrapping

		if let infoViewButton = infoViewButton {
			infoViewButton.addConstraint(NSLayoutConstraint(item: infoViewButton, attribute: .height, relatedBy: .equal, toItem: infoViewButton.titleLabel, attribute: .height, multiplier: 1, constant: 0))
		}
	}
}

extension NotificationSettingsViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in _: UITableView) -> Int {
		viewModel.sections.count
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		let section = viewModel.sections[section]

		switch section {
		case let .settingsOn(_, cells), let .settingsOff(_, cells):
			return cells.count
		}
	}

	func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = viewModel.sections[section]

		switch section {
		case let .settingsOn(title, _), let .settingsOff(title, _):
			return title
		}
	}

	func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = viewModel.sections[indexPath.section]

		switch section {
		case let .settingsOn(_, cells), let .settingsOff(_, cells):
			let cellModel = cells[indexPath.row]
			return configureCell(cellModel, indexPath: indexPath)
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
		case let .enableNotifications(item):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath) as? NotificationSettingsOffTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.configure(viewModel: item)

			return cell
		}
	}

	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = viewModel.sections[indexPath.section]
		let isAccessibility = traitCollection.preferredContentSizeCategory.isAccessibilityCategory

		switch section {
		case .settingsOn:
			return isAccessibility ? 220 : 44
		case .settingsOff:
			return isAccessibility ? 120 : 44
		}
	}
}
