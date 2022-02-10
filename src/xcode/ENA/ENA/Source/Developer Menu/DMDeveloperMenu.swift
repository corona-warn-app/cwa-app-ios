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
	
	var dmLastOnBehalfCheckinSubmissionRequest: Data? {
		get {
			data(forKey: "dmLastOnBehalfCheckinSubmissionRequest")
		}
		set {
			set(newValue, forKey: "dmLastOnBehalfCheckinSubmissionRequest")
		}
	}
}

/// If enabled, the developer can be revealed by tripple-tapping anywhere within the `presentingViewController`.
final class DMDeveloperMenu {
	
	// MARK: - Init
	
	/// Parameters:
	/// - presentingViewController: The instance of `UIViewController` which should receive a developer menu.
	/// - client: The `Client` to use.
	/// - store: The `Store` is used to retrieve debug information.
	init(
		presentingViewController: UIViewController,
		client: Client,
		restServiceProvider: RestServiceProviding,
		wifiClient: WifiOnlyHTTPClient,
		store: Store,
		exposureManager: ExposureManager,
		developerStore: DMStore,
		exposureSubmissionService: ExposureSubmissionService,
		environmentProvider: EnvironmentProviding,
		otpService: OTPServiceProviding,
		coronaTestService: CoronaTestService,
		eventStore: EventStoringProviding,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		ppacService: PrivacyPreservingAccessControl,
		healthCertificateService: HealthCertificateService,
		cache: KeyValueCaching
	) {
		self.client = client
		self.restServiceProvider = restServiceProvider
		self.wifiClient = wifiClient
		self.presentingViewController = presentingViewController
		self.store = store
		self.exposureManager = exposureManager
		self.developerStore = developerStore
		self.exposureSubmissionService = exposureSubmissionService
		self.environmentProvider = environmentProvider
		self.otpService = otpService
		self.coronaTestService = coronaTestService
		self.eventStore = eventStore
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.ppacService = ppacService
		self.healthCertificateService = healthCertificateService
		self.cache = cache
	}

	// MARK: - Internal
	
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
	
	func showDeveloperMenu() {
		let vc = DMViewController(
			client: client,
			restServiceProvider: restServiceProvider,
			wifiClient: wifiClient,
			exposureSubmissionService: exposureSubmissionService,
			otpService: otpService,
			coronaTestService: coronaTestService,
			eventStore: eventStore,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
			ppacService: ppacService,
			healthCertificateService: healthCertificateService,
			cache: cache
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
	
	// MARK: - Private
	
	private let presentingViewController: UIViewController
	private let client: Client
	private let restServiceProvider: RestServiceProviding
	private let wifiClient: WifiOnlyHTTPClient
	private let store: Store
	private let eventStore: EventStoringProviding
	private let exposureManager: ExposureManager
	private let exposureSubmissionService: ExposureSubmissionService
	private let developerStore: DMStore
	private let environmentProvider: EnvironmentProviding
	private let otpService: OTPServiceProviding
	private let coronaTestService: CoronaTestService
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let healthCertificateService: HealthCertificateService
	private let cache: KeyValueCaching

	@objc
	private func _showDeveloperMenu(_: UITapGestureRecognizer) {
		showDeveloperMenu()
	}
	
	private func isAllowed() -> Bool {
		true
	}
}
#endif
