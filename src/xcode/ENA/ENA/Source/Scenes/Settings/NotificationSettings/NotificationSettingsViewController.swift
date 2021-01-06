//
// 🦠 Corona-Warn-App
//

import UIKit

class NotificationSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Init

	init(store: Store) {
		self.store = store

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorColor = .enaColor(for: .hairline)

		navigationItem.title = AppStrings.NotificationSettings.navigationBarTitle
		navigationController?.navigationBar.prefersLargeTitles = true

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willEnterForeground),
			name: UIApplication.willEnterForegroundNotification,
			object: UIApplication.shared
		)

		registerCells()
		// Setup view to prevent unrendered content behind the UserNotification alert
		setupView()

		notificationSettings()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.layoutIfNeeded()
		tableViewHeightConstraint.constant = tableView.contentSize.height
	}

	// MARK: - Protocol UITableViewDataSource

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

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			return UITableView.automaticDimension
		} else {
			return 38
		}
	}

	func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = viewModel.sections[section]

		switch section {
		case let .settingsOn(title, _), let .settingsOff(title, _):
			return title
		}
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 16
	}

	func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = viewModel.sections[indexPath.section]

		switch section {
		case let .settingsOn(_, cells), let .settingsOff(_, cells):
			let cellModel = cells[indexPath.row]
			return configureCell(cellModel, indexPath: indexPath)
		}
	}

	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = viewModel.sections[indexPath.section]
		let isAccessibility = traitCollection.preferredContentSizeCategory.isAccessibilityCategory

		switch section {
		case .settingsOn:
			return isAccessibility ? 230 : 44
		case .settingsOff:
			return isAccessibility ? 120 : 44
		}
	}

	// MARK: - Internal

	enum ReuseIdentifier: String {
		case notificationsOn = "notificationsOn"
		case notificationsOff = "notificationsOff"
	}

	// MARK: - Private

	@IBOutlet private weak var illustrationImageView: UIImageView!
	@IBOutlet private weak var titleLabel: ENALabel!

	@IBOutlet private weak var infoView: UIView!
	@IBOutlet private weak var infoViewTitleLabel: ENALabel!
	@IBOutlet private weak var infoViewImage: UIImageView!
	@IBOutlet private weak var infoViewDescriptionLabel: ENALabel!
	@IBOutlet private weak var infoViewButton: ENAButton!

	@IBOutlet private weak var tableView: UITableView!

	@IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!

	private let store: Store
	private var viewModel = NotificationSettingsViewModel.notificationsOff()

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

		center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
			guard let self = self else { return }

			if let error = error {
				Log.info("Error while requesting notifications permissions: \(error.localizedDescription)", log: .api)
				self.viewModel = NotificationSettingsViewModel.notificationsOff()
				return
			}

			self.viewModel = granted ? NotificationSettingsViewModel.notificationsOn(self.store) : NotificationSettingsViewModel.notificationsOff()

			DispatchQueue.main.async {
				self.setupView()
				self.tableView.reloadData()
			}
		}
	}

	private func registerCells() {
		tableView.register(
			UINib(nibName: String(describing: NotificationSettingsOnTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifier.notificationsOn.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: NotificationSettingsOffTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifier.notificationsOff.rawValue
		)
	}

	private func setupView() {
		illustrationImageView.image = UIImage(named: viewModel.image)
		illustrationImageView.isAccessibilityElement = true
		illustrationImageView.accessibilityLabel = viewModel.imageDescription
		illustrationImageView.accessibilityIdentifier = "AppStrings.Settings.imageDescription"

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

		if let infoViewButton = infoViewButton {
			infoViewButton.addConstraint(NSLayoutConstraint(item: infoViewButton, attribute: .height, relatedBy: .equal, toItem: infoViewButton.titleLabel, attribute: .height, multiplier: 1, constant: 0))
		}
	}

	private func configureCell(_ cellModel: NotificationSettingsViewModel.SettingsItems, indexPath: IndexPath) -> UITableViewCell {
		switch cellModel {
		case let .riskChanges(item), let .testsStatus(item):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier.rawValue, for: indexPath) as? NotificationSettingsOnTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.viewModel = item
			cell.configure()

			return cell
		case let .enableNotifications(item):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier.rawValue, for: indexPath) as? NotificationSettingsOffTableViewCell else {
				fatalError("No cell for reuse identifier.")
			}

			cell.configure(viewModel: item)

			return cell
		}
	}

}
