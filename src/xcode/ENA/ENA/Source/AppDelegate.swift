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
	var client: HTTPClient { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var taskScheduler: ENATaskScheduler { get }
	var lastRiskCalculation: String { get set } // TODO: REMOVE ME
}

extension AppDelegate: CoronaWarnAppDelegate {
	// required - otherwise app will crash because cast will fails
}

extension AppDelegate: ExposureSummaryProvider {
	func detectExposure(completion: @escaping (ENExposureDetectionSummary?) -> Void) {
		exposureDetection = ExposureDetection(delegate: exposureDetectionExecutor)
		exposureDetection?.start { result in
			switch result {
			case .success(let summary):
				completion(summary)
			case .failure(let error):
				self.showError(exposure: error)
				completion(nil)
			}
		}
	}

	private func showError(exposure didEndPrematurely: ExposureDetection.DidEndPrematurelyReason) {

		guard
			let scene = UIApplication.shared.connectedScenes.first,
			let delegate = scene.delegate as? SceneDelegate,
			let rootController = delegate.window?.rootViewController,
			let alert = didEndPrematurely.errorAlertController(rootController: rootController)
		else {
			return
		}

		func _showError() {
			rootController.present(alert, animated: true, completion: nil)
		}

		if rootController.presentedViewController != nil {
			rootController.dismiss(
				animated: true,
				completion: _showError
			)
		} else {
			rootController.present(alert, animated: true, completion: nil)
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	//TODO: Handle it
	var store: Store = SecureStore(subDirectory: "database")
	
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
	private(set) var exposureSubmissionService: ENAExposureSubmissionService?

	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "packages")

	var client = HTTPClient(configuration: .backendBaseURLs)

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

		taskScheduler.delegate = self

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
