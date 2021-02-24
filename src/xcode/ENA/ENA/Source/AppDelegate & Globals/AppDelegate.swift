//
// 🦠 Corona-Warn-App
//

import OpenCombine
import OpenCombineFoundation
import OpenCombineDispatch
import ExposureNotification
import FMDB
import UIKit

protocol CoronaWarnAppDelegate: AnyObject {

	var client: HTTPClient { get }
	var wifiClient: WifiOnlyHTTPClient { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
	var appConfigurationProvider: AppConfigurationProviding { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var taskScheduler: ENATaskScheduler { get }
	var serverEnvironment: ServerEnvironment { get }
	var contactDiaryStore: ContactDiaryStore { get }

	func requestUpdatedExposureState()
}

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class AppDelegate: UIResponder, UIApplicationDelegate, CoronaWarnAppDelegate, RequiresAppDependencies, ENAExposureManagerObserver, CoordinatorDelegate, ExposureStateUpdating, ENStateHandlerUpdating {

	// MARK: - Init

	override init() {
		self.serverEnvironment = ServerEnvironment()

		self.store = SecureStore(subDirectory: "database", serverEnvironment: serverEnvironment)

		self.client = HTTPClient(serverEnvironmentProvider: store)
		self.wifiClient = WifiOnlyHTTPClient(serverEnvironmentProvider: store)

		self.downloadedPackagesStore.keyValueStore = self.store

		super.init()
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
		#if DEBUG
		setupOnboardingForTesting()
		setupDatadonationForTesting()
		#endif

		if AppDelegate.isAppDisabled() {
			// Show Disabled UI
			setupUpdateOSUI()
			return true
		}

		setupUI()
		setupQuickActions()

		UIDevice.current.isBatteryMonitoringEnabled = true

		// some delegates
		taskScheduler.delegate = taskExecutionDelegate
		UNUserNotificationCenter.current().delegate = notificationManager

		/// Setup DeadmanNotification after AppLaunch
		DeadmanNotificationManager(store: store).scheduleDeadmanNotificationIfNeeded()

		consumer.didFailCalculateRisk = { [weak self] error in
			self?.showError(error)
		}
		riskProvider.observeRisk(consumer)

		exposureManager.observeExposureNotificationStatus(observer: self)

		store.analyticsSubmitter = self.analyticsSubmitter

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		// App launched via shortcut?
		return handleQuickActions(with: launchOptions)
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.riskProvidingConfiguration.detectionMode = detectionMode
		riskProvider.requestRisk(userInitiated: false)
		let state = exposureManager.exposureManagerState
		updateExposureState(state)
		analyticsSubmitter.triggerSubmitData()
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		Log.info("Application did become active.", log: .background)

		hidePrivacyProtectionWindow()
		UIApplication.shared.applicationIconBadgeNumber = 0
		if !AppDelegate.isAppDisabled() {
			// explicitly disabled as per #EXPOSUREAPP-2214
			plausibleDeniabilityService.executeFakeRequestOnAppLaunch(probability: 0.0)
		}
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		showPrivacyProtectionWindow()
		if #available(iOS 13.0, *) {
			taskScheduler.scheduleTask()
		}
		Log.info("Application did enter background.", log: .background)
	}

	// MARK: - Protocol CoronaWarnAppDelegate

	let client: HTTPClient
	let wifiClient: WifiOnlyHTTPClient
	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "packages")
	let taskScheduler: ENATaskScheduler = ENATaskScheduler.shared
    let contactDiaryStore = ContactDiaryStore.make()
    let serverEnvironment: ServerEnvironment
	var store: Store

	lazy var plausibleDeniabilityService: PlausibleDeniabilityService = {
		PlausibleDeniabilityService(
			exposureManager: self.exposureManager,
			appConfigurationProvider: self.appConfigurationProvider,
			client: self.client,
			store: self.store,
			warnOthersReminder: WarnOthersReminder(store: self.store)
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
		let appFetchingClient = CachingHTTPClient(serverEnvironmentProvider: store)

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

		#if !RELEASE
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			riskCalculation: DebugRiskCalculation(riskCalculation: RiskCalculation(), store: store),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor
		)
		#else
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor
		)
		#endif
	}()

	private lazy var analyticsSubmitter: PPAnalyticsSubmitter = {
		return PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
		)
	}()

	private lazy var otpService: OTPServiceProviding = OTPService(
		store: store,
		client: client,
		riskProvider: riskProvider
	)

	#if targetEnvironment(simulator) || COMMUNITY
	// Enable third party contributors that do not have the required
	// entitlements to also use the app
	lazy var exposureManager: ExposureManager = {
		let keys = [ENTemporaryExposureKey()]
		return MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
	}()
	#else
	lazy var exposureManager: ExposureManager = ENAExposureManager()
	#endif


	/// A set of required dependencies
	///
	/// Computed instead of lazy 'fixed' var because previous implementation created multiple instances of the `WarnOthersReminder` for themselfs.
	/// Currently we copy this behavior until further checks where made to refactor this.
	var exposureSubmissionServiceDependencies: ExposureSubmissionServiceDependencies {
		ExposureSubmissionServiceDependencies(
			exposureManager: self.exposureManager,
			appConfigurationProvider: self.appConfigurationProvider,
			client: self.client,
			store: self.store,
			warnOthersReminder: WarnOthersReminder(store: store))
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
			plausibleDeniabilityService: self.plausibleDeniabilityService,
			contactDiaryStore: self.contactDiaryStore,
			store: self.store,
			exposureSubmissionDependencies: self.exposureSubmissionServiceDependencies,
			analyticsSubmitter: self.analyticsSubmitter
			)
	}()

	var notificationManager: NotificationManager! = NotificationManager()

	// MARK: - Protocol ENAExposureManagerObserver

	func exposureManager(
		_: ENAExposureManager,
		didChangeState newState: ExposureManagerState
	) {
		// Add the new state to the history
		store.tracingStatusHistory = store.tracingStatusHistory.consumingState(newState)

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
		exposureSubmissionService.reset()

		// Reset key value store. Preserve environment settings.
		let environment = store.selectedServerEnvironment
		do {
			/// ppac API Token is excluded from the reset
			/// read value from the current store
			let ppacAPIToken = store.ppacApiToken

			let newKey = try KeychainHelper().generateDatabaseKey()
			store.clearAll(key: newKey)

			/// write excluded value back to the 'new' store
			store.ppacApiToken = ppacAPIToken
			store.lastAppReset = Date()
		} catch {
			fatalError("Creating new database key failed")
		}
		store.selectedServerEnvironment = environment

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

	private lazy var exposureDetectionExecutor: ExposureDetectionExecutor = {
		ExposureDetectionExecutor(
			client: self.client,
			downloadedPackagesStore: self.downloadedPackagesStore,
			store: self.store,
			exposureDetector: self.exposureManager
		)
	}()

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
				return rootController.setupErrorAlert(message: didEndPrematurelyReason.localizedDescription)
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
						UIApplication.shared.open(url, options: [:])
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
		contactDiaryStore: self.contactDiaryStore,
		otpService: otpService
	)

	private lazy var appUpdateChecker = AppUpdateCheckHelper(appConfigurationProvider: self.appConfigurationProvider, store: self.store)

	private var enStateHandler: ENStateHandler?

	private let riskConsumer = RiskConsumer()

	private func setupUI() {
		setupNavigationBarAppearance()
		setupAlertViewAppearance()

		if store.isOnboarded {
			showHome()
		} else {
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

	func showHome() {
		if exposureManager.exposureManagerState.status == .unknown {
			exposureManager.activate { [weak self] error in
				if let error = error {
					Log.error("Cannot activate the  ENManager. The reason is \(error)", log: .api)
					return
				}
				self?.presentHomeVC()
			}
		} else {
			presentHomeVC()
		}
	}

	private func presentHomeVC() {
		enStateHandler = ENStateHandler(
			initialExposureManagerState: exposureManager.exposureManagerState,
			delegate: self
		)

		guard let enStateHandler = self.enStateHandler else {
			fatalError("It should not happen.")
		}

		coordinator.showHome(enStateHandler: enStateHandler)
	}

	private func showOnboarding() {
		coordinator.showOnboarding()
	}

	#if DEBUG
	private func setupOnboardingForTesting() {
		if let isOnboarded = UserDefaults.standard.string(forKey: "isOnboarded") {
			store.isOnboarded = (isOnboarded != "NO")
		}

		if let onboardingVersion = UserDefaults.standard.string(forKey: "onboardingVersion") {
			store.onboardingVersion = onboardingVersion
		}

		if let resetFinishedDeltaOnboardings = UserDefaults.standard.string(forKey: "resetFinishedDeltaOnboardings"), resetFinishedDeltaOnboardings == "YES" {
			store.finishedDeltaOnboardings = [:]
		}

		if let setCurrentOnboardingVersion = UserDefaults.standard.string(forKey: "setCurrentOnboardingVersion"), setCurrentOnboardingVersion == "YES" {
			store.onboardingVersion = Bundle.main.appVersion
		}
	}

	private func setupDatadonationForTesting() {
		if let isPrivacyPreservingAnalyticsConsentGiven = UserDefaults.standard.string(forKey: "isDatadonationConsentGiven") {
			store.isPrivacyPreservingAnalyticsConsentGiven = isPrivacyPreservingAnalyticsConsentGiven != "NO"
		}
	}

	#endif

	@objc
	private func isOnboardedDidChange(_: NSNotification) {
		store.isOnboarded ? showHome() : showOnboarding()
		updateQuickActions()
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
		if isUITesting && UserDefaults.standard.bool(forKey: "showUpdateOS") == true {
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
