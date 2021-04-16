//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeCoordinator: RequiresAppDependencies {
	private weak var delegate: CoordinatorDelegate?
	private let otpService: OTPServiceProviding
	private let eventStore: EventStoringProviding
	private let coronaTestService: CoronaTestService

	let rootViewController: UINavigationController = AppNavigationController(rootViewController: UIViewController())

	private var homeController: HomeTableViewController?
	private var homeState: HomeState?

	private var settingsController: SettingsViewController?

	private var traceLocationsCoordinator: TraceLocationsCoordinator?
	private var settingsCoordinator: SettingsCoordinator?

	private var exposureDetectionCoordinator: ExposureDetectionCoordinator?
	
	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		#if DEBUG
		if isUITesting {
			return ENAExposureSubmissionService(
				diagnosisKeysRetrieval: exposureManager,
				appConfigurationProvider: CachedAppConfigurationMock(with: CachedAppConfigurationMock.screenshotConfiguration),
				client: ClientMock(),
				store: MockTestStore(),
				eventStore: eventStore,
				coronaTestService: coronaTestService
			)
		}
		#endif

		return ENAExposureSubmissionService(
			diagnosisKeysRetrieval: exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
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
	
	private lazy var qrCodePosterTemplateProvider: QRCodePosterTemplateProvider = {
		return QRCodePosterTemplateProvider(
			client: CachingHTTPClient(serverEnvironmentProvider: store),
			store: store
		)
	}()
	
	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()

	init(
		_ delegate: CoordinatorDelegate,
		otpService: OTPServiceProviding,
		eventStore: EventStoringProviding,
		coronaTestService: CoronaTestService
	) {
		self.delegate = delegate
		self.otpService = otpService
		self.eventStore = eventStore
		self.coronaTestService = coronaTestService
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}


	private func selectHomeTabSection(route: Route?) {
		DispatchQueue.main.async { [weak self] in
			guard let rootViewController = self?.rootViewController,
				let index = self?.homeController?.tabBarController?.viewControllers?.firstIndex(of: rootViewController) else {
				Log.debug("Failed to find tabBarController and select correct tab")
				return
			}
			self?.homeController?.tabBarController?.dismiss(animated: false)
			self?.homeController?.tabBarController?.selectedIndex = index
			self?.homeController?.route = route
			self?.homeController?.showDeltaOnboardingAndAlertsIfNeeded()
		}
	}

	func showHome(enStateHandler: ENStateHandler, route: Route?) {
		guard homeController == nil else {
			guard case .rapidAntigen = route else {
				rootViewController.dismiss(animated: false)
				rootViewController.popToRootViewController(animated: false)
				homeController?.scrollToTop(animated: false)
				return
			}
			// only select tab if route is .rapidAntigen
			selectHomeTabSection(route: route)
			return
		}
		let homeState = HomeState(
			store: store,
			riskProvider: riskProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			enState: enStateHandler.state,
			statisticsProvider: statisticsProvider
		)

		let homeController = HomeTableViewController(
			viewModel: HomeTableViewModel(
				state: homeState,
				store: store,
				coronaTestService: coronaTestService,
				onTestResultCellTap: { [weak self] coronaTestType in
					self?.showExposureSubmission(testType: coronaTestType)
				}
			),
			appConfigurationProvider: appConfigurationProvider,
			route: route,
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
			onTestRegistrationCellTap: { [weak self] in
				self?.showExposureSubmission()
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
			},
			showTestInformationResult: { [weak self] testInformationResult in
			   self?.showExposureSubmission(testInformationResult: testInformationResult)
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
	}
	
	func showTestResultFromNotification(with testType: CoronaTestType) {
		if let presentedViewController = rootViewController.presentedViewController {
			presentedViewController.dismiss(animated: true) {
				self.showExposureSubmission(testType: testType)
			}
		} else {
			self.showExposureSubmission(testType: testType)
		}
	}
	
	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeState?.updateDetectionMode(detectionMode)
	}

	// MARK: - Private

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
			otpService: otpService,
			coronaTestService: coronaTestService,
			eventStore: eventStore,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider
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

	private func showRiskLegend() {
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

	private func showExposureSubmission(testType: CoronaTestType? = nil, testInformationResult: Result<CoronaTestQRCodeInformation, QRCodeError>? = nil) {
		// A strong reference to the coordinator is passed to the exposure submission navigation controller
		// when .start() is called. The coordinator is then bound to the lifecycle of this navigation controller
		// which is managed by UIKit.
		let coordinator = ExposureSubmissionCoordinator(
			parentNavigationController: rootViewController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService
		)

		if let testInformationResult = testInformationResult {
			coordinator.start(with: testInformationResult)
		} else {
			coordinator.start(with: testType)
		}
	}

	private func showStatisticsInfo() {
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
			appConfig: appConfigurationProvider,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
			eventStore: eventStore,
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
