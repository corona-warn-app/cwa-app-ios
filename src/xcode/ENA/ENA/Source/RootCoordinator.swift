//
// 🦠 Corona-Warn-App
//

import UIKit

/**
	A delegate protocol for resetting the state of the app, when Reset functionality is used.
*/
protocol CoordinatorDelegate: AnyObject {
	func coordinatorUserDidRequestReset(exposureSubmissionService: ExposureSubmissionService)
}

/**
	The object for coordination of communication between first and second level view controllers, including navigation.

	This class is the first point of contact for handling navigation inside the app.
	It's supposed to be instantiated from `AppDelegate` or `SceneDelegate` and handed over the root view controller.
	It instantiates view controllers with dependencies and presents them.
	Should be used as a delegate in view controllers that need to communicate with other view controllers, either for navigation, or something else (e.g. transferring state).
	Helps to decouple different view controllers from each other and to remove navigation responsibility from view controllers.
*/
class RootCoordinator: NSObject, RequiresAppDependencies, UITabBarControllerDelegate {

	// MARK: - Init
	
	init(
		_ delegate: CoordinatorDelegate,
		coronaTestService: CoronaTestService,
		contactDiaryStore: DiaryStoringProviding,
		eventStore: EventStoringProviding,
		eventCheckoutService: EventCheckoutService,
		otpService: OTPServiceProviding,
		ppacService: PrivacyPreservingAccessControl,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		elsService: ErrorLogSubmissionProviding,
		recycleBin: RecycleBin
	) {
		self.delegate = delegate
		self.coronaTestService = coronaTestService
		self.contactDiaryStore = contactDiaryStore
		self.eventStore = eventStore
		self.eventCheckoutService = eventCheckoutService
		self.otpService = otpService
		self.ppacService = ppacService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.elsService = elsService
		self.recycleBin = recycleBin
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}

	// MARK: - Protocol UITabBarControllerDelegate

	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		if viewController == tabBarController.selectedViewController {
			if let naviVC = viewController as? UINavigationController {
				naviVC.scrollEmbeddedViewToTop()
			}
		}

		if viewController == universalScannerDummyViewController {
			let selectedTab: SelectedTab?
			switch tabBarController.selectedIndex {
			case 0:
				selectedTab = .home
			case 1:
				selectedTab = .certificates
			case 3:
				selectedTab = .checkin
			case 4:
				selectedTab = .diary
			default:
				selectedTab = nil
			}

			qrScannerCoordinator?.start(
				parentViewController: self.viewController,
				presenter: .universalScanner(selectedTab)
			)

			return false
		}

		return true
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
			// route handling to showCertificate from notification
			else if case let .healthCertificateFromNotification(healthCertifiedPerson, healthCertificate) = route {
				showHealthCertificateFromNotification(for: healthCertifiedPerson, with: healthCertificate)
			}
			// route handling to show HealthCertifiedPerson from booster notification
			else if case let .healthCertifiedPersonFromNotification(healthCertifiedPerson) = route {
				showHealthCertifiedPersonFromNotification(for: healthCertifiedPerson)
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
		
		let qrScannerCoordinator = QRScannerCoordinator(
			store: store,
			client: client,
			eventStore: eventStore,
			appConfiguration: appConfigurationProvider,
			eventCheckoutService: eventCheckoutService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService
		)
		self.qrScannerCoordinator = qrScannerCoordinator
		
		let homeCoordinator = HomeCoordinator(
			delegate,
			otpService: otpService,
			ppacService: ppacService,
			eventStore: eventStore,
			coronaTestService: coronaTestService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			elsService: elsService,
			exposureSubmissionService: exposureSubmissionService,
			qrScannerCoordinator: qrScannerCoordinator,
			recycleBin: recycleBin
		)
		self.homeCoordinator = homeCoordinator
		homeCoordinator.showHome(
			enStateHandler: enStateHandler,
			route: route
		)
	
		let healthCertificatesTabCoordinator = HealthCertificatesTabCoordinator(
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			qrScannerCoordinator: qrScannerCoordinator
		)
		self.healthCertificatesTabCoordinator = healthCertificatesTabCoordinator

		// Setup checkin coordinator after app reset
		let checkinTabCoordinator = CheckinTabCoordinator(
			store: store,
			eventStore: eventStore,
			appConfiguration: appConfigurationProvider,
			eventCheckoutService: eventCheckoutService,
			qrScannerCoordinator: qrScannerCoordinator
		)
		self.checkinTabCoordinator = checkinTabCoordinator

		// ContactJournal
		let diaryCoordinator = DiaryCoordinator(
			store: store,
			diaryStore: contactDiaryStore,
			eventStore: eventStore,
			homeState: homeState
		)
		self.diaryCoordinator = diaryCoordinator
		
		// Tabbar
		let startTabBarItem = UITabBarItem(
			title: AppStrings.Tabbar.homeTitle,
			image: UIImage(named: "Icons_Tabbar_Home"),
			selectedImage: UIImage(named: "Icons_Tabbar_Home_Selected")
		)
		startTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.home
		homeCoordinator.rootViewController.tabBarItem = startTabBarItem

		let certificatesTabBarItem = UITabBarItem(
			title: AppStrings.Tabbar.certificatesTitle,
			image: UIImage(named: "Icons_Tabbar_Certificates"),
			selectedImage: UIImage(named: "Icons_Tabbar_Certificates_Selected")
		)
		certificatesTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.certificates
		healthCertificatesTabCoordinator.viewController.tabBarItem = certificatesTabBarItem

		let universalScannerTabBarItem = UITabBarItem(
			title: nil,
			image: UIImage(named: "Icons_Tabbar_UniversalScanner"),
			selectedImage: nil
		)
		universalScannerTabBarItem.accessibilityLabel = AppStrings.Tabbar.scannerTitle
		universalScannerTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.scanner
		universalScannerDummyViewController.tabBarItem = universalScannerTabBarItem

		let eventsTabBarItem = UITabBarItem(
			title: AppStrings.Tabbar.checkInTitle,
			image: UIImage(named: "Icons_Tabbar_Checkin"),
			selectedImage: UIImage(named: "Icons_Tabbar_Checkin_Selected")
		)
		eventsTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.checkin
		checkinTabCoordinator.viewController.tabBarItem = eventsTabBarItem

		let diaryTabBarItem = UITabBarItem(
			title: AppStrings.Tabbar.diaryTitle,
			image: UIImage(named: "Icons_Tabbar_Diary"),
			selectedImage: UIImage(named: "Icons_Tabbar_Diary_Selected")
		)
		diaryTabBarItem.accessibilityIdentifier = AccessibilityIdentifiers.TabBar.diary
		diaryCoordinator.viewController.tabBarItem = diaryTabBarItem

		tabBarController.tabBar.tintColor = .enaColor(for: .tint)
		tabBarController.delegate = self
		tabBarController.setViewControllers([homeCoordinator.rootViewController, healthCertificatesTabCoordinator.viewController, universalScannerDummyViewController, checkinTabCoordinator.viewController, diaryCoordinator.viewController], animated: false)

		viewController.clearChildViewController()
		viewController.embedViewController(childViewController: tabBarController)
	}

	func showTestResultFromNotification(with testType: CoronaTestType) {
		homeCoordinator?.showTestResultFromNotification(with: testType)
	}
	
	func showHealthCertificateFromNotification(
		for healthCertifiedPerson: HealthCertifiedPerson,
		with healthCertificate: HealthCertificate
	) {
		
		guard let healthCertificateNavigationController = healthCertificatesTabCoordinator?.viewController,
			  let index = tabBarController.viewControllers?.firstIndex(of: healthCertificateNavigationController) else {
			Log.warning("Could not show certificate because i could find the corresponding navigation controller.")
			return
		}

		// Close all modal screens that would prevent showing the certificate.
		tabBarController.dismiss(animated: false)
		tabBarController.selectedIndex = index
				
		healthCertificatesTabCoordinator?.showCertifiedPersonWithCertificateFromNotification(
			for: healthCertifiedPerson,
			with: healthCertificate
		)
	}
	
	func showHealthCertifiedPersonFromNotification(for healthCertifiedPerson: HealthCertifiedPerson) {
		
		guard let healthCertificateNavigationController = healthCertificatesTabCoordinator?.viewController,
			  let index = tabBarController.viewControllers?.firstIndex(of: healthCertificateNavigationController) else {
			Log.warning("Could not show Person because the corresponding navigation controller. can't be found")
			return
		}

		// Close all modal screens that would prevent showing the certificate.
		tabBarController.dismiss(animated: false)
		tabBarController.selectedIndex = index
				
		healthCertificatesTabCoordinator?.showCertifiedPersonFromNotification(for: healthCertifiedPerson)
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
		checkinTabCoordinator = nil
		
		viewController.clearChildViewController()
		viewController.embedViewController(childViewController: navigationVC)
	}

	func showEvent(_ guid: String) {
		guard let checkInNavigationController = checkinTabCoordinator?.viewController,
			  let index = tabBarController.viewControllers?.firstIndex(of: checkInNavigationController) else {
			return
		}

		// Close all modal screens that would prevent showing the checkin screen first.
		tabBarController.dismiss(animated: false)
		tabBarController.selectedIndex = index
		checkinTabCoordinator?.showTraceLocationDetailsFromExternalCamera(guid)
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
	private let elsService: ErrorLogSubmissionProviding
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let recycleBin: RecycleBin

	private let tabBarController = UITabBarController()

	private var homeCoordinator: HomeCoordinator?
	private var homeState: HomeState?

	private var healthCertificatesTabCoordinator: HealthCertificatesTabCoordinator?
	private let universalScannerDummyViewController = UIViewController()
	private(set) var checkinTabCoordinator: CheckinTabCoordinator?
	private(set) var diaryCoordinator: DiaryCoordinator?
	private(set) var qrScannerCoordinator: QRScannerCoordinator?
	
	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()
	
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
