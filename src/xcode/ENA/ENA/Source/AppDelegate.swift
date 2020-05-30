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

	func application(_: UIApplication,
					 didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

		log(message: "# TASKSHED #")
		log(message: "# TASKSHED # \(#line) \(#function), options = \(options)")
		log(message: "# TASKSHED #")
		
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
	func exposureDetectionTransactionRequiresExposureManager(
		_: ExposureDetectionTransaction
	) -> ExposureManager {
		exposureManager
	}

	func exposureDetectionTransaction(_: ExposureDetectionTransaction, didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason) {
		// TODO: show error to user
		logError(message: "Exposure transaction failed: \(reason)")
		exposureDetectionTransaction = nil
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
        // start background task execution
		log(message: "# TASKSHED # \(#line) \(#function) STARTED \(task.identifier)")
        
        let exposureDetectionTransaction = ExposureDetectionTransaction(delegate: self, client: client, keyPackagesStore: downloadedPackagesStore)
        exposureDetectionTransaction.start {
            // handle completed background task
			log(message: "# TASKSHED # \(#line) \(#function) RETURN \(task.identifier)")

			// mark background task as completed
            log(message: "# TASKSHED # \(#line) \(#function) COMPLETE \(task.identifier)")
            task.setTaskCompleted(success: true)

			// reschedule background task again
			log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
			self.taskScheduler.scheduleBackgroundTask(for: .detectExposures)
        }
        
        task.expirationHandler = {
			// handle background task expiration
            log(message: "# TASKSHED # \(#line) \(#function) EXPIRED \(task.identifier)")
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			
            // mark background task as completed
            task.setTaskCompleted(success: false)

			// reschedule background task again
			log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
			self.taskScheduler.scheduleBackgroundTask(for: .detectExposures)
        }
    }

    func executeFetchTestResults(task: BGTask) {
        // start background task execution
		log(message: "# TASKSHED # \(#line) \(#function) STARTED \(task.identifier)")

        let exposureSubmissionService = ENAExposureSubmissionService(manager: exposureManager, client: client, store: store)
        exposureSubmissionService.getTestResult { result in
            // handle completed background task
			log(message: "# TASKSHED # \(#line) \(#function) RETURN \(task.identifier)")

            switch result {
            case .failure(let error):
                log(message: "# TASKSHED # \(#line) \(#function) ERROR \(task.identifier) \(error)")
                logError(message: error.localizedDescription)

            case .success(let testResult):
                log(message: "# TASKSHED # \(#line) \(#function) TESTRESULT \(task.identifier)\(testResult)")

                if testResult != .pending {
                    self.taskScheduler.notificationManager.presentNotification(
                        title: AppStrings.LocalNotifications.testResultsTitle,
                        body: AppStrings.LocalNotifications.testResultsBody,
                        identifier: ENATaskIdentifier.fetchTestResults.rawValue)
                }

				// mark background task as completed
                log(message: "# TASKSHED # \(#line) \(#function) COMPLETE \(task.identifier)")
                task.setTaskCompleted(success: true)

				// reschedule background task again
				log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
                self.taskScheduler.scheduleBackgroundTask(for: .fetchTestResults)
            }
        }
    
        task.expirationHandler = {
			// handle background task expiration
            log(message: "# TASKSHED # \(#line) \(#function) EXPIRED \(task.identifier)")
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			
            // mark background task as completed
            task.setTaskCompleted(success: false)

			// reschedule background task again
			log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
			self.taskScheduler.scheduleBackgroundTask(for: .fetchTestResults)
        }

    }

	func executeSIMPLETEST(task: BGTask) {
        // start background task execution
		log(message: "# TASKSHED # \(#line) \(#function) STARTED \(task.identifier)")

		DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            // handle completed background task
			log(message: "# TASKSHED # \(#line) \(#function) RETURN \(task.identifier)")

			// mark background task as completed
            log(message: "# TASKSHED # \(#line) \(#function) COMPLETE \(task.identifier)")
            task.setTaskCompleted(success: true)

			// reschedule background task again
			log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
            self.taskScheduler.scheduleBackgroundTask(for: .SIMPLETEST)
		}
		
        task.expirationHandler = {
			// handle background task expiration
            log(message: "# TASKSHED # \(#line) \(#function) EXPIRED \(task.identifier)")
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			
            // mark background task as completed
            task.setTaskCompleted(success: false)

			// reschedule background task again
			log(message: "# TASKSHED # \(#line) \(#function) RESCHEDULING TASK \(task.identifier)")
			self.taskScheduler.scheduleBackgroundTask(for: .SIMPLETEST)
        }
	}

}
