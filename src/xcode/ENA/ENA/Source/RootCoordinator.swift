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
	
	// MARK: - Internal
	let viewController = UIViewController()
	
	func showHome(enStateHandler: ENStateHandler) {
		viewController.clearChildViewController()
		
		// Home
		guard let delegate = delegate else {
			return
		}
		
		let homeCoordinator = HomeCoordinator(delegate)
		self.homeCoordinator = homeCoordinator
		homeCoordinator.showHome(enStateHandler: enStateHandler)
		
		
		// ContactJournal
		let diaryCoordinator = DiaryCoordinator(
			store: store,
			diaryStore: contactDiaryStore,
			homeState: homeState
		)
		self.diaryCoordinator = diaryCoordinator
		
		
		// Tabbar
		let startTabbarItem = UITabBarItem(title: AppStrings.Tabbar.homeTitle, image: UIImage(named: "Icons_Tabbar_Home"), selectedImage: nil)
		startTabbarItem.accessibilityIdentifier = AccessibilityIdentifiers.Tabbar.home
		homeCoordinator.rootViewController.tabBarItem = startTabbarItem
		
		
		let diaryTabbarItem = UITabBarItem(title: AppStrings.Tabbar.diaryTitle, image: UIImage(named: "Icons_Tabbar_Diary"), selectedImage: nil)
		diaryTabbarItem.accessibilityIdentifier = AccessibilityIdentifiers.Tabbar.diary
		diaryCoordinator.viewController.tabBarItem = diaryTabbarItem

		let tabbarVC = UITabBarController()
		tabbarVC.tabBar.tintColor = .enaColor(for: .tint)
		tabbarVC.tabBar.barTintColor = .enaColor(for: .background)
		#if DEBUG
		let dummyDataDonationViewControllre = DataDonationViewController(
			presentSelectValueList: { [weak self] selectValueViewModel in
				self?.presentSelectValueList(selectValueViewModel: selectValueViewModel)
			},
			didTapLegal: {}
		)
		dummyDataDonationViewControllre.tabBarItem = UITabBarItem(title: "Dummy", image: UIImage(named: "bolt"), selectedImage: UIImage(named: "bolt.fill"))
		let navigationController = UINavigationController(rootViewController: dummyDataDonationViewControllre)
		tabbarVC.setViewControllers([homeCoordinator.rootViewController, diaryCoordinator.viewController, navigationController], animated: false)
		#else
		tabbarVC.setViewControllers([homeCoordinator.rootViewController, diaryCoordinator.viewController], animated: false)
		#endif
		viewController.embedViewController(childViewController: tabbarVC)
	}

	// MARK: - Datadonation Test Code

	private func presentSelectValueList(selectValueViewModel: SelectValueViewModel) {
		let selectValueViewController = SelectValueTableViewController(
			selectValueViewModel,
			dissmiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			})
		let navigationController = UINavigationController(rootViewController: selectValueViewController)
		viewController.present(navigationController, animated: true)
	}

	// MARK: -

	
	func showTestResultFromNotification(with result: TestResult) {
		homeCoordinator?.showTestResultFromNotification(with: result)
	}
	
	
	func showOnboarding() {
		let onboardingVC = OnboardingInfoViewController(
			pageType: .togetherAgainstCoronaPage,
			exposureManager: self.exposureManager,
			store: self.store,
			client: self.client
		)
		
		let navigationVC = AppNavigationController()
		
		navigationVC.setViewControllers([onboardingVC], animated: false)
		
		viewController.clearChildViewController()
		viewController.embedViewController(childViewController: navigationVC)
	}

	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeState?.updateDetectionMode(detectionMode)
		homeCoordinator?.updateDetectionMode(detectionMode)
	}
	
	// MARK: - Private
	
	private weak var delegate: CoordinatorDelegate?

	private let contactDiaryStore: DiaryStoringProviding

	private var homeCoordinator: HomeCoordinator?
	private var homeState: HomeState?

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

}

// MARK: - Protocol ExposureStateUpdating
extension RootCoordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeState?.updateExposureManagerState(state)
		homeCoordinator?.updateExposureState(state)
	}
}

// MARK: - Protocol ENStateHandlerUpdating
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
