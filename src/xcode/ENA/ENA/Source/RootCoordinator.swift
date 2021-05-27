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
		coronaTestService: CoronaTestService,
		contactDiaryStore: DiaryStoringProviding,
		eventStore: EventStoringProviding,
		eventCheckoutService: EventCheckoutService,
		otpService: OTPServiceProviding,
		ppacService: PrivacyPreservingAccessControl,
		healthCertificateService: HealthCertificateServiceProviding
	) {
		self.delegate = delegate
		self.coronaTestService = coronaTestService
		self.contactDiaryStore = contactDiaryStore
		self.eventStore = eventStore
		self.eventCheckoutService = eventCheckoutService
		self.otpService = otpService
		self.ppacService = ppacService
		self.healthCertificateService = healthCertificateService
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}
	
	// MARK: - Internal

	let viewController: UIViewController = {
		let viewController = UIViewController()
		viewController.view.backgroundColor = .enaColor(for: .background)
		return viewController
	}()

	func showHome(enStateHandler: ENStateHandler, route: Route?) {
		// only create and init the whole view stack if not done before
		// there for we check if the homeCoordinator exists
		defer {
			// dispatch event route handling to showEvent
			if case let .checkIn(guid) = route {
				showEvent(guid)
			}
		}

		guard let delegate = delegate,
			  homeCoordinator == nil else {
			homeCoordinator?.showHome(
				enStateHandler: enStateHandler,
				route: route
			)
			return
		}
		
		let homeCoordinator = HomeCoordinator(
			delegate,
			otpService: otpService,
			ppacService: ppacService,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)
		self.homeCoordinator = homeCoordinator
		homeCoordinator.showHome(
			enStateHandler: enStateHandler,
			route: route
		)

		let healthCertificateCoordinator = HealthCertificateCoordinator(
			store: store,
			healthCertificateService: healthCertificateService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)
		self.healthCertificateCoordinator = healthCertificateCoordinator

		// Setup checkin coordinator after app reset
		let checkInCoordinator = CheckinCoordinator(
			store: store,
			eventStore: eventStore,
			appConfiguration: appConfigurationProvider,
			eventCheckoutService: eventCheckoutService
		)
		self.checkInCoordinator = checkInCoordinator

		// ContactJournal
		let diaryCoordinator = DiaryCoordinator(
			store: store,
			diaryStore: contactDiaryStore,
			eventStore: eventStore,
			homeState: homeState
		)
		self.diaryCoordinator = diaryCoordinator

		// Tabbar
		let startTabBarItem = UITabBarItem(title: AppStrings.Tabbar.homeTitle, image: UIImage(named: "Icons_Tabbar_Home"), selectedImage: nil)
		startTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.home
		homeCoordinator.rootViewController.tabBarItem = startTabBarItem

		let certificatesTabBarItem = UITabBarItem(title: AppStrings.Tabbar.homeTitle, image: UIImage(named: "Icons_Tabbar_Certificates"), selectedImage: nil)
		certificatesTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.certificates
		healthCertificateCoordinator.viewController.tabBarItem = certificatesTabBarItem

		let eventsTabBarItem = UITabBarItem(title: AppStrings.Tabbar.checkInTitle, image: UIImage(named: "Icons_Tabbar_Checkin"), selectedImage: nil)
		eventsTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.checkin
		checkInCoordinator.viewController.tabBarItem = eventsTabBarItem

		let diaryTabBarItem = UITabBarItem(title: AppStrings.Tabbar.diaryTitle, image: UIImage(named: "Icons_Tabbar_Diary"), selectedImage: nil)
		diaryTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.diary
		diaryCoordinator.viewController.tabBarItem = diaryTabBarItem

		tabBarController.tabBar.tintColor = .enaColor(for: .tint)
		tabBarController.tabBar.barTintColor = .enaColor(for: .background)
		tabBarController.setViewControllers([homeCoordinator.rootViewController, healthCertificateCoordinator.viewController, checkInCoordinator.viewController, diaryCoordinator.viewController], animated: false)
		
		viewController.clearChildViewController()
		viewController.embedViewController(childViewController: tabBarController)
	}

	func showTestResultFromNotification(with testType: CoronaTestType) {
		homeCoordinator?.showTestResultFromNotification(with: testType)
	}
	
	func showOnboarding() {
		let onboardingVC = OnboardingInfoViewController(
			pageType: .togetherAgainstCoronaPage,
			exposureManager: self.exposureManager,
			store: self.store,
			client: self.client
		)
		
		let navigationVC = AppOnboardingNavigationController(rootViewController: onboardingVC)
		
		navigationVC.setViewControllers([onboardingVC], animated: false)
		
		tabBarController.clearChildViewController()
		tabBarController.setViewControllers([], animated: false)
		
		homeCoordinator = nil
		diaryCoordinator = nil
		checkInCoordinator = nil
		
		viewController.clearChildViewController()
		viewController.embedViewController(childViewController: navigationVC)
	}

	func showEvent(_ guid: String) {
		guard let checkInNavigationController = checkInCoordinator?.viewController,
			  let index = tabBarController.viewControllers?.firstIndex(of: checkInNavigationController) else {
			return
		}

		// Close all modal screens that would prevent showing the checkin screen first.
		tabBarController.dismiss(animated: false)
		tabBarController.selectedIndex = index
		checkInCoordinator?.showTraceLocationDetailsFromExternalCamera(guid)
	}

	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeState?.updateDetectionMode(detectionMode)
		homeCoordinator?.updateDetectionMode(detectionMode)
	}
	
	// MARK: - Private

	private weak var delegate: CoordinatorDelegate?

	private let coronaTestService: CoronaTestService
	private let contactDiaryStore: DiaryStoringProviding
	private let eventStore: EventStoringProviding
	private let eventCheckoutService: EventCheckoutService
	private let otpService: OTPServiceProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let healthCertificateService: HealthCertificateServiceProviding
	private let tabBarController = UITabBarController()

	private var homeCoordinator: HomeCoordinator?
	private var homeState: HomeState?

	private var healthCertificateCoordinator: HealthCertificateCoordinator?
	private(set) var checkInCoordinator: CheckinCoordinator?
	private(set) var diaryCoordinator: DiaryCoordinator?
	
	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()

	private var vaccinationValueSetsProvider: VaccinationValueSetsProvider {
		#if DEBUG
		if isUITesting {
			return VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		}
		#endif

		return VaccinationValueSetsProvider(client: CachingHTTPClient(), store: store)
	}

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
		homeCoordinator?.updateEnState(state)
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
