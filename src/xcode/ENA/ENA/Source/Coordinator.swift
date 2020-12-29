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
	It's supposed to be insantiated from `AppDelegate` or `SceneDelegate` and handed over the root view controller.
	It instantiates view controllers with dependencies and presents them.
	Should be used as a delegate in view controllers that need to communicate with other view controllers, either for navigation, or something else (e.g. transfering state).
	Helps to decouple different view controllers from each other and to remove navigation responsibility from view controllers.
*/
class Coordinator: RequiresAppDependencies {
	private weak var delegate: CoordinatorDelegate?

	private let rootViewController: UINavigationController
	private let contactDiaryStore: DiaryStoringProviding

	private var homeController: HomeViewController?
	private var settingsController: SettingsViewController?
	private var exposureDetectionController: ExposureDetectionViewController?

	private var diaryCoordinator: DiaryCoordinator?

	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		ExposureSubmissionServiceFactory.create(
			diagnosisKeysRetrieval: self.exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			client: self.client,
			store: self.store
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
			let homeController = AppStoryboard.home.initiate(viewControllerType: HomeViewController.self) { [unowned self] coder in
				HomeViewController(
					coder: coder,
					delegate: self,
					exposureManagerState: exposureManager.exposureManagerState,
					initialEnState: enStateHandler.state,
					exposureSubmissionService: self.exposureSubmissionService
				)
			}

			self.homeController = homeController

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
				AppStoryboard.onboarding.initiateInitial { [unowned self] coder in
					OnboardingInfoViewController(
						coder: coder,
						pageType: .togetherAgainstCoronaPage,
						exposureManager: self.exposureManager,
						store: self.store,
						client: self.client
					)
				}
			],
			animated: false
		)
	}

	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeController?.updateDetectionMode(detectionMode)
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
}

extension Coordinator: HomeViewControllerDelegate {
	func showRiskLegend() {
		rootViewController.present(
			AppStoryboard.riskLegend.initiateInitial(),
			animated: true,
			completion: nil
		)
	}

	func showExposureNotificationSetting(enState: ENStateHandler.State) {
		let storyboard = AppStoryboard.exposureNotificationSetting.instance
		let vc = storyboard.instantiateViewController(identifier: "ExposureNotificationSettingViewController") { coder in
			ExposureNotificationSettingViewController(
				coder: coder,
				initialEnState: enState,
				store: self.store,
				appConfigurationProvider: self.appConfigurationProvider,
				delegate: self
			)
		}
		addToEnStateUpdateList(vc)
		rootViewController.pushViewController(vc, animated: true)
	}

	func showExposureDetection(state: HomeInteractor.State, activityState: RiskProviderActivityState) {
		let state = ExposureDetectionViewController.State(
			riskState: state.riskState,
			detectionMode: state.detectionMode,
			activityState: activityState,
			previousRiskLevel: store.riskCalculationResult?.riskLevel
		)
		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				store: self.store,
				delegate: self
			)
		}
		exposureDetectionController = vc as? ExposureDetectionViewController
		rootViewController.present(vc, animated: true)
	}

	func setExposureDetectionState(state: HomeInteractor.State, activityState: RiskProviderActivityState) {
		let state = ExposureDetectionViewController.State(
			riskState: state.riskState,
			detectionMode: state.detectionMode,
			activityState: activityState,
			previousRiskLevel: store.riskCalculationResult?.riskLevel
		)
		exposureDetectionController?.state = state
	}

	func showExposureSubmission(with result: TestResult? = nil) {
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

	func showDiary() {
		diaryCoordinator = DiaryCoordinator(
			store: store,
			diaryStore: contactDiaryStore,
			parentNavigationController: rootViewController
		)

		diaryCoordinator?.start()
	}

	func showInviteFriends() {
		rootViewController.pushViewController(
			FriendsInviteController.initiate(for: .inviteFriends),
			animated: true
		)
	}

	func showWebPage(from viewController: UIViewController, urlString: String) {
		LinkHelper.showWebPage(from: viewController, urlString: urlString)
	}

	func showAppInformation() {
		rootViewController.pushViewController(
			AppInformationViewController(),
			animated: true
		)
	}

	func showSettings(enState: ENStateHandler.State) {
		let storyboard = AppStoryboard.settings.instance
		let vc = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
			SettingsViewController(
				coder: coder,
				store: self.store,
				initialEnState: enState,
				appConfigurationProvider: self.appConfigurationProvider,
				delegate: self
			)
		}
		addToEnStateUpdateList(vc)
		settingsController = vc
		rootViewController.pushViewController(vc, animated: true)
	}

	func addToEnStateUpdateList(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
		   anyObject is ENStateHandlerUpdating {
			enStateUpdateList.add(anyObject)
		}
	}
}

extension Coordinator: ExposureNotificationSettingViewControllerDelegate {
	func exposureNotificationSettingViewController(_ controller: ExposureNotificationSettingViewController, setExposureManagerEnabled enabled: Bool, then completion: @escaping Completion) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension Coordinator: ExposureDetectionViewControllerDelegate {
	func exposureDetectionViewController(
		_: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension Coordinator: ExposureSubmissionCoordinatorDelegate {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating) {
		homeController?.updateTestResultState()
	}
}

extension Coordinator: SettingsViewControllerDelegate {
	func settingsViewController(_ controller: SettingsViewController, setExposureManagerEnabled enabled: Bool, then completion: @escaping Completion) {
		setExposureManagerEnabled(enabled, then: completion)
	}

	func settingsViewControllerUserDidRequestReset(_ controller: SettingsViewController) {
		delegate?.coordinatorUserDidRequestReset(exposureSubmissionService: exposureSubmissionService)
	}
}

extension Coordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeController?.updateExposureState(state)
		settingsController?.updateExposureState(state)
		exposureDetectionController?.updateUI()
	}
}

extension Coordinator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeController?.updateEnState(state)
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
