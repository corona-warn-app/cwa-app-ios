//
// 🦠 Corona-Warn-App
//

import UIKit

/**
	A delegate protocol for reseting the state of the app, when Reset functionality is used.
*/
protocol CoordinatorDelegate: AnyObject {
	func coordinatorUserDidRequestReset(exposureSubmissionService: ExposureSubmissionService)
}

/**
	The object for coordination of communication between first and second level view controllers, including navigation.

	This class is the first point of contact for handling navigation inside the app.
	It's supposed to be instantiated from `AppDelegate` or `SceneDelegate` and handed over the root view controller.
	It instantiates view controllers with dependencies and presents them.
	Should be used as a delegate in view controllers that need to communicate with other view controllers, either for navigation, or something else (e.g. transfering state).
	Helps to decouple different view controllers from each other and to remove navigation responsibility from view controllers.
*/
class Coordinator: RequiresAppDependencies {
	private weak var delegate: CoordinatorDelegate?

	private let rootViewController: UINavigationController
	private let contactDiaryStore: DiaryStoringProviding

	private var homeController: HomeTableViewController?
	private var homeState: HomeState?

	private var settingsController: SettingsViewController?

	private var diaryCoordinator: DiaryCoordinator?
	private var settingsCoordinator: SettingsCoordinator?

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
		_ rootViewController: UINavigationController,
		contactDiaryStore: DiaryStoringProviding
	) {
		self.delegate = delegate
		self.rootViewController = rootViewController
		self.contactDiaryStore = contactDiaryStore
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
				viewModel: HomeTableViewModel(state: homeState),
				appConfigurationProvider: appConfigurationProvider,
				onInfoBarButtonItemTap: { [weak self] in
					self?.showRiskLegend()
				},
				onExposureDetectionCellTap: { [weak self] enState in
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
				onDiaryCellTap: { [weak self] in
					self?.showDiary()
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
	
	
	func showOnboarding() {
		rootViewController.navigationBar.prefersLargeTitles = false
		rootViewController.setViewControllers(
			[
				OnboardingInfoViewController(
					pageType: .togetherAgainstCoronaPage,
					exposureManager: self.exposureManager,
					store: self.store,
					client: self.client
				)
			],
			animated: false
		)

		// Reset the homeController, so its freshly recreated after onboarding.
		homeController = nil
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
			serverEnvironment: serverEnvironment
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

		let vc = ExposureDetectionViewController(
			viewModel: ExposureDetectionViewModel(
				homeState: homeState,
				onInactiveButtonTap: { [weak self] completion in
					self?.setExposureManagerEnabled(true, then: completion)
				}
			),
			store: store
		)

		rootViewController.present(vc, animated: true)
	}

	private func showExposureSubmission(with result: TestResult? = nil) {
		// A strong reference to the coordinator is passed to the exposure submission navigation controller
		// when .start() is called. The coordinator is then bound to the lifecycle of this navigation controller
		// which is managed by UIKit.
		let coordinator = ExposureSubmissionCoordinator(
			warnOthersReminder: WarnOthersReminder(store: store),
			parentNavigationController: rootViewController,
			exposureSubmissionService: exposureSubmissionService,
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

	private func showDiary() {
		diaryCoordinator = DiaryCoordinator(
			store: store,
			diaryStore: contactDiaryStore,
			parentNavigationController: rootViewController,
			homeState: homeState
		)

		diaryCoordinator?.start()
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

extension Coordinator: ExposureSubmissionCoordinatorDelegate {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating) {
		homeController?.reload()
		homeState?.updateTestResult()
	}
}

extension Coordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeState?.updateExposureManagerState(state)
		settingsController?.updateExposureState(state)
	}
}

extension Coordinator: ENStateHandlerUpdating {
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
