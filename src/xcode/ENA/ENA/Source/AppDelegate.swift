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
	// swiftlint:disable:next force_unwrapping
	static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
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

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		let taskScheduler = ENATaskScheduler()
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
			downloadedPackagesStore: downloadedPackagesStore
		)
		exposureDetectionTransaction?.start()
	}
}
