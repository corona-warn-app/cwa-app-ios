// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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

		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.state.riskState = .risk(risk)

			#if DEBUG
			if isUITesting, let uiTestRiskLevelEnv = UserDefaults.standard.string(forKey: "riskLevel") {
				var uiTestRiskLevel: RiskLevel
				var uiTestExposureNumber = 100
				switch uiTestRiskLevelEnv {
				case "high":
					uiTestRiskLevel = .high
				case "low":
					uiTestRiskLevel = .low
					uiTestExposureNumber = 7
				default:
					uiTestRiskLevel = .low

				}
				let uiTestRisk = Risk(level: uiTestRiskLevel, details: .init(daysSinceLastExposure: 1, numberOfExposures: uiTestExposureNumber, activeTracing: .init(interval: 14 * 86400), exposureDetectionDate: Date()), riskLevelHasChanged: false)
				self?.state.riskState = .risk(uiTestRisk)
			}
			#endif
		}

		riskConsumer.didFailCalculateRisk = { [weak self] error in
			switch error {
			case .inactive:
				self?.state.riskState = .inactive
			default:
				self?.state.riskState = .detectionFailed
			}
		}

		riskProvider.observeRisk(riskConsumer)

		UNUserNotificationCenter.current().delegate = self

		setupUI()

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.riskProvidingConfiguration.detectionMode = detectionMode

		riskProvider.requestRisk(userInitiated: false)

		let state = exposureManager.preconditions()

		updateExposureState(state)
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		showPrivacyProtectionWindow()
		taskScheduler.scheduleTask()
	}

	func sceneDidBecomeActive(_: UIScene) {
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
		riskProvider.exposureManagerState = newState

		let message = """
		New status of EN framework:
		Authorized: \(newState.authorized)
		enabled: \(newState.enabled)
		status: \(newState.status)
		authorizationStatus: \(ENManager.authorizationStatus)
		"""
		Log.info(message, log: .api)

		state.exposureManager = newState
		updateExposureState(newState)
	}

	// MARK: - Protocol CoordinatorDelegate

	/// Resets all stores and notifies the Onboarding and resets all pending notifications
	func coordinatorUserDidRequestReset() {
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
	}

	// MARK: - Protocol UNUserNotificationCenterDelegate

	func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.notification.request.identifier {
		case ActionableNotificationIdentifier.testResult.identifier,
			 ActionableNotificationIdentifier.riskDetection.identifier,
			 ActionableNotificationIdentifier.deviceTimeCheck.identifier:
			showHome(animated: true)

		case ActionableNotificationIdentifier.warnOthersReminder1.identifier,
			 ActionableNotificationIdentifier.warnOthersReminder2.identifier:
			showPositiveTestResultFromNotification(animated: true)

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

	var state: State = State(exposureManager: .init(), detectionMode: currentDetectionMode, riskState: .inactive) {
		didSet {
			coordinator.updateState(
				detectionMode: state.detectionMode,
				exposureManagerState: state.exposureManager
			)
		}
	}

	func requestUpdatedExposureState() {
		let state = exposureManager.preconditions()
		updateExposureState(state)
	}

	// MARK: - Private

	private lazy var navigationController: UINavigationController = AppNavigationController()
	private lazy var coordinator = Coordinator(self, navigationController)

	private lazy var appUpdateChecker = AppUpdateCheckHelper(appConfigurationProvider: self.appConfigurationProvider, store: self.store)

	private var enStateHandler: ENStateHandler?

	private let riskConsumer = RiskConsumer()

	private func setupUI() {
		setupNavigationBarAppearance()

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

	private func showHome(animated _: Bool = false) {
		if exposureManager.preconditions().status == .unknown {
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
			initialExposureManagerState: exposureManager.preconditions(),
			delegate: self
		)

		guard let enStateHandler = self.enStateHandler else {
			fatalError("It should not happen.")
		}

		coordinator.showHome(enStateHandler: enStateHandler, state: state)
	}
	
	private func showPositiveTestResultFromNotification(animated _: Bool = false) {
		guard warnOthersReminder.hasPositiveTestResult else {
			return
		}
		coordinator.showPositiveTestResultFromNotification(with: .positive)
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
		let detectionMode: DetectionMode = currentDetectionMode
		state.detectionMode = detectionMode
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
