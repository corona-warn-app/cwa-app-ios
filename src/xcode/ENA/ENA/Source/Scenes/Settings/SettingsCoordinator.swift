//
// 🦠 Corona-Warn-App
//

import UIKit

class SettingsCoordinator: ENStateHandlerUpdating {

	// MARK: - Init

	init(
		store: Store,
		initialEnState: ENStateHandler.State,
		appConfigurationProvider: AppConfigurationProviding,
		parentNavigationController: UINavigationController,
		setExposureManagerEnabled: @escaping (Bool, @escaping (ExposureNotificationError?) -> Void) -> Void,
		onResetRequest: @escaping () -> Void
	) {
		self.store = store
		self.enState = initialEnState
		self.appConfigurationProvider = appConfigurationProvider
		self.parentNavigationController = parentNavigationController
		self.setExposureManagerEnabled = setExposureManagerEnabled
		self.onResetRequest = onResetRequest
	}

	// MARK: - Internal

	func start() {
		parentNavigationController?.pushViewController(settingsScreen, animated: true)
	}

	// MARK: - Protocol ENStateHandlerUpdating

	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
		settingsScreen.updateEnState(state)
		notificationSettingsViewController?.updateEnState(state)
	}

	// MARK: - Private

	private let store: Store
	private var enState: ENStateHandler.State
	private let appConfigurationProvider: AppConfigurationProviding
	private let setExposureManagerEnabled: (Bool, @escaping  (ExposureNotificationError?) -> Void) -> Void
	private let onResetRequest: () -> Void

	private weak var parentNavigationController: UINavigationController?
	private weak var notificationSettingsViewController: ExposureNotificationSettingViewController?

	// MARK: Show Screens

	private lazy var settingsScreen: SettingsViewController = {
		return SettingsViewController(
			store: store,
			initialEnState: enState,
			appConfigurationProvider: appConfigurationProvider,
			onTracingCellTap: { [weak self] in
				self?.showTracingScreen()
			},
			onNotificationsCellTap: { [weak self] in
				self?.showNotificationsScreen()
			},
			onBackgroundAppRefreshCellTap: { [weak self] in
				self?.showBackgroundAppRefreshScreen()
			},
			onResetCellTap: { [weak self] in
				self?.showResetScreen()
			}
		)
	}()

	private func showResetScreen() {
		var navigationController: UINavigationController!
		let viewController = ResetViewController(
			onResetRequest: { [weak self] in
				self?.onResetRequest()
			},
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)

		navigationController = UINavigationController(rootViewController: viewController)
		parentNavigationController?.present(navigationController, animated: true)
	}

	private func showTracingScreen() {
		let viewController = ExposureNotificationSettingViewController(
			initialEnState: enState,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, completion)
			}
		)
		self.notificationSettingsViewController = viewController

		parentNavigationController?.pushViewController(viewController, animated: true)
	}

	private func showNotificationsScreen() {
		let viewController = NotificationSettingsViewController(store: store)

		parentNavigationController?.pushViewController(viewController, animated: true)
	}

	private func showBackgroundAppRefreshScreen() {
		let viewController = BackgroundAppRefreshViewController()

		parentNavigationController?.pushViewController(viewController, animated: true)
	}
	
}
