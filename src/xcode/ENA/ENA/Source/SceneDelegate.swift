//
// 🦠 Corona-Warn-App
//

import BackgroundTasks
import ExposureNotification
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, RequiresAppDependencies, ENAExposureManagerObserver, CoordinatorDelegate, UNUserNotificationCenterDelegate, ExposureStateUpdating, ENStateHandlerUpdating {

	// MARK: - Protocol UIWindowSceneDelegate

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		self.window = window

		#if DEBUG

		// Speed up animations for faster UI-Tests: https://pspdfkit.com/blog/2016/running-ui-tests-with-ludicrous-speed/#update-why-not-just-disable-animations-altogether
		if isUITesting {
			window.layer.speed = 100
		}

		setupOnboardingForTesting()

		#endif

		exposureManager.observeExposureNotificationStatus(observer: self)

		UNUserNotificationCenter.current().delegate = self

		setupUI()

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.riskProvidingConfiguration.detectionMode = detectionMode

		riskProvider.requestRisk(userInitiated: false)

		let state = exposureManager.exposureManagerState

		updateExposureState(state)
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		showPrivacyProtectionWindow()
		taskScheduler.scheduleTask()
		Log.info("Scene did enter Background.", log: .background)
	}

	func sceneDidBecomeActive(_: UIScene) {
		Log.info("Scene did become active.", log: .background)

		hidePrivacyProtectionWindow()
		UIApplication.shared.applicationIconBadgeNumber = 0
		// explicitely disabled as per #EXPOSUREAPP-2214
		(UIApplication.shared.delegate as? AppDelegate)?.executeFakeRequestOnAppLaunch(probability: 0.0)
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
			showHome(animated: true)

		case ActionableNotificationIdentifier.warnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.warnOthersReminder2.identifier:
			showPositiveTestResultIfNeeded()

		case ActionableNotificationIdentifier.testResult.identifier:
			let testIdenifier = ActionableNotificationIdentifier.testResult.identifier
			guard let testResultRawValue = response.notification.request.content.userInfo[testIdenifier] as? Int,
				  let testResult = TestResult(rawValue: testResultRawValue) else {
				showHome(animated: true)
				return
			}
			
			switch testResult {
			case .positive, .negative:
				showTestResultFromNotification(with: testResult)
			case .invalid:
				showHome(animated: true)
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
		Log.info("SceneDelegate got EnState update: \(state)", log: .api)
		coordinator.updateEnState(state)
	}

	// MARK: - Internal

	func requestUpdatedExposureState() {
		let state = exposureManager.exposureManagerState
		updateExposureState(state)
	}

	// MARK: - Private

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
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()

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

	private func showHome(animated _: Bool = false) {
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
		guard
			let windowScene = window?.windowScene,
			store.isOnboarded == true
			else {
				return
		}

		let privacyProtectionViewController = PrivacyProtectionViewController()
		privacyProtectionWindow = UIWindow(windowScene: windowScene)
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

}

private extension Array where Element == URLQueryItem {
	func valueFor(queryItem named: String) -> String? {
		first(where: { $0.name == named })?.value
	}
}

private var currentDetectionMode: DetectionMode {
	DetectionMode.fromBackgroundStatus()
}
