//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeCoordinator: RequiresAppDependencies {
	private weak var delegate: CoordinatorDelegate?
	private let otpService: OTPServiceProviding

	let rootViewController: UINavigationController = AppNavigationController(rootViewController: UIViewController())

	private var homeController: HomeTableViewController?
	private var homeState: HomeState?

	private var settingsController: SettingsViewController?

	private var traceLocationsCoordinator: TraceLocationsCoordinator?
	private var settingsCoordinator: SettingsCoordinator?

	private var exposureDetectionCoordinator: ExposureDetectionCoordinator?

	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		ExposureSubmissionServiceFactory.create(
			diagnosisKeysRetrieval: self.exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			client: self.client,
			store: self.store
		)
	}()

	private lazy var statisticsProvider: StatisticsProvider = {
		#if DEBUG
		let useMockDataForStatistics = UserDefaults.standard.string(forKey: "useMockDataForStatistics")
		if isUITesting, useMockDataForStatistics != "NO" {
			return StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		}
		#endif

		return StatisticsProvider(
			client: CachingHTTPClient(serverEnvironmentProvider: store),
			store: store
		)
	}()
	
	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()

	init(
		_ delegate: CoordinatorDelegate,
		otpService: OTPServiceProviding
	) {
		self.delegate = delegate
		self.otpService = otpService
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}

	func showHome(enStateHandler: ENStateHandler) {
		if homeController == nil {
			let homeState = HomeState(
				store: store,
				riskProvider: riskProvider,
				exposureManagerState: exposureManager.exposureManagerState,
				enState: enStateHandler.state,
				exposureSubmissionService: exposureSubmissionService,
				statisticsProvider: statisticsProvider
			)

			let homeController = HomeTableViewController(
				viewModel: HomeTableViewModel(
					state: homeState,
					store: store
				),
				appConfigurationProvider: appConfigurationProvider,
				onInfoBarButtonItemTap: { [weak self] in
					self?.showRiskLegend()
				},
				onExposureLoggingCellTap: { [weak self] enState in
					self?.showExposureNotificationSetting(enState: enState)
				},
				onRiskCellTap: { [weak self] homeState in
					self?.showExposureDetection(state: homeState)
				},
				onInactiveCellButtonTap: { [weak self] enState in
					self?.showExposureNotificationSetting(enState: enState)
				},
				onTestResultCellTap: { [weak self] testResult in
					self?.showExposureSubmission(with: testResult)
				},
				onStatisticsInfoButtonTap: { [weak self] in
					self?.showStatisticsInfo()
				},
				onTraceLocationsCellTap: { [weak self] in
					self?.showTraceLocations()
				},
				onInviteFriendsCellTap: { [weak self] in
					self?.showInviteFriends()
				},
				onFAQCellTap: { [weak self] in
					guard let self = self else { return }
					self.showWebPage(from: self.rootViewController, urlString: AppStrings.SafariView.targetURL)
				},
				onAppInformationCellTap: { [weak self] in
					self?.showAppInformation()
				},
				onSettingsCellTap: { [weak self] enState in
					self?.showSettings(enState: enState)
				}
			)

			self.homeState = homeState
			self.homeController = homeController
			addToEnStateUpdateList(homeState)

			UIView.transition(with: rootViewController.view, duration: CATransaction.animationDuration(), options: [.transitionCrossDissolve], animations: {
				self.rootViewController.setViewControllers([homeController], animated: false)
				#if !RELEASE
				self.enableDeveloperMenuIfAllowed(in: homeController)
				#endif
			})
		} else {
			rootViewController.dismiss(animated: false)
			rootViewController.popToRootViewController(animated: false)

			homeController?.scrollToTop(animated: false)
		}
	}
	
	func showTestResultFromNotification(with result: TestResult) {
		if let presentedViewController = rootViewController.presentedViewController {
			presentedViewController.dismiss(animated: true) {
				self.showExposureSubmission(with: result)
			}
		} else {
			self.showExposureSubmission(with: result)
		}
	}
	
	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeState?.updateDetectionMode(detectionMode)
	}

	#if !RELEASE
	private var developerMenu: DMDeveloperMenu?
	private func enableDeveloperMenuIfAllowed(in controller: UIViewController) {

		developerMenu = DMDeveloperMenu(
			presentingViewController: controller,
			client: client,
			wifiClient: wifiClient,
			store: store,
			exposureManager: exposureManager,
			developerStore: UserDefaults.standard,
			exposureSubmissionService: exposureSubmissionService,
			serverEnvironment: serverEnvironment,
			otpService: otpService
		)
		developerMenu?.enableIfAllowed()
	}
	#endif

	private func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			exposureManager.enable(completion: completion)
		} else {
			exposureManager.disable(completion: completion)
		}
	}

	func showRiskLegend() {
		let riskLegendViewController = RiskLegendViewController(
			onDismiss: { [weak rootViewController] in
				rootViewController?.dismiss(animated: true)
			}
		)

		rootViewController.present(
			UINavigationController(rootViewController: riskLegendViewController),
			animated: true
		)
	}

	private func showExposureNotificationSetting(enState: ENStateHandler.State) {
		let vc = ExposureNotificationSettingViewController(
			initialEnState: enState,
			store: self.store,
			appConfigurationProvider: self.appConfigurationProvider,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, then: completion)
			}
		)
		addToEnStateUpdateList(vc)
		rootViewController.pushViewController(vc, animated: true)
	}

	private func showExposureDetection(state: HomeState) {
		guard let homeState = homeState else {
			return
		}

		exposureDetectionCoordinator = ExposureDetectionCoordinator(
			rootViewController: rootViewController,
			store: store,
			homeState: homeState,
			exposureManager: exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			otpService: otpService
		)
		exposureDetectionCoordinator?.start()
	}


	private func showExposureSubmission(with result: TestResult? = nil) {
		// A strong reference to the coordinator is passed to the exposure submission navigation controller
		// when .start() is called. The coordinator is then bound to the lifecycle of this navigation controller
		// which is managed by UIKit.
		let coordinator = ExposureSubmissionCoordinator(
			warnOthersReminder: WarnOthersReminder(store: store),
			parentNavigationController: rootViewController,
			exposureSubmissionService: exposureSubmissionService,
			store: self.store,
			delegate: self
		)

		coordinator.start(with: result)
	}

	func showStatisticsInfo() {
		let statisticsInfoController = StatisticsInfoViewController(
			onDismiss: { [weak rootViewController] in
				rootViewController?.dismiss(animated: true)
			}
		)

		rootViewController.present(
			UINavigationController(rootViewController: statisticsInfoController),
			animated: true
		)
	}

	private func showTraceLocations() {
		traceLocationsCoordinator = TraceLocationsCoordinator(
			store: store,
			parentNavigationController: rootViewController
		)

		traceLocationsCoordinator?.start()
	}

	private func showInviteFriends() {
		rootViewController.pushViewController(
			InviteFriendsViewController(),
			animated: true
		)
	}

	private func showWebPage(from viewController: UIViewController, urlString: String) {
		LinkHelper.showWebPage(from: viewController, urlString: urlString)
	}

	private func showAppInformation() {
		rootViewController.pushViewController(
			AppInformationViewController(),
			animated: true
		)
	}

	private func showSettings(enState: ENStateHandler.State) {
		settingsCoordinator = SettingsCoordinator(
			store: store,
			initialEnState: enState,
			appConfigurationProvider: appConfigurationProvider,
			parentNavigationController: rootViewController,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, then: completion)
			},
			onResetRequest: { [weak self] in
				guard let self = self else { return }

				self.delegate?.coordinatorUserDidRequestReset(exposureSubmissionService: self.exposureSubmissionService)
			}
		)

		settingsCoordinator?.start()

		addToEnStateUpdateList(settingsCoordinator)
	}

	private func addToEnStateUpdateList(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
		   anyObject is ENStateHandlerUpdating {
			enStateUpdateList.add(anyObject)
		}
	}

}

extension HomeCoordinator: ExposureSubmissionCoordinatorDelegate {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating) {
		homeController?.reload()
		homeState?.updateTestResult()
	}
}

extension HomeCoordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeState?.updateExposureManagerState(state)
		settingsController?.updateExposureState(state)
	}
}

extension HomeCoordinator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeState?.updateEnState(state)
		updateAllState(state)
	}

	private func updateAllState(_ state: ENStateHandler.State) {
		enStateUpdateList.allObjects.forEach { anyObject in
			if let updating = anyObject as? ENStateHandlerUpdating {
				updating.updateEnState(state)
			}
		}
	}
}
