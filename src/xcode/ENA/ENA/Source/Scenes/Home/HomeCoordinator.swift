//
// 🦠 Corona-Warn-App
//

import UIKit

class HomeCoordinator: RequiresAppDependencies {

	// MARK: - Init

	init(
		_ delegate: CoordinatorDelegate,
		otpService: OTPServiceProviding,
		ppacService: PrivacyPreservingAccessControl,
		eventStore: EventStoringProviding,
		coronaTestService: CoronaTestService,
		elsService: ErrorLogSubmissionProviding
	) {
		self.delegate = delegate
		self.otpService = otpService
		self.ppacService = ppacService
		self.eventStore = eventStore
		self.coronaTestService = coronaTestService
		self.elsService = elsService
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}

	// MARK: - Internal

	let rootViewController: UINavigationController = AppNavigationController(rootViewController: UIViewController())

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
			statisticsProvider: statisticsProvider,
			localStatisticsProvider: localStatisticsProvider
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
				self.showWebPage(urlString: AppStrings.SafariView.targetURL)
			},
			onAppInformationCellTap: { [weak self] in
				self?.showAppInformation()
			},
			onSettingsCellTap: { [weak self] enState in
				self?.showSettings(enState: enState)
			},
			showTestInformationResult: { [weak self] testInformationResult in
				self?.showExposureSubmission(testInformationResult: testInformationResult)
			},
			onAddLocalStatisticsTap: { [weak self] selectValueViewController in
				self?.rootViewController.present(
					UINavigationController(rootViewController: selectValueViewController),
					animated: true
				)
			},
			onAddDistrict: { [weak self] selectValueViewController in
				self?.rootViewController.presentedViewController?.present(
					UINavigationController(rootViewController: selectValueViewController),
					animated: true
				)
			},
			onDismissState: { [weak self] in
				self?.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
			},
			onDismissDistrict: { [weak self] dismissToRoot in
				if dismissToRoot {
					self?.rootViewController.dismiss(animated: true, completion: nil)
				} else {
					self?.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
				}
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
	
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	private let eventStore: EventStoringProviding
	private let coronaTestService: CoronaTestService
	private let elsService: ErrorLogSubmissionProviding

	private var homeController: HomeTableViewController?
	private var homeState: HomeState?
	private var settingsController: SettingsViewController?
	private var traceLocationsCoordinator: TraceLocationsCoordinator?
	private var settingsCoordinator: SettingsCoordinator?
	private var exposureDetectionCoordinator: ExposureDetectionCoordinator?

	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()

	private weak var delegate: CoordinatorDelegate?

	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		#if DEBUG
		if isUITesting {
			let store = MockTestStore()
			return ENAExposureSubmissionService(
				diagnosisKeysRetrieval: exposureManager,
				appConfigurationProvider: CachedAppConfigurationMock(with: CachedAppConfigurationMock.screenshotConfiguration, store: store),
				client: ClientMock(),
				store: store,
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
			if isUITesting {
				return StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			}
			#endif

			return StatisticsProvider(
				client: CachingHTTPClient(),
				store: store
			)
		}()
	
	private lazy var localStatisticsProvider: LocalStatisticsProviding = {
			#if DEBUG
			if isUITesting {
				return LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			}
			#endif

			return LocalStatisticsProvider(
				client: CachingHTTPClient(),
				store: store
			)
		}()

		private lazy var qrCodePosterTemplateProvider: QRCodePosterTemplateProvider = {
			return QRCodePosterTemplateProvider(
				client: CachingHTTPClient(),
				store: store
			)
		}()

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
			otpService: otpService,
			ppacService: ppacService
		)
		exposureDetectionCoordinator?.start()
	}

	private func showExposureSubmission(testType: CoronaTestType? = nil, testInformationResult: Result<CoronaTestRegistrationInformation, QRCodeError>? = nil) {
		// A strong reference to the coordinator is passed to the exposure submission navigation controller
		// when .start() is called. The coordinator is then bound to the lifecycle of this navigation controller
		// which is managed by UIKit.
		let coordinator = ExposureSubmissionCoordinator(
			parentNavigationController: rootViewController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			eventProvider: eventStore,
			antigenTestProfileStore: store
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

	private func showWebPage(urlString: String) {
		LinkHelper.open(urlString: urlString)
	}

	private func showAppInformation() {
		rootViewController.pushViewController(
			AppInformationViewController(
				elsService: elsService
			),
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

	// MARK: - HealthCertificate

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
			environmentProvider: Environments(),
			otpService: otpService,
			coronaTestService: coronaTestService,
			eventStore: eventStore,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
			ppacService: ppacService
		)
		developerMenu?.enableIfAllowed()
	}
	#endif
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
