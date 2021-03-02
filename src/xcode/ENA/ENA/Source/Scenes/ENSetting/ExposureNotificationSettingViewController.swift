//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import UIKit

final class ExposureNotificationSettingViewController: UITableViewController, ActionTableViewCellDelegate, ENStateHandlerUpdating {

	// MARK: - Init

	init(
		initialEnState: ENStateHandler.State,
		store: Store,
		appConfigurationProvider: AppConfigurationProviding,
		setExposureManagerEnabled: @escaping (Bool, @escaping (ExposureNotificationError?) -> Void) -> Void
	) {
		self.enState = initialEnState
		self.store = store
		self.appConfigurationProvider = appConfigurationProvider
		self.setExposureManagerEnabled = setExposureManagerEnabled

		super.init(style: .grouped)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .background)

		navigationItem.title = AppStrings.ExposureNotificationSetting.title
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
		
		registerCells()

		tableView.sectionFooterHeight = 0.0
		tableView.separatorStyle = .none
		tableView.estimatedRowHeight = 1000 // this is need to prevent jumping of scroll position when tableview datasource is reloaded
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationItem.largeTitleDisplayMode = .always
		tableView.reloadData()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in _: UITableView) -> Int {
		sections.count
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
	
	override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch sections[section] {
		case .actionCell:
			if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
				return UITableView.automaticDimension
			}
			return 40
		default:
			return CGFloat.leastNormalMagnitude
		}
	}

	override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch sections[section] {
		case .actionCell:
			return AppStrings.ExposureNotificationSetting.actionCellHeader
		default:
			return nil
		}
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return 1
	}

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let section = sections[indexPath.section]
		switch section {
		case .banner:
			return bannerCell(for: indexPath, in: tableView)
		case .actionCell:
			return actionCell(for: indexPath, in: tableView)
		case .euTracingCell:
			return euTracingCell(for: indexPath, in: tableView)
		case .daysSinceInstallationCell, .actionDetailCell:
			switch enState {
			case .enabled, .disabled:
				return tracingCell(for: indexPath, in: tableView)
			case .bluetoothOff, .restricted, .notAuthorized, .unknown, .notActiveApp:
				return actionDetailCell(for: indexPath, in: tableView)
			}
		case .descriptionCell:
			return descriptionCell(for: indexPath, in: tableView)
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]

		guard section == .euTracingCell else { return }
		
		if #available(iOS 13, *) {
			navigationItem.largeTitleDisplayMode = .always
		} else {
			navigationItem.largeTitleDisplayMode = .never
		}
		let vc = EUSettingsViewController(appConfigurationProvider: appConfigurationProvider)
		navigationController?.pushViewController(vc, animated: true)
	}

	// MARK: - Protocol ActionTableViewCellDelegate

	func performAction(action: SettingAction) {
		switch action {
		case .enable(true):
			setExposureManagerEnabled(true, handleErrorIfNeed)
		case .enable(false):
			setExposureManagerEnabled(false, handleErrorIfNeed)
		case .askConsent:
			askConsentToUser()
		}
	}

	// MARK: - Protocol ENStateHandlerUpdating

	func updateEnState(_ enState: ENStateHandler.State) {
		Log.info("Get the new state: \(enState)", log: .api)
		self.enState = enState
		lastActionCell?.configure(for: enState, delegate: self)
		tableView.reloadData()
	}

	// MARK: - Internal

	let sections = [ReusableCellIdentifier.banner, .actionCell, .euTracingCell, .daysSinceInstallationCell, .descriptionCell]
	let store: Store
	let appConfigurationProvider: AppConfigurationProviding
	var enState: ENStateHandler.State

	func persistForDPP(accepted: Bool) {
		self.store.exposureActivationConsentAccept = accepted
		self.store.exposureActivationConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
	}

	// MARK: - Private

	enum ReusableCellIdentifier: String {
		case banner
		case actionCell
		case euTracingCell
		case daysSinceInstallationCell
		case actionDetailCell
		case descriptionCell
	}

	private var lastActionCell: ActionTableViewCell?

	private let setExposureManagerEnabled: (Bool, @escaping (ExposureNotificationError?) -> Void) -> Void

	private func registerCells() {
		tableView.register(
			DaysSinceInstallTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.daysSinceInstallationCell.rawValue
		)

		tableView.register(
			ImageTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.banner.rawValue
		)

		tableView.register(
			DescriptionTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.descriptionCell.rawValue
		)

		tableView.register(
			ActionTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.actionCell.rawValue
		)
		
		tableView.register(
			ActionDetailTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.actionDetailCell.rawValue
		)

		tableView.register(
			EuTracingTableViewCell.self,
			forCellReuseIdentifier: ReusableCellIdentifier.euTracingCell.rawValue
		)
	}

	private func handleEnableError(_ error: ExposureNotificationError, alert: Bool) {
		let openSettingsAction = UIAlertAction(title: AppStrings.Common.alertActionOpenSettings, style: .default, handler: { _ in
			if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
				UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: nil)
			}
		})
		var errorMessage = ""
		switch error {
		case .exposureNotificationAuthorization:
			errorMessage = AppStrings.ExposureNotificationError.enAuthorizationError
		case .exposureNotificationRequired:
			errorMessage = AppStrings.ExposureNotificationError.enActivationRequiredError
		case .exposureNotificationUnavailable:
			errorMessage = AppStrings.ExposureNotificationError.enUnavailableError
		case .unknown(let message):
			errorMessage = AppStrings.ExposureNotificationError.enUnknownError + message
		case .apiMisuse:
			errorMessage = AppStrings.ExposureNotificationError.apiMisuse
		}
		if alert {
			alertError(message: errorMessage, title: AppStrings.ExposureNotificationError.generalErrorTitle, optInActions: [openSettingsAction])
		}
		Log.error(error.localizedDescription + " with message: " + errorMessage, log: .ui)

		// should only fail when running tests (see `main.swift`)
		if let delegate = UIApplication.shared.delegate as? CoronaWarnAppDelegate {
			delegate.requestUpdatedExposureState()
		}
		tableView.reloadData()
	}

	private func handleErrorIfNeed(_ error: ExposureNotificationError?) {
		if let error = error {
			handleEnableError(error, alert: true)
		} else {
			tableView.reloadData()
		}
	}

	private func silentErrorIfNeed(_ error: ExposureNotificationError?) {
		if let error = error {
			handleEnableError(error, alert: false)
		} else {
			tableView.reloadData()
		}
	}

	private func askConsentToUser() {
		let alert = UIAlertController(
			title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelTitle,
			message: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelBody,
			preferredStyle: .alert
		)
		let completionHandler: (UIAlertAction) -> Void = { action in
			switch action.style {
			case .default:
				self.persistForDPP(accepted: true)
				self.setExposureManagerEnabled(true, self.silentErrorIfNeed)
			case .cancel, .destructive:
				self.lastActionCell?.configure(for: self.enState, delegate: self)
				self.tableView.reloadData()
			@unknown default:
				fatalError("Not all cases of actions covered when handling the bluetooth")
			}
		}
		alert.addAction(UIAlertAction(title: AppStrings.ExposureNotificationSetting.privacyConsentActivateAction, style: .default, handler: { action in completionHandler(action) }))
		alert.addAction(UIAlertAction(title: AppStrings.ExposureNotificationSetting.privacyConsentDismissAction, style: .cancel, handler: { action in completionHandler(action) }))
		self.present(alert, animated: true, completion: nil)
	}
	
	private func bannerCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.banner.rawValue, for: indexPath) as? ImageTableViewCell else {
			fatalError("Cell is not registered")
		}
		cell.configure(for: enState)
		return cell
	}
	
	private func actionCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		if let lastActionCell = lastActionCell {
			return lastActionCell
		}
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.actionCell.rawValue, for: indexPath) as? ActionTableViewCell else {
			fatalError("Cell is not registered")
		}
		cell.configure(for: enState, delegate: self)
		lastActionCell = cell
		return cell
	}
	
	private func actionDetailCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.actionDetailCell.rawValue, for: indexPath) as? ActionDetailTableViewCell else {
			fatalError("Cell is not registered")
		}
		cell.configure(for: enState, delegate: self)
		return cell
	}

	private func euTracingCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		guard let euTracingCell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.euTracingCell.rawValue, for: indexPath) as? EuTracingTableViewCell else {
			fatalError("Cell is not registered")
		}
		euTracingCell.configure()
		return euTracingCell
	}

	private func tracingCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		guard let tracingCell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.daysSinceInstallationCell.rawValue, for: indexPath) as? DaysSinceInstallTableViewCell else {
			fatalError("Cell is not registered")
		}

		tracingCell.configure(daysSinceInstall: store.appFirstStartDate?.ageInDays ?? 0)

		return tracingCell
	}

	private func descriptionCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableCellIdentifier.descriptionCell.rawValue, for: indexPath) as? DescriptionTableViewCell else {
			fatalError("Cell is not registered")
		}
		cell.configure(for: enState)
		return cell
	}
}
