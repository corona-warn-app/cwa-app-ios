//
// 🦠 Corona-Warn-App
//

#if !RELEASE
import UIKit

protocol DMStore: AnyObject {
	var dmLastSubmissionRequest: Data? { get set }
}

extension UserDefaults: DMStore {
	var dmLastSubmissionRequest: Data? {
		get {
			data(forKey: "dmLastSubmissionRequest")
		}
		set {
			set(newValue, forKey: "dmLastSubmissionRequest")
		}
	}
}

/// If enabled, the developer can be revealed by tripple-tapping anywhere within the `presentingViewController`.
final class DMDeveloperMenu {
	// MARK: Creating a developer menu

	/// Parameters:
	/// - presentingViewController: The instance of `UIViewController` which should receive a developer menu.
	/// - client: The `Client` to use.
	/// - store: The `Store` is used to retrieve debug information.
	init(
		presentingViewController: UIViewController,
		client: Client,
		wifiClient: WifiOnlyHTTPClient,
		store: Store,
		exposureManager: ExposureManager,
		developerStore: DMStore,
		exposureSubmissionService: ExposureSubmissionService,
		serverEnvironment: ServerEnvironment,
		otpService: OTPServiceProviding,
		eventStore: EventStoringProviding
	) {
		self.client = client
		self.wifiClient = wifiClient
		self.presentingViewController = presentingViewController
		self.store = store
		self.exposureManager = exposureManager
		self.developerStore = developerStore
		self.exposureSubmissionService = exposureSubmissionService
		self.serverEnvironment = serverEnvironment
		self.otpService = otpService
        self.eventStore = eventStore
	}

	// MARK: Properties
	private let presentingViewController: UIViewController
	private let client: Client
	private let wifiClient: WifiOnlyHTTPClient
	private let store: Store
    private let eventStore: EventStoringProviding
	private let exposureManager: ExposureManager
	private let exposureSubmissionService: ExposureSubmissionService
	private let developerStore: DMStore
	private let serverEnvironment: ServerEnvironment
	private let otpService: OTPServiceProviding

	// MARK: Interacting with the developer menu

	/// Enables the developer menu if it is currently allowed to do so.
	///
	/// Whether or not the developer menu is allowed is determined at build time by looking at the active build configuration. It is only allowed for `RELEASE` and `DEBUG` builds. Builds that target the app store (configuration `APP_STORE`) are built without support for a developer menu.
	func enableIfAllowed() {
		guard isAllowed() else {
			return
		}
		let showDeveloperMenuGesture = UITapGestureRecognizer(target: self, action: #selector(_showDeveloperMenu(_:)))
		showDeveloperMenuGesture.numberOfTapsRequired = 3
		presentingViewController.view.addGestureRecognizer(showDeveloperMenuGesture)
	}

	@objc
	private func _showDeveloperMenu(_: UITapGestureRecognizer) {
		showDeveloperMenu()
	}

	 func showDeveloperMenu() {
		let vc = DMViewController(
			client: client,
			wifiClient: wifiClient,
			exposureSubmissionService: exposureSubmissionService,
			otpService: otpService,
			eventStore: eventStore
		)

		let closeBarButtonItem = UIBarButtonItem(
			title: "❌",
			style: .done,
			target: self,
			action: #selector(closeDeveloperMenu)
		)

		vc.navigationItem.rightBarButtonItem = closeBarButtonItem

		let navigationController = UINavigationController(
			rootViewController: vc
		)
		presentingViewController.present(
			navigationController,
			animated: true,
			completion: nil
		)
	}

	@objc
	func closeDeveloperMenu() {
		presentingViewController.dismiss(animated: true)
	}

	private func isAllowed() -> Bool {
		true
	}
}
#endif
