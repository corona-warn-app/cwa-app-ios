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
import Connectivity

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, RequiresAppDependencies {
	// MARK: Properties

	var window: UIWindow?

	private lazy var navigationController: UINavigationController = AppNavigationController()
	private var homeController: HomeViewController?

	var state: State = State(exposureManager: .init(), detectionMode: currentDetectionMode, risk: nil) {
		didSet {
			homeController?.updateState(
				detectionMode: state.detectionMode,
				exposureManagerState: state.exposureManager,
				risk: state.risk)
		}
	}

	private lazy var appUpdateChecker = AppUpdateCheckHelper(client: self.client, store: self.store)

	#if !RELEASE
	private var developerMenu: DMDeveloperMenu?
	private func enableDeveloperMenuIfAllowed(in controller: UIViewController) {
		developerMenu = DMDeveloperMenu(
			presentingViewController: controller,
			client: client,
			store: store,
			exposureManager: exposureManager
		)
		developerMenu?.enableIfAllowed()
	}
	#endif

	private var enStateHandler: ENStateHandler?

	// MARK: UISceneDelegate

	private let riskConsumer = RiskConsumer()

	func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		self.window = window

		#if UITESTING
		if let isOnboarded = UserDefaults.standard.value(forKey: "isOnboarded") as? String {
			store.isOnboarded = (isOnboarded != "NO")
		}
		#endif

		exposureManager.resume(observer: self)

		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.state.risk = risk
		}
		riskProvider.observeRisk(riskConsumer)

		UNUserNotificationCenter.current().delegate = self

		setupUI()

		NotificationCenter.default.addObserver(self, selector: #selector(isOnboardedDidChange(_:)), name: .isOnboardedDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(backgroundRefreshStatusDidChange), name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.configuration.detectionMode = detectionMode

		riskProvider.requestRisk(userInitiated: false)

		let state = exposureManager.preconditions()
		updateExposureState(state)
		appUpdateChecker.checkAppVersionDialog(for: window?.rootViewController)
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		showPrivacyProtectionWindow()
		taskScheduler.scheduleTasks()
	}

	func sceneDidBecomeActive(_: UIScene) {
		hidePrivacyProtectionWindow()
		UIApplication.shared.applicationIconBadgeNumber = 0
	}

	// MARK: Helper

	func requestUpdatedExposureState() {
		let state = exposureManager.preconditions()
		updateExposureState(state)
	}

	private func setupUI() {
		setupNavigationBarAppearance()

		if !store.isOnboarded {
			showOnboarding()
		} else {
			showHome()
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
					// TODO: Error handling, if error occurs, what can we do?
					logError(message: "Cannot activate the  ENManager. The reason is \(error)")
					return
				}
				self?.presentHomeVC()
			}
		} else {
			presentHomeVC()
		}
	}

	private func presentHomeVC() {
		Connectivity.urlSessionConfiguration.timeoutIntervalForRequest = 15.0
		Connectivity.urlSessionConfiguration.timeoutIntervalForResource = 15.0
		enStateHandler = ENStateHandler(
			initialExposureManagerState: exposureManager.preconditions(),
			reachabilityService: ConnectivityReachabilityService(
				connectivityURLs: [client.configuration.configurationURL]
			),
			delegate: self
		)
		
		guard let enStateHandler = self.enStateHandler else {
			fatalError("It should not happen.")
		}

		let vc = AppStoryboard.home.initiate(viewControllerType: HomeViewController.self) { [unowned self] coder in
			HomeViewController(
				coder: coder,
				delegate: self,
				detectionMode: self.state.detectionMode,
				exposureManagerState: self.state.exposureManager,
				initialEnState: enStateHandler.state,
				risk: self.state.risk
			)
		}

		homeController = vc // strong ref needed
		UIView.transition(with: navigationController.view, duration: CATransaction.animationDuration(), options: [.transitionCrossDissolve], animations: {
			self.navigationController.setViewControllers([vc], animated: false)
		})
		#if !RELEASE
		enableDeveloperMenuIfAllowed(in: vc)
		#endif
	}

	private func showOnboarding() {
		navigationController.navigationBar.prefersLargeTitles = false
		navigationController.setViewControllers(
			[
				AppStoryboard.onboarding.initiateInitial { [unowned self] coder in
					OnboardingInfoViewController(
						coder: coder,
						pageType: .togetherAgainstCoronaPage,
						exposureManager: self.exposureManager,
						store: self.store
					)
				}
			],
			animated: false
		)
	}

	@objc
	func isOnboardedDidChange(_: NSNotification) {
		store.isOnboarded ? showHome() : showOnboarding()
	}

	#if !RELEASE
	func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else {
			return
		}

		guard let components = NSURLComponents(
			url: url,
			resolvingAgainstBaseURL: true
		),
			let query = components.queryItems else {
			return
		}

		if let submissionBaseURL = query.valueFor(queryItem: "submissionBaseURL") {
			store.developerSubmissionBaseURLOverride = submissionBaseURL
		}
		if let distributionBaseURL = query.valueFor(queryItem: "distributionBaseURL") {
			store.developerDistributionBaseURLOverride = distributionBaseURL
		}
		if let verificationBaseURL = query.valueFor(queryItem: "verificationBaseURL") {
			store.developerVerificationBaseURLOverride = verificationBaseURL
		}
	}
	#endif

	private var privacyProtectionWindow: UIWindow?
}

// MARK: Privacy Protection
extension SceneDelegate {
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

extension SceneDelegate: ENAExposureManagerObserver {
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
		log(message: message)
		
		state.exposureManager = newState
		updateExposureState(newState)
	}
}

extension SceneDelegate: HomeViewControllerDelegate {
	/// Resets all stores and notifies the Onboarding.
	func homeViewControllerUserDidRequestReset(_: HomeViewController) {
		let newKey = KeychainHelper.generateDatabaseKey()
		store.clearAll(key: newKey)
		UIApplication.coronaWarnDelegate().downloadedPackagesStore.reset()
		UIApplication.coronaWarnDelegate().downloadedPackagesStore.open()
		exposureManager.reset {
			self.exposureManager.resume(observer: self)
			NotificationCenter.default.post(name: .isOnboardedDidChange, object: nil)
		}
	}
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}

	func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
		case UserNotificationAction.openExposureDetectionResults.rawValue,
			 UserNotificationAction.openTestResults.rawValue:
			showHome(animated: true)
		case UserNotificationAction.ignore.rawValue,
			 UNNotificationDefaultActionIdentifier,
			 UNNotificationDismissActionIdentifier:
			break
		default: break
		}

		completionHandler()
	}
}

private extension Array where Element == URLQueryItem {
	func valueFor(queryItem named: String) -> String? {
		first(where: { $0.name == named })?.value
	}
}


extension SceneDelegate: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		riskProvider.exposureManagerState = state
		riskProvider.requestRisk(userInitiated: false)
		homeController?.updateExposureState(state)
		enStateHandler?.updateExposureState(state)
		taskScheduler.updateExposureState(state)
	}
}

extension SceneDelegate: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		log(message: "SceneDelegate got EnState update: \(state)")
		homeController?.updateEnState(state)
	}
}

// MARK: Background Task
extension SceneDelegate {
	@objc
	func backgroundRefreshStatusDidChange() {
		let detectionMode: DetectionMode = currentDetectionMode
		state.detectionMode = detectionMode
	}
}

private var currentDetectionMode: DetectionMode {
	DetectionMode.fromBackgroundStatus()
}
