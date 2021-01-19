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

@UIApplicationMain
// swiftlint:disable:next type_body_length
class AppDelegate: UIResponder, UIApplicationDelegate, CoronaWarnAppDelegate, RequiresAppDependencies, ENAExposureManagerObserver, CoordinatorDelegate, UNUserNotificationCenterDelegate, ExposureStateUpdating, ENStateHandlerUpdating {

	// MARK: - Init

	override init() {
		self.serverEnvironment = ServerEnvironment()

		self.store = SecureStore(subDirectory: "database", serverEnvironment: serverEnvironment)

		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: store)
		self.client = HTTPClient(configuration: configuration)
		self.wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		self.downloadedPackagesStore.keyValueStore = self.store
	}

	// MARK: - Protocol UIApplicationDelegate

	var window: UIWindow?

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		#if DEBUG
		setupOnboardingForTesting()
		#endif
		
		if AppDelegate.isAppDisabled() {
			// Show Disabled UI
			setupAppDisabledUI()
			
			return true
		}
		
		setupUI()

		UIDevice.current.isBatteryMonitoringEnabled = true

		taskScheduler.delegate = self

		// Setup DeadmanNotification after AppLaunch
		UNUserNotificationCenter.current().scheduleDeadmanNotificationIfNeeded()

		consumer.didFailCalculateRisk = { [weak self] error in
			self?.showError(error)
		}
		riskProvider.observeRisk(consumer)

		exposureManager.observeExposureNotificationStatus(observer: self)

		UNUserNotificationCenter.current().delegate = self

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		return true
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.riskProvidingConfiguration.detectionMode = detectionMode

		riskProvider.requestRisk(userInitiated: false)

		let state = exposureManager.exposureManagerState

		updateExposureState(state)
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		Log.info("Application did become active.", log: .background)

		hidePrivacyProtectionWindow()
		UIApplication.shared.applicationIconBadgeNumber = 0
		// explicitely disabled as per #EXPOSUREAPP-2214
		executeFakeRequestOnAppLaunch(probability: 0.0)
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
    let store: Store
    let contactDiaryStore = ContactDiaryStore.make()
    let serverEnvironment: ServerEnvironment

	lazy var appConfigurationProvider: AppConfigurationProviding = {
		#if DEBUG
		if isUITesting {
			// provide a static app configuration for ui tests to prevent validation errors
			return CachedAppConfigurationMock()
		}
		#endif
		// use a custom http client that uses/recognized caching mechanisms
		let appFetchingClient = CachingHTTPClient(clientConfiguration: client.configuration)

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
			contactDiaryStore: contactDiaryStore,
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
			contactDiaryStore: contactDiaryStore,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.exposureManagerState,
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor
		)
		#endif
	}()

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

	func requestUpdatedExposureState() {
		let state = exposureManager.exposureManagerState
		updateExposureState(state)
	}

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

		do {
			let newKey = try KeychainHelper().generateDatabaseKey()
			store.clearAll(key: newKey)
		} catch {
			fatalError("Creating new database key failed")
		}
		UIApplication.coronaWarnDelegate().downloadedPackagesStore.reset()
		UIApplication.coronaWarnDelegate().downloadedPackagesStore.open()
		exposureManager.reset {
			self.exposureManager.observeExposureNotificationStatus(observer: self)
			NotificationCenter.default.post(name: .isOnboardedDidChange, object: nil)
		}

		// Remove all pending notifications
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		
		// Reset contact diary
		UIApplication.coronaWarnDelegate().contactDiaryStore.reset()
	}

	// MARK: - Protocol UNUserNotificationCenterDelegate

	func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
			showHome()

		case ActionableNotificationIdentifier.warnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.warnOthersReminder2.identifier:
			showPositiveTestResultIfNeeded()

		case ActionableNotificationIdentifier.testResult.identifier:
			let testIdenifier = ActionableNotificationIdentifier.testResult.identifier
			guard let testResultRawValue = response.notification.request.content.userInfo[testIdenifier] as? Int,
				  let testResult = TestResult(rawValue: testResultRawValue) else {
				showHome()
				return
			}

			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(with: testResult)
			case .invalid:
				showHome()
			case .expired, .pending:
				assertionFailure("Expired and Pending Test Results should not trigger the Local Notification")
			}

		default: break
		}

		completionHandler()
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

	// MARK: - Internal

	let backgroundTaskConsumer = RiskConsumer()

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

	private lazy var navigationController: UINavigationController = AppNavigationController()
	private lazy var coordinator = Coordinator(
		self,
		navigationController,
		contactDiaryStore: UIApplication.coronaWarnDelegate().contactDiaryStore
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
		window?.rootViewController = navigationController
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

	private func showHome() {
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

	private func showPositiveTestResultIfNeeded() {
		let warnOthersReminder = WarnOthersReminder(store: store)
		guard warnOthersReminder.positiveTestResultWasShown else {
			return
		}

		showTestResultFromNotification(with: .positive)
	}
	
	private func showTestResultFromNotification(with testResult: TestResult) {
		// we should show screens based on test result regardless wether positiveTestResultWasShown before or not
		coordinator.showTestResultFromNotification(with: testResult)
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

		if let setCurrentOnboardingVersion = UserDefaults.standard.string(forKey: "setCurrentOnboardingVersion"), setCurrentOnboardingVersion == "YES" {
			store.onboardingVersion = Bundle.main.appVersion
		}
	}
	#endif

	@objc
	private func isOnboardedDidChange(_: NSNotification) {
		store.isOnboarded ? showHome() : showOnboarding()
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
	
	private static func isAppDisabled() -> Bool {
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
	
	private func setupAppDisabledUI() {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = AppDisabledViewController()
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
