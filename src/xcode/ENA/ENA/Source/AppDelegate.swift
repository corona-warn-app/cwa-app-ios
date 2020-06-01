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
	func appStartExposureDetectionTransaction()
	var client: Client { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	let taskScheduler = ENATaskScheduler()
	private var exposureManager: ExposureManager = ENAExposureManager()
	private var exposureDetectionTransaction: ExposureDetectionTransaction?
	private var exposureSubmissionService: ENAExposureSubmissionService?

	let downloadedPackagesStore: DownloadedPackagesStore = {
		let fileManager = FileManager()
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
			.appendingPathComponent("packages")
			.appendingPathExtension("sqlite3")

		let db = FMDatabase(url: storeURL)
		let store = DownloadedPackagesSQLLiteStore(database: db)
		store.open()
		return store
	}()

	let store: Store = SecureStore()
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
				submission: .init(baseURL: submissionURL, requiresTrailingSlash: true),
				verification: .init(baseURL: verificationURL, requiresTrailingSlash: false)
			)
		)
		return HTTPClient(configuration: config)
	}()

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		UIDevice.current.isBatteryMonitoringEnabled = true

		taskScheduler.taskDelegate = self
		taskScheduler.registerBackgroundTaskRequests()
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

extension AppDelegate: ExposureDetectionTransactionDelegate {
	func exposureDetectionTransactionRequiresExposureDetector(_ transaction: ExposureDetectionTransaction) -> ExposureDetector {
		exposureManager
	}



	func exposureDetectionTransaction(_: ExposureDetectionTransaction, didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason) {
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
		case .unableToDiagnosisKeys:
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

		exposureDetectionTransaction = nil

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

	func exposureDetectionTransaction(
		_: ExposureDetectionTransaction,
		didDetectSummary summary: ENExposureDetectionSummary
	) {
		exposureDetectionTransaction = nil

		store.dateLastExposureDetection = Date()

		NotificationCenter.default.post(
			name: .didDetectExposureDetectionSummary,
			object: nil,
			userInfo: ["summary": summary]
		)
	}

	func exposureDetectionTransactionRequiresFormattedToday(_: ExposureDetectionTransaction) -> String {
		.formattedToday()
	}
}

extension AppDelegate: CoronaWarnAppDelegate {
	func appStartExposureDetectionTransaction() {
		precondition(
			exposureDetectionTransaction == nil,
			"An Exposure Transaction is currently already running. This should never happen."
		)
		exposureDetectionTransaction = ExposureDetectionTransaction(
			delegate: self,
			client: client,
			keyPackagesStore: downloadedPackagesStore
		)
		exposureDetectionTransaction?.start()
	}
}

extension AppDelegate: ENATaskExecutionDelegate {
	func executeExposureDetectionRequest(task: BGTask) {
		func complete(success: Bool) {
			task.setTaskCompleted(success: success)
			taskScheduler.scheduleBackgroundTask(for: .detectExposures)
		}

		guard
			self.exposureDetectionTransaction == nil,
			exposureManager.preconditions().authorized,
			UIApplication.shared.backgroundRefreshStatus == .available
			else {
			complete(success: false)
			return
		}

		self.exposureDetectionTransaction = ExposureDetectionTransaction(delegate: self, client: client, keyPackagesStore: downloadedPackagesStore)

		self.exposureDetectionTransaction?.start {
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
			taskScheduler.scheduleBackgroundTask(for: .detectExposures)
		}

		
		self.exposureSubmissionService = ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		self.exposureSubmissionService?.getTestResult { result in

			switch result {
			case .failure(let error):
				logError(message: error.localizedDescription)

			case .success(let testResult):
				if testResult != .pending {
					self.taskScheduler.notificationManager.presentNotification(
						title: AppStrings.LocalNotifications.testResultsTitle,
						body: AppStrings.LocalNotifications.testResultsBody,
						identifier: ENATaskIdentifier.fetchTestResults.rawValue)
				}
			}

			complete(success: true)
		}

		task.expirationHandler = {
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			complete(success: false)
		}

	}
}
