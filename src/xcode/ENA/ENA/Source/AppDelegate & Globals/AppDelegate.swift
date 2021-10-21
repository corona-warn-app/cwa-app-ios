//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import OpenCombineFoundation
import OpenCombineDispatch
import ExposureNotification
import FMDB
import UIKit
import HealthCertificateToolkit
import CertLogic

protocol CoronaWarnAppDelegate: AnyObject {

	var client: HTTPClient { get }
	var wifiClient: WifiOnlyHTTPClient { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
	var appConfigurationProvider: AppConfigurationProviding { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var taskScheduler: ENATaskScheduler { get }
	var environmentProvider: EnvironmentProviding { get }
	var contactDiaryStore: DiaryStoringProviding { get }

	func requestUpdatedExposureState()
}

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class AppDelegate: UIResponder, UIApplicationDelegate, CoronaWarnAppDelegate, RequiresAppDependencies, ENAExposureManagerObserver, CoordinatorDelegate, ExposureStateUpdating, ENStateHandlerUpdating {

	// MARK: - Init

	override init() {
		self.environmentProvider = Environments()

		#if DEBUG
		if isUITesting {
			self.store = MockTestStore()
		} else {
			self.store = SecureStore(subDirectory: "database", environmentProvider: environmentProvider)
		}
		#else
		self.store = SecureStore(subDirectory: "database", environmentProvider: environmentProvider)
		#endif

		if store.appInstallationDate == nil {
			store.appInstallationDate = InstallationDate.inferredFromDocumentDirectoryCreationDate()
			Log.debug("App installation date: \(String(describing: store.appInstallationDate))")
		}

		self.client = HTTPClient(environmentProvider: environmentProvider)
		self.wifiClient = WifiOnlyHTTPClient(environmentProvider: environmentProvider)
		self.recycleBin = RecycleBin(store: store)

		self.downloadedPackagesStore.keyValueStore = self.store

		super.init()

		recycleBin.testRestorationHandler = TestRestorationHandlerFake()
		recycleBin.certificateRestorationHandler = HealthCertificateRestorationHandler(service: healthCertificateService)

		// Make the analytics working. Should not be called later than at this moment of app initialization.
		
		let testResultCollector = PPAAnalyticsTestResultCollector(
			store: store
		)

		let submissionCollector = PPAAnalyticsSubmissionCollector(
			store: store,
			coronaTestService: coronaTestService
		)

		Analytics.setup(
			store: store,
			coronaTestService: coronaTestService,
			submitter: analyticsSubmitter,
			testResultCollector: testResultCollector,
			submissionCollector: submissionCollector
		)
		
		// Let ELS run for our testers as soon as possible to see any possible errors in startup, too. Only in release builds we wait for the user to start it manually.
		#if !RELEASE
		if store.elsLoggingActiveAtStartup {
			elsService.startLogging()
		} else {
			Log.warning("ELS is not set to be active at app startup.")
		}
		#endif

		// Migrate the old pcr test structure from versions older than v2.1
		coronaTestService.migrate()
	}

	deinit {
		// We are (intentionally) keeping strong references for delegates. Let's clean them ups.
		self.taskExecutionDelegate = nil
	}

	// MARK: - Protocol UIApplicationDelegate

	var window: UIWindow?

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		Log.info("Application did finish launching.", log: .appLifecycle)

		#if DEBUG
		setupOnboardingForTesting()
		setupDatadonationForTesting()
		setupInstallationDateForTesting()
		setupAntigenTestProfileForTesting()
		setupSelectedRegionsForTesting()
		#endif

		if AppDelegate.isAppDisabled() {
			// Show Disabled UI
			setupUpdateOSUI()
			didSetupUI = true
			return true
		}

		// Check for any URLs passed into the app – most likely via scanning a QR code from event or antigen rapid test
		// Route will be executed in 'applicationDidBecomeActive'
		route = routeFromLaunchOptions(launchOptions)

		QuickAction.setup()

		UIDevice.current.isBatteryMonitoringEnabled = true

		// some delegates
		taskScheduler.delegate = taskExecutionDelegate
		UNUserNotificationCenter.current().delegate = notificationManager

		/// Setup DeadmanNotification after AppLaunch
		DeadmanNotificationManager(coronaTestService: coronaTestService).scheduleDeadmanNotificationIfNeeded()

		consumer.didFailCalculateRisk = { [weak self] error in
			if self?.store.isOnboarded == true {
				self?.showError(error)
			}
		}
		riskProvider.observeRisk(consumer)

		exposureManager.observeExposureNotificationStatus(observer: self)

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		// Background task registration on iOS 12.5 requires us to activate the ENManager (https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-8919)
		if #available(iOS 13.5, *) {
			// Do nothing since we can use BGTask in this case.
		} else if NSClassFromString("ENManager") != nil { // Make sure that ENManager is available. -> iOS 12.5.x
			if store.isOnboarded, exposureManager.exposureManagerState.status == .unknown {
				self.exposureManager.activate { error in
					if let error = error {
						Log.error("[ENATaskExecutionDelegate] Cannot activate the ENManager.", log: .api, error: error)
					}
				}
			}
		}

		return handleQuickActions(with: launchOptions)
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.riskProvidingConfiguration.detectionMode = detectionMode
		riskProvider.requestRisk(userInitiated: false)
		let state = exposureManager.exposureManagerState
		updateExposureState(state)
		Analytics.triggerAnalyticsSubmission()
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
		healthCertificateService.checkIfBoosterRulesShouldBeFetched(completion: { errorMessage in
			guard let errorMessage = errorMessage else {
				return
			}
			Log.error(errorMessage, log: .vaccination, error: nil)
		})
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		Log.info("Application did become active.", log: .appLifecycle)

		if !didSetupUI {
			setupUI(route)
			didSetupUI = true
			route = nil
		}

		hidePrivacyProtectionWindow()
		UIApplication.shared.applicationIconBadgeNumber = 0
		if !AppDelegate.isAppDisabled() {
			// explicitly disabled as per #EXPOSUREAPP-2214
			plausibleDeniabilityService.executeFakeRequestOnAppLaunch(probability: 0.0)
		}

		// Cleanup recycle-bin. Remove old entries.
		recycleBin.cleanup()
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		showPrivacyProtectionWindow()
		if #available(iOS 13.0, *) {
			taskScheduler.scheduleTask()
		}
		Log.info("Application did enter background.", log: .appLifecycle)
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		Log.info("Application continue user activity.", log: .appLifecycle)

		// handle QR codes scanned in the camera app
		var route: Route?
		if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let incomingURL = userActivity.webpageURL {
			route = Route(url: incomingURL)
		}
		guard store.isOnboarded else {
			postOnboardingRoute = route
			return false
		}
		showHome(route)
		return true
	}

	// MARK: - Protocol CoronaWarnAppDelegate

	let client: HTTPClient
	let wifiClient: WifiOnlyHTTPClient
	let cachingClient = CachingHTTPClient()
	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "packages")
	let taskScheduler: ENATaskScheduler = ENATaskScheduler.shared
	let contactDiaryStore: DiaryStoringProviding = ContactDiaryStore.make()
	let eventStore: EventStoringProviding = {
		#if DEBUG
		if isUITesting {
			return MockEventStore()
		}
		#endif
		
		return EventStore.make()
	}()
    let environmentProvider: EnvironmentProviding
	var store: Store

	lazy var coronaTestService: CoronaTestService = {
		return CoronaTestService(
			client: client,
			store: store,
			eventStore: eventStore,
			diaryStore: contactDiaryStore,
			appConfiguration: appConfigurationProvider,
			healthCertificateService: healthCertificateService
		)
	}()

	lazy var eventCheckoutService: EventCheckoutService = EventCheckoutService(
		eventStore: eventStore,
		contactDiaryStore: contactDiaryStore
	)

	lazy var plausibleDeniabilityService: PlausibleDeniabilityService = {
		PlausibleDeniabilityService(
			client: self.client,
			store: self.store,
			coronaTestService: coronaTestService
		)
	}()

	lazy var appConfigurationProvider: AppConfigurationProviding = {
		#if DEBUG
		if isUITesting {
			// provide a static app configuration for ui tests to prevent validation errors
			return CachedAppConfigurationMock(isEventSurveyEnabled: true, isEventSurveyUrlAvailable: true)
		}
		#endif
		// use a custom http client that uses/recognized caching mechanisms
		let appFetchingClient = CachingHTTPClient(environmentProvider: environmentProvider)

		let provider = CachedAppConfiguration(client: appFetchingClient, store: store)
		// used to remove invalidated key packages
		provider.packageStore = downloadedPackagesStore
		return provider
	}()

	lazy var riskProvider: RiskProvider = {
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: wifiClient,
			store: store
		)

		let traceWarningPackageDownload = TraceWarningPackageDownload(
			client: client,
			store: store,
			eventStore: eventStore
		)

		let checkinRiskCalculation = CheckinRiskCalculation(
			eventStore: eventStore,
			checkinSplittingService: CheckinSplittingService(),
			traceWarningMatcher: TraceWarningMatcher(eventStore: eventStore)
		)

		#if !RELEASE
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			enfRiskCalculation: DebugRiskCalculation(riskCalculation: ENFRiskCalculation(), store: store),
			checkinRiskCalculation: checkinRiskCalculation,
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor,
			coronaTestService: coronaTestService
		)
		#else
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			checkinRiskCalculation: checkinRiskCalculation,
			keyPackageDownload: keyPackageDownload,
			traceWarningPackageDownload: traceWarningPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor,
			coronaTestService: coronaTestService
		)
		#endif
	}()
	
	private lazy var healthCertificateService: HealthCertificateService = HealthCertificateService(
		store: store,
		dccSignatureVerifier: dccSignatureVerificationService,
		dscListProvider: dscListProvider,
		client: client,
		appConfiguration: appConfigurationProvider,
		boosterNotificationsService: BoosterNotificationsService(
			rulesDownloadService: RulesDownloadService(
				store: store,
				client: client
			)
		),
		recycleBin: recycleBin
	)

	private lazy var analyticsSubmitter: PPAnalyticsSubmitting = {
		return PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
	}()

	private lazy var otpService: OTPServiceProviding = OTPService(
		store: store,
		client: client,
		riskProvider: riskProvider
	)
	
	private lazy var ppacService: PrivacyPreservingAccessControl = PPACService(
		store: store,
		deviceCheck: PPACDeviceCheck()
	)

	private lazy var dccSignatureVerificationService: DCCSignatureVerifying = {
		#if DEBUG
		if isUITesting {
			if LaunchArguments.healthCertificate.isCertificateInvalid.boolValue {
				return DCCSignatureVerifyingStub(error: .HC_DSC_NOT_YET_VALID)
			}
			return DCCSignatureVerifyingStub()
		}
		#endif

		return DCCSignatureVerification()
	}()

	private lazy var dscListProvider: DSCListProviding = {
		return DSCListProvider(client: cachingClient, store: store)
	}()

	private var vaccinationValueSetsProvider: VaccinationValueSetsProvider {
		#if DEBUG
		if isUITesting {
			return VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: store)
		}
		#endif

		return VaccinationValueSetsProvider(client: cachingClient, store: store)
	}
	
	private lazy var healthCertificateValidationService: HealthCertificateValidationProviding = {
		#if DEBUG
		if isUITesting {
			var mock = MockHealthCertificateValidationService()
			
			if LaunchArguments.healthCertificate.invalidCertificateCheck.boolValue {
				
				// Provide data for invalid validation
				let fakeResult: ValidationResult = .fake(result: .fail)
				fakeResult.rule?.description = [Description(lang: "de", desc: "Die Impfreihe muss vollständig sein (z.B. 1/1, 2/2)."), Description(lang: "en", desc: "The vaccination schedule must be complete (e.g., 1/1, 2/2).")]
				mock.validationResult = .success(.validationFailed([fakeResult]))
			} else {
				mock.validationResult = .success(.validationPassed([.fake(), .fake(), .fake()]))
			}
			
			return mock
		}
		#endif
		let rulesDownloadService = RulesDownloadService(store: store, client: client)
		return HealthCertificateValidationService(
			store: store,
			client: client,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dccSignatureVerifier: dccSignatureVerificationService,
			dscListProvider: dscListProvider,
			rulesDownloadService: rulesDownloadService
		)
	}()
	
	private lazy var healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding = HealthCertificateValidationOnboardedCountriesProvider(
		store: store,
		client: client
	)
	
	/// Reference to the ELS server handling error log recording & submission
	private lazy var elsService: ErrorLogSubmissionProviding = ErrorLogSubmissionService(
		client: client,
		store: store,
		ppacService: ppacService,
		otpService: otpService
	)

	private let recycleBin: RecycleBin

	#if COMMUNITY
	// Enable third party contributors that do not have the required
	// entitlements to also use the app
	lazy var exposureManager: ExposureManager = {
		return ENAExposureManager(manager: MockENManager())
	}()
	#elseif targetEnvironment(simulator)
	lazy var exposureManager: ExposureManager = {
		let keys = [ENTemporaryExposureKey()]
		return MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
	}()
	#else
	lazy var exposureManager: ExposureManager = ENAExposureManager()
	#endif

	/// A set of required dependencies
	///
	/// Computed instead of lazy 'fixed' var because previous implementation created multiple instances of the `WarnOthersReminder` for themselves.
	/// Currently we copy this behavior until further checks where made to refactor this.
	var exposureSubmissionServiceDependencies: ExposureSubmissionServiceDependencies {
		ExposureSubmissionServiceDependencies(
			exposureManager: self.exposureManager,
			appConfigurationProvider: self.appConfigurationProvider,
			client: self.client,
			store: self.store,
			eventStore: self.eventStore,
			coronaTestService: coronaTestService)
	}

	func requestUpdatedExposureState() {
		let state = exposureManager.exposureManagerState
		updateExposureState(state)
	}

	// MARK: - Delegate properties

	// swiftlint:disable:next weak_delegate
	lazy var taskExecutionDelegate: ENATaskExecutionDelegate! = {
		// will be released in `deinit`
		TaskExecutionHandler(
			riskProvider: self.riskProvider,
			exposureManager: exposureManager,
			plausibleDeniabilityService: self.plausibleDeniabilityService,
			contactDiaryStore: self.contactDiaryStore,
			eventStore: self.eventStore,
			eventCheckoutService: self.eventCheckoutService,
			store: self.store,
			exposureSubmissionDependencies: self.exposureSubmissionServiceDependencies,
			healthCertificateService: self.healthCertificateService
		)
	}()

	lazy var notificationManager: NotificationManager = {
		let notificationManager = NotificationManager(
			coronaTestService: coronaTestService,
			eventCheckoutService: eventCheckoutService,
			healthCertificateService: healthCertificateService,
			showHome: { [weak self] in
				// We don't need the Route parameter in the NotificationManager
				self?.showHome()
			},
			showTestResultFromNotification: coordinator.showTestResultFromNotification,
			showHealthCertificate: { [weak self] route in
				// We must NOT call self?.showHome(route) here because we do not target the home screen. Only set the route. The rest is done automatically by the startup process of the app.
				// Works only for notifications tapped when the app is closed. When inside the app, the notification will trigger nothing.
				self?.route = route
			}, showHealthCertifiedPerson: { [weak self] route in
				guard let self = self else { return }
				/*
					The booster notifications can be fired when the app is running (either foreground or background) or when the app is killed
					in case the app is running then we need to show the Home using the route of the booster notifications
					in case the app is killed and then reopened then we should just set the route into the health certified person,
					as the showHome flow will begin anyway at the startup process of the app
				*/
				if self.didSetupUI {
					self.showHome(route)
				} else {
					self.route = route
				}
			}
		)
		return notificationManager
	}()

	// MARK: - Protocol ENAExposureManagerObserver

	func exposureManager(
		_: ENAExposureManager,
		didChangeState newState: ExposureManagerState
	) {
		let message = """
		New status of EN framework:
		Authorized: \(newState.authorized)
		enabled: \(newState.enabled)
		status: \(newState.status)
		authorizationStatus: \(ENManager.authorizationStatus)
		"""
		Log.info(message, log: .api)

		updateExposureState(newState)
	}

	// MARK: - Protocol CoordinatorDelegate

	/// Resets all stores and notifies the Onboarding and resets all pending notifications
	func coordinatorUserDidRequestReset(exposureSubmissionService: ExposureSubmissionService) {
		// Reset key value store. Preserve some values.
		do {
			/// Following values are excluded from reset:
			/// - PPAC API Token
			/// - App installation date
			///
			/// read values from the current store
			let ppacEdusApiToken = store.ppacApiTokenEdus
			let installationDate = store.appInstallationDate

			let newKey = try KeychainHelper().generateDatabaseKey()
			store.wipeAll(key: newKey)

			/// write excluded values back to the 'new' store
			store.ppacApiTokenEdus = ppacEdusApiToken
			store.appInstallationDate = installationDate
            Analytics.collect(.submissionMetadata(.lastAppReset(Date())))
		} catch {
			fatalError("Creating new database key failed")
		}

		// Reset packages store
		downloadedPackagesStore.reset()
		downloadedPackagesStore.open()

		// Reset exposureManager
		exposureManager.reset {
			self.exposureManager.observeExposureNotificationStatus(observer: self)
			NotificationCenter.default.post(name: .isOnboardedDidChange, object: nil)
		}

		// Remove all pending notifications
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

		// Reset contact diary
		contactDiaryStore.reset()

		// Reset event store
		eventStore.reset()

		coronaTestService.updatePublishersFromStore()
		healthCertificateService.updatePublishersFromStore()
	}

	// MARK: - Protocol ExposureStateUpdating

	func updateExposureState(_ state: ExposureManagerState) {
		riskProvider.exposureManagerState = state
		riskProvider.requestRisk(userInitiated: false)
		coordinator.updateExposureState(state)
		enStateHandler?.updateExposureState(state)
	}

	// MARK: - Protocol ENStateHandlerUpdating

	func updateEnState(_ state: ENStateHandler.State) {
		Log.info("AppDelegate got EnState update: \(state)", log: .api)
		coordinator.updateEnState(state)
	}

	// MARK: - Private

	private var exposureDetection: ExposureDetection?
	private let consumer = RiskConsumer()
	private var postOnboardingRoute: Route?
	private var route: Route?
	private var didSetupUI = false

	private lazy var exposureDetectionExecutor: ExposureDetectionExecutor = {
		ExposureDetectionExecutor(
			client: self.client,
			downloadedPackagesStore: self.downloadedPackagesStore,
			store: self.store,
			exposureDetector: self.exposureManager
		)
	}()

	/// - Parameter launchOptions: Launch options passed on app launch
	/// - Returns: A `Route` if a valid URL is passed in the launch options
	private func routeFromLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Route? {
		guard let activityDictionary = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any] else {
			return nil
		}

		for key in activityDictionary.keys {
			if let userActivity = activityDictionary[key] as? NSUserActivity,
			   userActivity.activityType == NSUserActivityTypeBrowsingWeb,
			   let url = userActivity.webpageURL {
				return Route(url: url)
			}
		}

		return nil
	}

	private func showError(_ riskProviderError: RiskProviderError) {
		guard let rootController = window?.rootViewController else {
			return
		}

		guard let alert = makeErrorAlert(
			riskProviderError: riskProviderError,
			rootController: rootController
		) else {
			return
		}

		func presentAlert() {
			rootController.present(alert, animated: true, completion: nil)
		}

		if rootController.presentedViewController != nil {
			rootController.dismiss(
				animated: true,
				completion: presentAlert
			)
		} else {
			presentAlert()
		}
	}

	private func makeErrorAlert(riskProviderError: RiskProviderError, rootController: UIViewController) -> UIAlertController? {
		switch riskProviderError {
		case .failedRiskDetection(let didEndPrematurelyReason):
			switch didEndPrematurelyReason {
			case let .noExposureWindows(error):
				return makeAlertController(
					noExposureWindowsError: error,
					localizedDescription: didEndPrematurelyReason.localizedDescription,
					rootController: rootController
				)
			case .wrongDeviceTime:
				if !self.store.wasDeviceTimeErrorShown {
					self.store.wasDeviceTimeErrorShown = true
					return rootController.setupErrorAlert(message: didEndPrematurelyReason.localizedDescription)
				} else {
					return nil
				}

			default:
				return nil
			}
		case .failedKeyPackageDownload(let downloadError):
			switch downloadError {
			case .noDiskSpace:
				return rootController.setupErrorAlert(message: downloadError.description)
			default:
				return nil
			}
		default:
			return nil
		}
	}

	private func makeAlertController(noExposureWindowsError: Error?, localizedDescription: String, rootController: UIViewController) -> UIAlertController? {

		if let enError = noExposureWindowsError as? ENError {
			switch enError.code {
			case .dataInaccessible:
				return nil
			default:
				let openFAQ: (() -> Void)? = {
					guard let url = enError.faqURL else { return nil }
					return {
						LinkHelper.open(url: url)
					}
				}()
				return rootController.setupErrorAlert(
					message: localizedDescription,
					secondaryActionTitle: AppStrings.Common.errorAlertActionMoreInfo,
					secondaryActionCompletion: openFAQ
				)
			}
		} else if let exposureDetectionError = noExposureWindowsError as? ExposureDetectionError {
			switch exposureDetectionError {
			case .isAlreadyRunning:
				return nil
			}
		} else {
			return rootController.setupErrorAlert(
				message: localizedDescription
			)
		}
	}

	lazy var coordinator = RootCoordinator(
		self,
		coronaTestService: coronaTestService,
		contactDiaryStore: contactDiaryStore,
		eventStore: eventStore,
		eventCheckoutService: eventCheckoutService,
		otpService: otpService,
		ppacService: ppacService,
		healthCertificateService: healthCertificateService,
		healthCertificateValidationService: healthCertificateValidationService,
		healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
		vaccinationValueSetsProvider: vaccinationValueSetsProvider,
		elsService: elsService,
		recycleBin: recycleBin
	)

	private lazy var appUpdateChecker = AppUpdateCheckHelper(appConfigurationProvider: self.appConfigurationProvider, store: self.store)

	private var enStateHandler: ENStateHandler?

	private let riskConsumer = RiskConsumer()

	private func setupUI(_ route: Route?) {
		setupNavigationBarAppearance()
		setupAlertViewAppearance()

		if store.isOnboarded {
			showHome(route)
		} else {
			postOnboardingRoute = route
			showOnboarding()
		}
		UIImageView.appearance().accessibilityIgnoresInvertColors = true

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = coordinator.viewController
		window?.makeKeyAndVisible()

		#if DEBUG
		// Speed up animations for faster UI-Tests: https://pspdfkit.com/blog/2016/running-ui-tests-with-ludicrous-speed/#update-why-not-just-disable-animations-altogether
		if isUITesting {
			window?.layer.speed = 100
		}
		#endif
	}

	private func setupNavigationBarAppearance() {
		let appearance = UINavigationBar.appearance()

		appearance.tintColor = .enaColor(for: .tint)

		appearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]

		appearance.largeTitleTextAttributes = [
			NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle).scaledFont(size: 28, weight: .bold),
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]
	}

	private func setupAlertViewAppearance() {
		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .enaColor(for: .tint)
	}

	func showHome(_ route: Route? = nil) {
		// On iOS 12.5 ENManager is already activated in didFinishLaunching (https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-8919)
		if #available(iOS 13.5, *) {
			if exposureManager.exposureManagerState.status == .unknown {
				exposureManager.activate { [weak self] error in
					if let error = error {
						Log.error("Cannot activate the ENManager.", log: .api, error: error)
					}
					self?.presentHomeVC(route)
				}
			} else {
				presentHomeVC(route)
			}
		} else if NSClassFromString("ENManager") != nil { // Make sure that ENManager is available. -> iOS 12.5.x
			presentHomeVC(route)
		}
	}

	private func presentHomeVC(_ route: Route?) {
		enStateHandler = ENStateHandler(
			initialExposureManagerState: exposureManager.exposureManagerState,
			delegate: self
		)

		guard let enStateHandler = self.enStateHandler else {
			fatalError("It should not happen.")
		}

		coordinator.showHome(enStateHandler: enStateHandler, route: route)
	}

	private func showOnboarding() {
		coordinator.showOnboarding()
	}

	#if DEBUG
	private func setupOnboardingForTesting() {
		if isUITesting {
			// Only disable onboarding if it was explicitly set to "NO"
			if let isOnboarded = LaunchArguments.onboarding.isOnboarded.stringValue {
				store.isOnboarded = isOnboarded != "NO"
			}

			if let onboardingVersion = LaunchArguments.onboarding.onboardingVersion.stringValue {
				store.onboardingVersion = onboardingVersion
			}

			if LaunchArguments.onboarding.resetFinishedDeltaOnboardings.boolValue {
				store.finishedDeltaOnboardings = [:]
			}

			if LaunchArguments.onboarding.setCurrentOnboardingVersion.boolValue {
				store.onboardingVersion = Bundle.main.appVersion
			}
		}
	}

	private func setupDatadonationForTesting() {
		if isUITesting {
			store.isPrivacyPreservingAnalyticsConsentGiven = LaunchArguments.consent.isDatadonationConsentGiven.boolValue
		}
	}

	private func setupInstallationDateForTesting() {
		if isUITesting, let installationDaysString = LaunchArguments.common.appInstallationDays.stringValue {
			let installationDays = Int(installationDaysString) ?? 0
			let date = Calendar.current.date(byAdding: .day, value: -installationDays, to: Date())
			store.appInstallationDate = date
		}
	}

	private func setupAntigenTestProfileForTesting() {
		if isUITesting {
			store.antigenTestProfileInfoScreenShown = LaunchArguments.infoScreen.antigenTestProfileInfoScreenShown.boolValue
			if LaunchArguments.test.antigen.removeAntigenTestProfile.boolValue {
				store.antigenTestProfile = nil
			}
		}
	}
	
	private func setupSelectedRegionsForTesting() {
		if isUITesting, LaunchArguments.statistics.maximumRegionsSelected.boolValue {
			store.selectedLocalStatisticsRegions = [LocalStatisticsRegion(
													   federalState: .badenWürttemberg,
													   name: "Heidelberg",
													   id: "1432",
													   regionType: .administrativeUnit
													),
													LocalStatisticsRegion(
														federalState: .badenWürttemberg,
														name: "Mannheim",
														id: "1434",
														regionType: .administrativeUnit
													),
													LocalStatisticsRegion(
														federalState: .hessen,
														name: "Hessen",
														id: "1144",
														regionType: .federalState
													),
													LocalStatisticsRegion(
														federalState: .hessen,
														name: "Hessen",
														id: "1144",
														regionType: .federalState
													),
													LocalStatisticsRegion(
														federalState: .rheinlandPfalz,
														name: "Rheinland Pfalz",
														id: "1456",
														regionType: .federalState
													)]
		}
	}
	
	#endif

	@objc
	private func isOnboardedDidChange(_: NSNotification) {
		if store.isOnboarded {
			showHome(postOnboardingRoute)
			postOnboardingRoute = nil
		} else {
			showOnboarding()
		}
	}

	@objc
	private func backgroundRefreshStatusDidChange() {
		coordinator.updateDetectionMode(currentDetectionMode)
	}

	// MARK: Privacy Protection

	private var privacyProtectionWindow: UIWindow?

	private func showPrivacyProtectionWindow() {
		guard store.isOnboarded else { return }

		let privacyProtectionViewController = PrivacyProtectionViewController()
		privacyProtectionWindow = UIWindow(frame: UIScreen.main.bounds)
		privacyProtectionWindow?.rootViewController = privacyProtectionViewController
		privacyProtectionWindow?.windowLevel = .alert + 1
		privacyProtectionWindow?.makeKeyAndVisible()
		privacyProtectionViewController.show()
	}

	private func hidePrivacyProtectionWindow() {
		guard let privacyProtectionViewController = privacyProtectionWindow?.rootViewController as? PrivacyProtectionViewController else {
			return
		}
		privacyProtectionViewController.hide {
			self.privacyProtectionWindow?.isHidden = true
			self.privacyProtectionWindow = nil
		}
	}


	/// Is the app able to function with the current iOS version?
	///
	/// Due to the backport of the Exposure Notification Framework to iOS 12.5 the app has a certain range of iOS versions that aren't supported.
	///
	/// - Returns: Returns `true` if the app is in the *disabled* state and requires the user to upgrade the os.
	private static func isAppDisabled() -> Bool {
		#if DEBUG
		if isUITesting && LaunchArguments.infoScreen.showUpdateOS.boolValue == true {
			return true
		}
		#endif
		if #available(iOS 13.7, *) {
			return false
		} else if #available(iOS 13.5, *) {
			return true
		} else if NSClassFromString("ENManager") != nil {
			return false
		} else {
			return true
		}
	}

	private func setupUpdateOSUI() {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = UpdateOSViewController()
		window?.makeKeyAndVisible()
	}

}

private extension Array where Element == URLQueryItem {
	func valueFor(queryItem named: String) -> String? {
		first(where: { $0.name == named })?.value
	}
}

private var currentDetectionMode: DetectionMode {
	DetectionMode.fromBackgroundStatus()
}
