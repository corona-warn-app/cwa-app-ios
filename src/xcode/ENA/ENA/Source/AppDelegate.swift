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
	var taskScheduler: ENATaskScheduler { get }
	var riskProvier: RiskProvider { get }
}

protocol RequiresAppDependencies {
	var client: Client { get }
	var store: Store { get }
	var taskScheduler: ENATaskScheduler { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var riskProvier: RiskProvider { get }
}

extension RequiresAppDependencies {
	var client: Client {
		UIApplication.coronaWarnDelegate().client
	}

	var downloadedPackagesStore: DownloadedPackagesStore {
		UIApplication.coronaWarnDelegate().downloadedPackagesStore
	}

	var store: Store {
		UIApplication.coronaWarnDelegate().store
	}

	var taskScheduler: ENATaskScheduler {
		UIApplication.coronaWarnDelegate().taskScheduler
	}

	var riskProvier: RiskProvider {
		UIApplication.coronaWarnDelegate().riskProvier
	}
}

extension AppDelegate: ExposureSummaryProvider {
	func detectExposure(completion: @escaping (ENExposureDetectionSummary?) -> Void) {
		exposureDetection = ExposureDetection(delegate: self)
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
	let taskScheduler = ENATaskScheduler.shared
	lazy var riskProvier: RiskProvider = {
		var duration = DateComponents()
		duration.day = 1

		let config = RiskProvidingConfiguration(
			updateMode: .automatic,
			exposureDetectionValidityDuration: duration
		)
		return RiskProvider(
			configuration: config,
			store: self.store,
			exposureSummaryProvider: self,
			appConfigurationProvider: CachedAppConfiguration(client: self.client),
			exposureManagerState: self.exposureManager.preconditions()
		)
	}()
	private var exposureManager: ExposureManager = ENAExposureManager()
	private var exposureDetection: ExposureDetection?
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

extension AppDelegate: ExposureDetectionDelegate {
	func exposureDetection(_ detection: ExposureDetection, determineAvailableData completion: @escaping (DaysAndHours?) -> Void) {
		client.availableDaysAndHoursUpUntil(.formattedToday()) { result in
			let mappedResult = result.map { DaysAndHours(days: $0.days, hours: $0.hours) }
			switch mappedResult {
			case .success(let daysAndHours):
				completion(daysAndHours)
			case .failure:
				completion(nil)
			}
		}
	}

	func exposureDetection(_ detection: ExposureDetection, downloadDeltaFor remote: DaysAndHours) -> DaysAndHours {
		let delta = DeltaCalculationResult(
			remoteDays: Set(remote.days),
			remoteHours: Set(remote.hours),
			localDays: Set(downloadedPackagesStore.allDays()),
			localHours: Set(downloadedPackagesStore.hours(for: .formattedToday()))
		)
		return (
			days: Array(delta.missingDays),
			hours: Array(delta.missingHours)
		)
	}

	func exposureDetection(_ detection: ExposureDetection, downloadAndStore delta: DaysAndHours, completion: @escaping (Error?) -> Void) {
		func storeDaysAndHours(_ fetchedDaysAndHours: FetchedDaysAndHours) {
			downloadedPackagesStore.addFetchedDaysAndHours(fetchedDaysAndHours)
			completion(nil)
		}
		client.fetchDays(
			delta.days,
			hours: delta.hours,
			of: .formattedToday(),
			completion: storeDaysAndHours
		)
	}

	func exposureDetection(_ detection: ExposureDetection, downloadConfiguration completion: @escaping (ENExposureConfiguration?) -> Void) {
		client.exposureConfiguration(completion: completion)
	}

	func exposureDetectionWriteDownloadedPackages(_ detection: ExposureDetection) -> WrittenPackages? {
		let fileManager = FileManager()
		let rootDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		do {
			try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)
			let packages = downloadedPackagesStore.allPackages(for: .formattedToday(), onlyHours: store.hourlyFetchingEnabled)
			let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: packages)
			return writer.writeAllPackages()
		} catch {
			return nil
		}
	}

	func exposureDetection(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration
		configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping (Result<ENExposureDetectionSummary, Error>) -> Void
	) {
		func withResultFrom(
			summary: ENExposureDetectionSummary?,
			error: Error?
		) -> Result<ENExposureDetectionSummary, Error> {
			if let error = error {
				return .failure(error)
			}
			if let summary = summary {
				return .success(summary)
			}
			fatalError("invalid state")
		}
		_ = exposureManager.detectExposures(
			configuration: configuration,
			diagnosisKeyURLs: writtenPackages.urls
		) { summary, error in
			completion(withResultFrom(summary: summary, error: error))
		}
	}
}

extension AppDelegate: CoronaWarnAppDelegate {
	private func useSummaryDetectionResult(
		_ result: Result<ENExposureDetectionSummary, ExposureDetection.DidEndPrematurelyReason>
	) {
		exposureDetection = nil
		switch result {
		case .success(let summary):
			store.dateLastExposureDetection = Date()
			NotificationCenter.default.post(
				name: .didDetectExposureDetectionSummary,
				object: nil,
				userInfo: ["summary": summary]
			)
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
	func appStartExposureDetectionTransaction() {
		precondition(
			exposureDetection == nil,
			"An Exposure Transaction is currently already running. This should never happen."
		)
		exposureDetection = ExposureDetection(
			delegate: self
		)
		exposureDetection?.start(completion: useSummaryDetectionResult)
	}
}

extension DownloadedPackagesStore {
	func addFetchedDaysAndHours(_ daysAndHours: FetchedDaysAndHours) {
		let days = daysAndHours.days
		days.bucketsByDay.forEach { day, bucket in
			self.set(day: day, package: bucket)
		}

		let hours = daysAndHours.hours
		hours.bucketsByHour.forEach { hour, bucket in
			self.set(hour: hour, day: hours.day, package: bucket)
		}
	}
}

private extension DownloadedPackagesStore {
	func allPackages(for day: String, onlyHours: Bool) -> [SAPDownloadedPackage] {
		var packages = [SAPDownloadedPackage]()

		if onlyHours {  // Testing only: Feed last three hours into framework
			let allHoursForToday = hourlyPackages(for: .formattedToday())
			packages.append(contentsOf: Array(allHoursForToday.prefix(3)))
		} else {
			let fullDays = allDays()
			packages.append(
				contentsOf: fullDays.map { package(for: $0) }.compactMap { $0 }
			)
		}

		return packages
	}
}

extension AppDelegate: ENATaskExecutionDelegate {
	func executeExposureDetectionRequest(task: BGTask) {
		func complete(success: Bool) {
			task.setTaskCompleted(success: success)
			taskScheduler.scheduleBackgroundTask(for: .detectExposures)
		}

		guard
			exposureDetection == nil,
			exposureManager.preconditions().authorized,
			UIApplication.shared.backgroundRefreshStatus == .available
			else {
			complete(success: false)
			return
		}

		exposureDetection = ExposureDetection(delegate: self)

		self.exposureDetection?.start { result in
			defer { complete(success: true) }
			if case let .success(newSummary) = result {

				// get the previous risk score from the store
				// check if the risk score has escalated since the last summary
				if let previousRiskScore = self.store.previousSummary?.maximumRiskScore,
					RiskLevel(riskScore: newSummary.maximumRiskScore) > RiskLevel(riskScore: previousRiskScore),
					RiskLevel(riskScore: newSummary.maximumRiskScore) == .increased {
					// present a notification if the risk score has increased
					self.taskScheduler.notificationManager.presentNotification(
						title: AppStrings.LocalNotifications.detectExposureTitle,
						body: AppStrings.LocalNotifications.detectExposureBody,
						identifier: ENATaskIdentifier.detectExposures.rawValue)
				}

				// persist the previous risk score to the store
				self.store.previousSummary = ENExposureDetectionSummaryContainer(with: newSummary)

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
			taskScheduler.scheduleBackgroundTask(for: .fetchTestResults)
		}

		self.exposureSubmissionService = ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		if store.registrationToken != nil && store.testResultReceivedTimeStamp == nil {
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
		} else {
			complete(success: true)
		}

		task.expirationHandler = {
			logError(message: NSLocalizedString("BACKGROUND_TIMEOUT", comment: "Error"))
			complete(success: false)
		}

	}
}
