//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import ExposureNotification
import UIKit

/// The root view controller of the developer menu.
final class DMViewController: UITableViewController, RequiresAppDependencies {
	// MARK: Creating a developer menu view controller
	init(
		client: Client,
		wifiClient: WifiOnlyHTTPClient,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.client = client
		self.wifiClient = wifiClient
		self.exposureSubmissionService = exposureSubmissionService
		super.init(style: .plain)
		title = "👩🏾‍💻 Developer Menu 🧑‍💻"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties
	private let client: Client
	private let consumer = RiskConsumer()
	private let exposureSubmissionService: ExposureSubmissionService
	private var keys = [SAP_External_Exposurenotification_TemporaryExposureKey]() {
		didSet {
			keys = self.keys.sorted()
		}
	}
	
	// internal because of protocol RequiresAppDependencies
	let wifiClient: WifiOnlyHTTPClient

	// MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		consumer.didCalculateRisk = { _ in
			// intentionally left blank
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setToolbarHidden(true, animated: animated)
	}

	// MARK: Clear Registration Token of Submission
	@objc
	private func clearRegistrationToken() {
		store.registrationToken = nil
		let alert = UIAlertController(
			title: "Token Deleted",
			message: "Successfully deleted the submission registration token.",
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .cancel
			)
		)
		present(alert, animated: true, completion: nil)
	}

	// MARK: UITableView

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		DMMenuItem.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DMMenuCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DMMenuCell")

		let menuItem = DMMenuItem.existingFromIndexPath(indexPath)

		cell.textLabel?.text = menuItem.title
		cell.detailTextLabel?.text = menuItem.subtitle
		cell.accessoryType = .disclosureIndicator

		return cell
	}

	// swiftlint:disable:next cyclomatic_complexity
	override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		let menuItem = DMMenuItem.existingFromIndexPath(indexPath)
		let vc: UIViewController?

		switch menuItem {
		case .keys:
			vc = DMKeysViewController(
				client: client,
				store: store,
				exposureManager: exposureManager
			)
		case .wifiClient:
			vc = DMWifiClientViewController(wifiClient: wifiClient)
		case .checkSubmittedKeys:
			vc = DMSubmissionStateViewController(
				client: client,
				wifiClient: wifiClient,
				delegate: self
			)
		case .appConfiguration:
			vc = DMAppConfigurationViewController(appConfiguration: appConfigurationProvider)
		case .backendConfiguration:
			vc = makeBackendConfigurationViewController()
		case .tracingHistory:
			vc = DMTracingHistoryViewController(tracingHistory: store.tracingStatusHistory)
		case .store:
			vc = DMStoreViewController(store: store)
		case .lastSubmissionRequest:
			vc = DMLastSubmissionRequestViewController(lastSubmissionRequest: UserDefaults.standard.dmLastSubmissionRequest)
		case .errorLog:
			vc = DMLogsViewController()
		case .sendFakeRequest:
			vc = nil
			sendFakeRequest()
		case .purgeRegistrationToken:
			clearRegistrationToken()
			vc = nil
		case .manuallyRequestRisk:
			vc = nil
			manuallyRequestRisk()
		case .debugRiskCalculation:
			vc = DMDebugRiskCalculationViewController(store: store)
		case .onboardingVersion:
			vc = makeOnboardingVersionViewController()
		case .serverEnvironment:
			vc = makeServerEnvironmentViewController()
		case .simulateNoDiskSpace:
			vc = DMSQLiteErrorViewController(store: store)
		case .listPendingNotifications:
			vc = DMNotificationsViewController()
		case .warnOthersNotifications:
			vc = DMWarnOthersNotificationViewController(warnOthersReminder: WarnOthersReminder(store: store), store: store, exposureSubmissionService: exposureSubmissionService)
		case .deviceTimeCheck:
			vc = DMDeviceTimeCheckViewController(store: store)

		case .ppacService:
			var deviceCheck: DeviceCheckable
			#if targetEnvironment(simulator)
			deviceCheck = PPACDeviceCheckMock(true, deviceToken: "MockedTestToken")
			#else
			deviceCheck = PPACDeviceCheck()
			#endif
			vc = DMPPACViewController(store)
		}
		
		if let vc = vc {
			navigationController?.pushViewController(
				vc,
				animated: true
			)
		}
	}

	// MARK: Performing developer menu related tasks
	@objc
	private func sendFakeRequest() {
		exposureSubmissionService.fakeRequest { _ in
			let alert = self.setupErrorAlert(title: "Info", message: "Fake request was sent.")
			self.present(alert, animated: true) {}
		}
	}

	private func makeBackendConfigurationViewController() -> DMBackendConfigurationViewController {
		return DMBackendConfigurationViewController(
			serverEnvironmentProvider: store
		)
	}

	private func manuallyRequestRisk() {
		let alert = UIAlertController(
			title: "Manually request risk?",
			message: "⚠️⚠️⚠️ WARNING ⚠️⚠️⚠️\n\nManually requesting the current risk works by purging the cache. This actually deletes the last calculated risk (among other things) from the store. Do you want to manually request your current risk?",
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: "Cancel",
				style: .cancel
			) { _ in
				alert.dismiss(animated: true, completion: nil)
			}
		)

		alert.addAction(
			UIAlertAction(
				title: "Purge Cache and request Risk",
				style: .destructive
			) { _ in
				self.store.riskCalculationResult = nil
				self.riskProvider.requestRisk(userInitiated: true)
			}
		)
		present(alert, animated: true, completion: nil)
	}

	private func makeOnboardingVersionViewController() -> DMDeltaOnboardingViewController {
		return DMDeltaOnboardingViewController(store: store)
    }

    private func makeServerEnvironmentViewController() -> DMServerEnvironmentViewController {
		return DMServerEnvironmentViewController(
			store: store,
			downloadedPackagesStore: downloadedPackagesStore,
			serverEnvironment: serverEnvironment
		)
	}
}

extension DMViewController: DMSubmissionStateViewControllerDelegate {
	func submissionStateViewController(
		_: DMSubmissionStateViewController,
		getDiagnosisKeys completionHandler: @escaping ENGetDiagnosisKeysHandler
	) {
		exposureManager.getTestDiagnosisKeys(completionHandler: completionHandler)
	}
}

#endif
