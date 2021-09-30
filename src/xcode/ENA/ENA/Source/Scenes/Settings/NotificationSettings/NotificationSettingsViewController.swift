//
// 🦠 Corona-Warn-App
//

import UIKit

class NotificationSettingsViewController: DynamicTableViewController {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
		self.viewModel = NotificationSettingsViewModel()

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willEnterForeground),
			name: UIApplication.willEnterForegroundNotification,
			object: UIApplication.shared
		)
		
		setupView()
		notificationSettings()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	// MARK: - Internal
	
	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case buttonCell = "NotificationSettingsButtonCell"
	}

	// MARK: - Private

	private let store: Store
	private let viewModel: NotificationSettingsViewModel
	
	private var isNotificationOn: Bool = false
	
	private func setupView() {
		navigationItem.title = AppStrings.NotificationSettings.notifications
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
		
		setupTableView()
	}
	
	private func setupTableView() {
		
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: ReuseIdentifiers.buttonCell.rawValue
		)
		dynamicTableViewModel = isNotificationOn ? viewModel.dynamicTableViewModelNotificationOn : viewModel.dynamicTableViewModelNotificationOff
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
				self.isNotificationOn = false
				return
			}

			self.isNotificationOn = granted ? true : false

			DispatchQueue.main.async {
				self.setupView()
				self.tableView.reloadData()
			}
		}
	}
}
