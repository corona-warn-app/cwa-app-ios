//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import MessageUI
import UIKit

final class SettingsViewController: UITableViewController, ExposureStateUpdating, ENStateHandlerUpdating, NavigationBarOpacityDelegate {

	// MARK: - Init

	init(
		store: Store,
		initialEnState: ENStateHandler.State,
		appConfigurationProvider: AppConfigurationProviding,
		onTracingCellTap: @escaping () -> Void,
		onNotificationsCellTap: @escaping () -> Void,
		onBackgroundAppRefreshCellTap: @escaping () -> Void,
		onResetCellTap: @escaping () -> Void
	) {
		self.store = store
		self.enState = initialEnState
		self.appConfigurationProvider = appConfigurationProvider

		self.onTracingCellTap = onTracingCellTap
		self.onNotificationsCellTap = onNotificationsCellTap
		self.onBackgroundAppRefreshCellTap = onBackgroundAppRefreshCellTap
		self.onResetCellTap = onResetCellTap

		super.init(style: .grouped)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.separatorColor = .enaColor(for: .hairline)

		navigationItem.title = AppStrings.Settings.navigationBarTitle

		registerCells()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateUI()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in _: UITableView) -> Int {
		Sections.allCases.count
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch Sections.allCases[section] {
		case .tracing: return 32
		case .reset: return 48
		default: return UITableView.automaticDimension
		}
	}

	override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
		let section = Sections.allCases[section]

		switch section {
		case .tracing:
			return AppStrings.Settings.tracingDescription
		case .notifications:
			return AppStrings.Settings.notificationDescription
		case .reset:
			return AppStrings.Settings.resetDescription
		case .backgroundAppRefresh:
			return AppStrings.Settings.backgroundAppRefreshDescription
		case .datadonation:
			return AppStrings.Settings.Datadonation.description
		}
	}

	override func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		guard let footerView = view as? UITableViewHeaderFooterView else { return }

		let section = Sections.allCases[section]

		switch section {
		case .reset:
			footerView.textLabel?.textAlignment = .center
		case .tracing, .notifications, .backgroundAppRefresh, .datadonation:
			footerView.textLabel?.textAlignment = .left
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = Sections.allCases[indexPath.section]

		let cell: UITableViewCell

		switch section {
		case .tracing:
			cell = configureMainCell(indexPath: indexPath, model: settingsViewModel.tracing)
		case .notifications:
			cell = configureMainCell(indexPath: indexPath, model: settingsViewModel.notifications)
		case .backgroundAppRefresh:
			cell = configureMainCell(indexPath: indexPath, model: settingsViewModel.backgroundAppRefresh)
		case .datadonation:
			cell = configureMainCell(indexPath: indexPath, model: settingsViewModel.datadonation)
		case .reset:
			guard let labelCell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.reset.rawValue, for: indexPath) as? SettingsLabelCell else {
				fatalError("No cell for reuse identifier.")
			}

			labelCell.titleLabel.text = settingsViewModel.reset

			cell = labelCell
			cell.accessibilityIdentifier = AccessibilityIdentifiers.Settings.resetLabel
		}

		cell.isAccessibilityElement = true
		cell.accessibilityTraits = .button

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = Sections.allCases[indexPath.section]

		switch section {
		case .tracing:
			onTracingCellTap()
		case .notifications:
			onNotificationsCellTap()
		case .reset:
			onResetCellTap()
		case .datadonation:
			Log.debug("NYD")
		case .backgroundAppRefresh:
			onBackgroundAppRefreshCellTap()
		}

		tableView.deselectRow(at: indexPath, animated: false)
	}

	// MARK: - Protocol ExposureStateUpdating
	func updateExposureState(_ state: ExposureManagerState) {
		checkTracingStatus()
	}

	// MARK: - Protocol ENStateHandlerUpdating
	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
		checkTracingStatus()
	}

	// MARK: - Protocol NavigationBarOpacityDelegate

	var preferredLargeTitleBackgroundColor: UIColor? { .enaColor(for: .background) }

	// MARK: - Internal

	enum Sections: CaseIterable {
		case tracing
		case notifications
		case backgroundAppRefresh
		case datadonation
		case reset
	}

	enum ReuseIdentifier: String {
		case main = "mainSettings"
		case reset = "resetSettings"
	}

	// MARK: - Private

	private let store: Store
	private let appConfigurationProvider: AppConfigurationProviding

	private let settingsViewModel = SettingsViewModel()
	private var enState: ENStateHandler.State

	private let onTracingCellTap: () -> Void
	private let onNotificationsCellTap: () -> Void
	private let onBackgroundAppRefreshCellTap: () -> Void
	private let onResetCellTap: () -> Void

	@objc
	private func updateUI() {
		checkTracingStatus()
		checkNotificationSettings()
		checkBackgroundAppRefresh()
	}

	private func registerCells() {
		tableView.register(
			UINib(nibName: String(describing: MainSettingsCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifier.main.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: SettingsLabelCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifier.reset.rawValue
		)
	}

	private func setupView() {
		updateUI()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateUI),
			name: UIApplication.willEnterForegroundNotification,
			object: UIApplication.shared
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateUI),
			name: UIApplication.backgroundRefreshStatusDidChangeNotification,
			object: UIApplication.shared
		)
	}

	private func checkTracingStatus() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.settingsViewModel.tracing.state = self.enState == .enabled
					? self.settingsViewModel.tracing.stateActive
					: self.settingsViewModel.tracing.stateInactive

			self.tableView.reloadData()
		}
	}

	private func checkNotificationSettings() {
		let currentCenter = UNUserNotificationCenter.current()

		currentCenter.getNotificationSettings { [weak self] settings in
			guard let self = self else { return }

			if (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
				&& (self.store.allowRiskChangesNotification || self.store.allowTestsStatusNotification) {
				self.settingsViewModel.notifications.setState(state: true)
			} else {
				self.settingsViewModel.notifications.setState(state: false)
			}

			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	private func checkBackgroundAppRefresh() {
		self.settingsViewModel.backgroundAppRefresh.setState(
			state: UIApplication.shared.backgroundRefreshStatus == .available
		)
	}

	private func configureMainCell(indexPath: IndexPath, model: SettingsViewModel.CellModel) -> MainSettingsCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.main.rawValue, for: indexPath) as? MainSettingsCell else {
			fatalError("No cell for reuse identifier.")
		}

		cell.configure(model: model)

		return cell
	}

}
