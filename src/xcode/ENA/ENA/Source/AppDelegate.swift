//
// 🦠 Corona-Warn-App
//

import Combine
import ExposureNotification
import FMDB
import UIKit

protocol CoronaWarnAppDelegate: AnyObject {
	var client: HTTPClient { get }
	var wifiClient: WifiOnlyHTTPClient { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var store: Store { get }
	var appConfigurationProvider: AppConfigurationProviding { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var taskScheduler: ENATaskScheduler { get }
	var serverEnvironment: ServerEnvironment { get }
}

extension AppDelegate: CoronaWarnAppDelegate {
	// required - otherwise app will crash because cast will fail.
}

extension AppDelegate {

	func showError(_ riskProviderError: RiskProviderError) {
		guard
			let scene = UIApplication.shared.connectedScenes.first,
			let delegate = scene.delegate as? SceneDelegate,
			let rootController = delegate.window?.rootViewController
		else {
			return
		}

		guard let alert = makeErrorAlert(
				riskProviderError: riskProviderError,
				rootController: rootController
		) else {
			return
		}

		func presentAlert() {
			rootController.present(alert, animated: true, completion: nil)
		}

		if rootController.presentedViewController != nil {
			rootController.dismiss(
				animated: true,
				completion: presentAlert
			)
		} else {
			presentAlert()
		}
	}

	private func makeErrorAlert(riskProviderError: RiskProviderError, rootController: UIViewController) -> UIAlertController? {
		switch riskProviderError {
		case .failedRiskDetection(let didEndPrematurelyReason):
			switch didEndPrematurelyReason {
			case let .noExposureWindows(error):
				return makeAlertController(
					noExposureWindowsError: error,
					localizedDescription: didEndPrematurelyReason.localizedDescription,
					rootController: rootController
				)
			case .wrongDeviceTime:
				return rootController.setupErrorAlert(message: didEndPrematurelyReason.localizedDescription)
			default:
				return nil
			}
		case .failedKeyPackageDownload(let downloadError):
			switch downloadError {
			case .noDiskSpace:
				return rootController.setupErrorAlert(message: downloadError.description)
			default:
				return nil
			}
		default:
			return nil
		}
	}

	private func makeAlertController(noExposureWindowsError: Error?, localizedDescription: String, rootController: UIViewController) -> UIAlertController? {

		if let enError = noExposureWindowsError as? ENError {
			switch enError.code {
			case .dataInaccessible:
				return nil
			default:
				let openFAQ: (() -> Void)? = {
					guard let url = enError.faqURL else { return nil }
					return {
						UIApplication.shared.open(url, options: [:])
					}
				}()
				return rootController.setupErrorAlert(
					message: localizedDescription,
					secondaryActionTitle: AppStrings.Common.errorAlertActionMoreInfo,
					secondaryActionCompletion: openFAQ
				)
			}
		} else if let exposureDetectionError = noExposureWindowsError as? ExposureDetectionError {
			switch exposureDetectionError {
			case .isAlreadyRunning:
				return nil
			}
		} else {
			return rootController.setupErrorAlert(
				message: localizedDescription
			)
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	let store: Store
	let serverEnvironment: ServerEnvironment

	let taskScheduler: ENATaskScheduler = ENATaskScheduler.shared
	let backgroundTaskConsumer = RiskConsumer()

	lazy var appConfigurationProvider: AppConfigurationProviding = {
		#if DEBUG
		if isUITesting {
			// provide a static app configuration for ui tests to prevent validation errors
			return CachedAppConfigurationMock()
		}
		#endif
		// use a custom http client that uses/recognized caching mechanisms
		let appFetchingClient = CachingHTTPClient(clientConfiguration: client.configuration)
		
		let provider = CachedAppConfiguration(client: appFetchingClient, store: store)
		// used to remove invalidated key packages
		provider.packageStore = downloadedPackagesStore
		return provider
	}()

	lazy var riskProvider: RiskProvider = {
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: downloadedPackagesStore,
			client: client,
			wifiClient: wifiClient,
			store: store
		)

		#if !RELEASE
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.preconditions(),
			riskCalculation: DebugRiskCalculation(riskCalculation: RiskCalculation(), store: store),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor
		)
		#else
		return RiskProvider(
			configuration: .default,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			exposureManagerState: exposureManager.preconditions(),
			keyPackageDownload: keyPackageDownload,
			exposureDetectionExecutor: exposureDetectionExecutor
		)
		#endif

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
	private let consumer = RiskConsumer()

	let downloadedPackagesStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "packages")

	let client: HTTPClient
	let wifiClient: WifiOnlyHTTPClient

	private lazy var exposureDetectionExecutor: ExposureDetectionExecutor = {
		ExposureDetectionExecutor(
			client: self.client,
			downloadedPackagesStore: self.downloadedPackagesStore,
			store: self.store,
			exposureDetector: self.exposureManager
		)
	}()

	override init() {
		self.serverEnvironment = ServerEnvironment()

		self.store = SecureStore(subDirectory: "database", serverEnvironment: serverEnvironment)

		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: store)
		self.client = HTTPClient(configuration: configuration)
		self.wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		downloadedPackagesStore.keyValueStore = self.store
	}

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {

		UIDevice.current.isBatteryMonitoringEnabled = true

		taskScheduler.delegate = self

		// Setup DeadmanNotification after AppLaunch
		UNUserNotificationCenter.current().scheduleDeadmanNotificationIfNeeded()

		consumer.didFailCalculateRisk = { [weak self] error in
			self?.showError(error)
		}
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
