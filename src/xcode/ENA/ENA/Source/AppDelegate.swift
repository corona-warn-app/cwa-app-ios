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
import FMDB
import UIKit

protocol CoronaWarnAppDelegate: AnyObject {
	var client: Client { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var taskScheduler: ENATaskScheduler { get }
	var lastRiskCalculation: String { get set } // TODO: REMOVE ME
}

extension AppDelegate: ExposureSummaryProvider {
	func detectExposure(completion: @escaping (ENExposureDetectionSummary?) -> Void) {
		exposureDetection = ExposureDetection(delegate: exposureDetectionExecutor)
		exposureDetection?.start { result in
			switch result {
			case .success(let summary):
				completion(summary)
			case .failure:
				completion(nil)
			}
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	private let consumer = RiskConsumer()
	let taskScheduler: ENATaskScheduler = ENATaskScheduler.shared

	lazy var riskProvider: RiskProvider = {
		let exposureDetectionInterval = self.store.hourlyFetchingEnabled ? DateComponents(minute: 45) : DateComponents(hour: 24)

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 2),
			exposureDetectionInterval: exposureDetectionInterval,
			detectionMode: .default
		)


		return RiskProvider(
			configuration: config,
			store: self.store,
			exposureSummaryProvider: self,
			appConfigurationProvider: CachedAppConfiguration(client: self.client),
			exposureManagerState: self.exposureManager.preconditions()
		)
	}()

	#if targetEnvironment(simulator) || COMMUNITY
	// Enable third party contributors that do not have the required
	// entitlements to also use the app
	let exposureManager: ExposureManager = {
		let keys = [ENTemporaryExposureKey()]
		return MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: (keys, nil))
	}()
	#else
	let exposureManager: ExposureManager = ENAExposureManager()
	#endif

	private var exposureDetection: ExposureDetection?
	private var exposureSubmissionService: ENAExposureSubmissionService?

	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "packages")


	let store: Store = {
		do {
			let fileManager = FileManager.default
			let directoryURL = try fileManager
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("database")

			if !fileManager.fileExists(atPath: directoryURL.path) {
				try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
				guard let key = KeychainHelper.generateDatabaseKey() else {
					fatalError("Creating the Database failed")
				}
				return SecureStore(at: directoryURL, key: key)
			} else {
				guard let keyData = KeychainHelper.loadFromKeychain(key: "secureStoreDatabaseKey") else {
					guard let key = KeychainHelper.generateDatabaseKey() else {
						fatalError("Creating the Database failed")
					}
					return SecureStore(at: directoryURL, key: key)
				}
				let key = String(decoding: keyData, as: UTF8.self)
				return SecureStore(at: directoryURL, key: key)
			}
		} catch {
			fatalError("Creating the Database failed")
		}
	}()

	lazy var client: Client = {
		// We disable app store checks to make testing easier.
		//        #if APP_STORE
		//        return HTTPClient(configuration: .production)
		//        #endif

		if ClientMode.default == .mock {
			fatalError("not implemented")
		}

		let store = self.store
		guard
			let distributionURLString = store.developerDistributionBaseURLOverride,
			let submissionURLString = store.developerSubmissionBaseURLOverride,
			let verificationURLString = store.developerVerificationBaseURLOverride,
			let distributionURL = URL(string: distributionURLString),
			let verificationURL = URL(string: verificationURLString),
			let submissionURL = URL(string: submissionURLString) else {
				return HTTPClient(configuration: .production)
		}

		let config = HTTPClient.Configuration(
			apiVersion: "v1",
			country: "DE",
			endpoints: HTTPClient.Configuration.Endpoints(
				distribution: .init(baseURL: distributionURL, requiresTrailingSlash: false),
				submission: .init(baseURL: submissionURL, requiresTrailingSlash: false),
				verification: .init(baseURL: verificationURL, requiresTrailingSlash: false)
			)
		)
		return HTTPClient(configuration: config)
	}()

	// TODO: REMOVE ME
	var lastRiskCalculation: String = ""

	private lazy var exposureDetectionExecutor: ExposureDetectionExecutor = {
		ExposureDetectionExecutor(
			client: self.client,
			downloadedPackagesStore: self.downloadedPackagesStore,
			store: self.store,
			exposureDetector: self.exposureManager
		)
	}()

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		UIDevice.current.isBatteryMonitoringEnabled = true

		taskScheduler.taskDelegate = self

		riskProvider.observeRisk(consumer)

		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(
		_: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options _: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}
}

extension AppDelegate: CoronaWarnAppDelegate {

	private func useSummaryDetectionResult(
		_ result: Result<ENExposureDetectionSummary, ExposureDetection.DidEndPrematurelyReason>
	) {
		exposureDetection = nil
		switch result {
		case .success(let summary):
			store.summary = SummaryMetadata(detectionSummary: summary)
		case .failure(let reason):
			logError(message: "Exposure transaction failed: \(reason)")

			let message: String
			switch reason {
			case .noExposureManager:
				message = "No ExposureManager"
			case .noSummary:
				// not really accurate but very likely this is the case.
				message = "Max file per day limit set by Apple reached (15)"
			case .noDaysAndHours:
				message = "No available files. Did you configure the backend URL?"
			case .noExposureConfiguration:
				message = "Didn't get a configuration"
			case .unableToWriteDiagnosisKeys:
				message = "No keys"
			}

			// We have to remove this after the test has been concluded.
			let alert = UIAlertController(
				title: "Exposure Detection Failed",
				message: message,
				preferredStyle: .alert
			)

			alert.addAction(
				UIAlertAction(
					title: "OK",
					style: .cancel
				)
			)

			exposureDetection = nil

			guard let scene = UIApplication.shared.connectedScenes.first else { return }
			guard let delegate = scene.delegate as? SceneDelegate else { return }
			guard let rootController = delegate.window?.rootViewController else {
				return
			}
			func showError() {
				rootController.present(alert, animated: true, completion: nil)
			}

			if rootController.presentedViewController != nil {
				rootController.dismiss(animated: true, completion: showError)
			} else {
				showError()
			}
		}
	}
}

extension AppDelegate: ENATaskExecutionDelegate {
	func executeExposureDetectionRequest(task: BGTask) {

		func complete(success: Bool) {
			task.setTaskCompleted(success: success)
			taskScheduler.scheduleTask(for: .detectExposures)
		}

		riskProvider.requestRisk(userInitiated: false) { risk in
			// present a notification if the risk score has increased
			if let risk = risk,
				risk.riskLevelHasChanged {
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.detectExposureTitle,
					body: AppStrings.LocalNotifications.detectExposureBody,
					identifier: ENATaskIdentifier.detectExposures.rawValue
				)
			}
			complete(success: true)
		}

		task.expirationHandler = {
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			complete(success: false)
		}
	}

	func executeFetchTestResults(task: BGTask) {

		func complete(success: Bool) {
			task.setTaskCompleted(success: success)
			taskScheduler.scheduleTask(for: .fetchTestResults)
		}
		self.exposureSubmissionService = ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		if store.registrationToken != nil && store.testResultReceivedTimeStamp == nil {
			self.exposureSubmissionService?.getTestResult { result in
				switch result {
				case .failure(let error):
					logError(message: error.localizedDescription)
				case .success(let testResult):
					if testResult != .pending {
						UNUserNotificationCenter.current().presentNotification(
							title: AppStrings.LocalNotifications.testResultsTitle,
							body: AppStrings.LocalNotifications.testResultsBody,
							identifier: ENATaskIdentifier.fetchTestResults.rawValue)
					}
				}

				complete(success: true)
			}
		} else {
			complete(success: true)
		}

		task.expirationHandler = {
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			complete(success: false)
		}
	}
}
