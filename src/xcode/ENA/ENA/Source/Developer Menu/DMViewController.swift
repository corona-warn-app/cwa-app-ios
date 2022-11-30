//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import ExposureNotification
import UIKit

/// The root view controller of the developer menu.
final class DMViewController: UITableViewController, RequiresAppDependencies {
	
	// MARK: - Init
	
	init(
		client: Client,
		restServiceProvider: RestServiceProviding,
		exposureSubmissionService: ExposureSubmissionService,
		otpService: OTPServiceProviding,
		coronaTestService: CoronaTestServiceProviding,
		eventStore: EventStoringProviding,
		qrCodePosterTemplateProvider: QRCodePosterTemplateProviding,
		ppacService: PrivacyPreservingAccessControl,
		healthCertificateService: HealthCertificateService,
		cache: KeyValueCaching
	) {
		self.client = client
		self.restServiceProvider = restServiceProvider
		self.exposureSubmissionService = exposureSubmissionService
		self.otpService = otpService
		self.coronaTestService = coronaTestService
		self.eventStore = eventStore
		self.qrCodePosterTemplateProvider = qrCodePosterTemplateProvider
		self.ppacService = ppacService
		self.healthCertificateService = healthCertificateService
		self.cache = cache
		super.init(style: .plain)
		title = "👩🏾‍💻 Developer Menu 🧑‍💻"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
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
	
	// MARK: - Protocol UITableView
	
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
		case .healthCertificateMigration:
			vc = DMHealthCertificateMigrationViewController(store: store)
		case .cclConfig:
			vc = DMCCLConfigurationViewController()
		case .revocationList:
			vc = DMRevocationListViewController()
		case .newHttp:
			vc = DMNHCViewController(
				store: store,
				cache: cache,
				appConfiguration: appConfigurationProvider,
				healthCertificateService: healthCertificateService
			)
		case .ticketValidation:
			vc = DMTicketValidationViewController(store: store)

		case .keys:
			vc = DMKeysViewController(
				client: client,
				store: store,
				exposureManager: exposureManager
			)
		case .notifications:
			vc = DMLocalNotificationsViewController(healthCertificateService: healthCertificateService)
		case .boosterRules:
			vc = DMBoosterChoosePersonViewController(store: store, healthCertificateService: healthCertificateService)
		case .wifiClient:
			vc = DMWifiClientViewController(restService: restServiceProvider)
		case .checkSubmittedKeys:
			vc = DMSubmissionStateViewController(
				client: client,
				restService: restServiceProvider,
				delegate: self
			)
		case .appConfiguration:
			vc = DMAppConfigurationViewController(appConfiguration: appConfigurationProvider)
		case .backendConfiguration:
			vc = DMBackendConfigurationViewController()
		case .store:
			vc = DMStoreViewController(store: store)
		case .lastSubmissionRequest:
			vc = DMLastSubmissionRequestViewController(lastSubmissionRequest: UserDefaults.standard.dmLastSubmissionRequest)
		case .lastOnBehalfSubmissionRequest:
			vc = DMLastSubmissionRequestViewController(lastSubmissionRequest: UserDefaults.standard.dmLastOnBehalfCheckinSubmissionRequest)
		case .errorLog:
			vc = DMLogsViewController()
		case .els:
			vc = DMErrorLogSharingViewController(store: store)
		case .sendFakeRequest:
			vc = nil
			sendFakeRequest()
		case .manuallyRequestRisk:
			vc = nil
			manuallyRequestRisk()
		case .deleteRiskFilesAndRequestRisk:
			vc = nil
			deleteRiskFilesAndRequestRisk()
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
			vc = DMWarnOthersNotificationViewController(warnOthersReminder: WarnOthersReminder(store: store), store: store, coronaTestService: coronaTestService)
		case .deviceTimeCheck:
			vc = DMDeviceTimeCheckViewController(store: store)
		case .ppacService:
			vc = DMPPACViewController(store, ppacService: ppacService)
		case .otpService:
			vc = DMOTPServiceViewController(store: store, otpService: otpService)
		case .ppaMostRecent:
			vc = DMPPAMostRecentData(store: store, restServiceProvider: restServiceProvider, appConfig: appConfigurationProvider, coronaTestService: coronaTestService, ppacService: ppacService)
		case .ppaActual:
			vc = DMPPAActualDataViewController(store: store, restServiceProvider: restServiceProvider, appConfig: appConfigurationProvider, coronaTestService: coronaTestService, ppacService: ppacService)
		case .ppaSubmission:
			vc = DMPPAnalyticsViewController(store: store, restServiceProvider: restServiceProvider, appConfig: appConfigurationProvider, coronaTestService: coronaTestService, ppacService: ppacService)
		case .installationDate:
			vc = DMInstallationDateViewController(store: store)
		case .allTraceLocations:
			vc = DMRecentCreatedEventViewController(store: store, eventStore: eventStore, qrCodePosterTemplateProvider: qrCodePosterTemplateProvider, isPosterGeneration: false)
		case .mostRecentTraceLocationCheckedInto:
			vc = DMDMMostRecentTraceLocationCheckedIntoViewController(store: store)
		case .adHocPosterGeneration:
			vc = DMRecentCreatedEventViewController(store: store, eventStore: eventStore, qrCodePosterTemplateProvider: qrCodePosterTemplateProvider, isPosterGeneration: true)
		case .appFeatures:
			vc = DMAppFeaturesViewController(store: store)
		case .dscLists:
			vc = DMDSCListsController(store: store)
		case .crashApp:
			vc = DMCrashAppViewController()
		}

		if let vc = vc {
			navigationController?.pushViewController(
				vc,
				animated: true
			)
		}
	}
		
	// MARK: - Private
	
	private let client: Client
	private let restServiceProvider: RestServiceProviding
	private let consumer = RiskConsumer()
	private let exposureSubmissionService: ExposureSubmissionService
	private let otpService: OTPServiceProviding
	private let coronaTestService: CoronaTestServiceProviding
	private let eventStore: EventStoringProviding
	private let qrCodePosterTemplateProvider: QRCodePosterTemplateProviding
	private let ppacService: PrivacyPreservingAccessControl
	private let healthCertificateService: HealthCertificateService
	private let cache: KeyValueCaching

	private var keys = [SAP_External_Exposurenotification_TemporaryExposureKey]() {
		didSet {
			keys = self.keys.sorted()
		}
	}

	@objc
	private func sendFakeRequest() {
		FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService).fakeRequest {
			let alert = self.setupErrorAlert(title: "Info", message: "Fake request was sent.")
			self.present(alert, animated: true) {}
		}
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
				self.store.enfRiskCalculationResult = nil
				self.store.checkinRiskCalculationResult = nil
				self.riskProvider.requestRisk(userInitiated: true)
			}
		)
		present(alert, animated: true, completion: nil)
	}
	
	private func deleteRiskFilesAndRequestRisk() {
		let alert = UIAlertController(
			title: "Manually delete downloaded files and request risk?",
			message: "⚠️⚠️⚠️ WARNING ⚠️⚠️⚠️\n\n This deletes the last calculated risk, downloded key packages and trace warnings from the store.",
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
				title: "Delete current risk data and request risk",
				style: .destructive
			) { _ in
				self.store.enfRiskCalculationResult = nil
				self.store.checkinRiskCalculationResult = nil
				
				// Reset packages store.
				self.downloadedPackagesStore.reset()
				self.downloadedPackagesStore.open()
				
				// Reset downloaded data from event store.
				self.eventStore.deleteAllTraceWarningPackageMetadata()
				self.eventStore.deleteAllTraceTimeIntervalMatches()
				
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
			downloadedPackagesStore: downloadedPackagesStore
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
