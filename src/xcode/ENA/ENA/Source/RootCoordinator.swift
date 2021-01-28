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
class RootCoordinator: RequiresAppDependencies {
	
	
	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	private let viewController = UIViewController()
	
	// MARK: - Private
	private weak var delegate: CoordinatorDelegate?

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
	
	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()

	init(
		_ delegate: CoordinatorDelegate,
		contactDiaryStore: DiaryStoringProviding
	) {
		self.delegate = delegate
		self.contactDiaryStore = contactDiaryStore
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}

	func showHome(enStateHandler: ENStateHandler) {
		// Embeed HomeCoordinator VC
	}
	
	func showTestResultFromNotification(with result: TestResult) {
//		if let presentedViewController = rootViewController.presentedViewController {
//			presentedViewController.dismiss(animated: true) {
//				self.showExposureSubmission(with: result)
//			}
//		} else {
//			self.showExposureSubmission(with: result)
//		}
	}
	
	
	func showOnboarding() {
		let onboardingVC = OnboardingInfoViewController(
			pageType: .togetherAgainstCoronaPage,
			exposureManager: self.exposureManager,
			store: self.store,
			client: self.client
		)
		
		
		viewController.view.addSubview(onboardingVC.view)
//		rootViewController.navigationBar.prefersLargeTitles = false
//		rootViewController.setViewControllers(
//			[
//				OnboardingInfoViewController(
//					pageType: .togetherAgainstCoronaPage,
//					exposureManager: self.exposureManager,
//					store: self.store,
//					client: self.client
//				)
//			],
//			animated: false
//		)

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

	private func showDiary() {
//		diaryCoordinator = DiaryCoordinator(
//			store: store,
//			diaryStore: contactDiaryStore,
//			parentNavigationController: rootViewController,
//			homeState: homeState
//		)
//
//		diaryCoordinator?.start()
	}

	private func showWebPage(from viewController: UIViewController, urlString: String) {
		LinkHelper.showWebPage(from: viewController, urlString: urlString)
	}


	private func addToEnStateUpdateList(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
		   anyObject is ENStateHandlerUpdating {
			enStateUpdateList.add(anyObject)
		}
	}

}

extension RootCoordinator: ExposureSubmissionCoordinatorDelegate {
	func exposureSubmissionCoordinatorWillDisappear(_ coordinator: ExposureSubmissionCoordinating) {
		homeController?.reload()
		homeState?.updateTestResult()
	}
}

extension RootCoordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeState?.updateExposureManagerState(state)
		settingsController?.updateExposureState(state)
	}
}

extension RootCoordinator: ENStateHandlerUpdating {
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
