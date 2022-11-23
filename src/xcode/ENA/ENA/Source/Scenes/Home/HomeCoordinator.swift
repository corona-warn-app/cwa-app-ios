//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

// swiftlint:disable type_body_length
class HomeCoordinator: RequiresAppDependencies {

	// MARK: - Init

	init(
		_ delegate: CoordinatorDelegate,
		otpService: OTPServiceProviding,
		ppacService: PrivacyPreservingAccessControl,
		eventStore: EventStoringProviding,
		coronaTestService: CoronaTestServiceProviding,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		elsService: ErrorLogSubmissionProviding,
		srsService: SRSServiceProviding,
		exposureSubmissionService: ExposureSubmissionService,
		qrScannerCoordinator: QRScannerCoordinator,
		recycleBin: RecycleBin,
		restServiceProvider: RestServiceProviding,
		badgeWrapper: HomeBadgeWrapper,
		cache: KeyValueCaching,
		cclService: CCLServable,
		homeState: HomeState
	) {
		self.delegate = delegate
		self.otpService = otpService
		self.ppacService = ppacService
		self.eventStore = eventStore
		self.coronaTestService = coronaTestService
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.elsService = elsService
		self.srsService = srsService
		self.exposureSubmissionService = exposureSubmissionService
		self.qrScannerCoordinator = qrScannerCoordinator
		self.recycleBin = recycleBin
		self.restServiceProvider = restServiceProvider
		self.badgeWrapper = badgeWrapper
		self.cache = cache
		self.cclService = cclService
		self.homeState = homeState
	}

	deinit {
		enStateUpdateList.removeAllObjects()
	}

	// MARK: - Internal

	let rootViewController: UINavigationController = NavigationControllerWithLargeTitle(rootViewController: UIViewController())

	func showHome(enStateHandler: ENStateHandler, route: Route?, startupErrors: [Error]) {
		guard homeController == nil else {
			switch route {
			case .rapidAntigen, .rapidPCR, .testResultFromNotification, .familyMemberTestResultFromNotification:
				selectHomeTabSection(route: route)
				return
			case .checkIn,
				 .healthCertificateFromNotification,
				 .healthCertifiedPersonFromNotification,
				 .none:
				/*
				 .healthCertifiedPersonFromNotification .checkIn and
				 .healthCertificateFromNotification routings are checked in the
				 showHome function in the RootCoordinator inside the defer block.
				 So basically here we show home THEN excute the routings in the defer
				*/
				rootViewController.dismiss(animated: false)
				rootViewController.popToRootViewController(animated: false)
				rootViewController.tabBarController?.selectedIndex = 0
				homeController?.scrollToTop(animated: false)
				return
			}
		}

		let homeController = HomeTableViewController(
			viewModel: HomeTableViewModel(
				state: homeState,
				store: store,
				appConfiguration: appConfigurationProvider,
				coronaTestService: coronaTestService,
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				onTestResultCellTap: { [weak self] coronaTestType in
					self?.showExposureSubmission(testType: coronaTestType)
				},
				badgeWrapper: badgeWrapper
			),
			appConfigurationProvider: appConfigurationProvider,
			route: route,
			startupErrors: startupErrors,
			onInfoBarButtonItemTap: { [weak self] in
				self?.showRiskLegend()
			},
			onExposureLoggingCellTap: { [weak self] enState in
				self?.showExposureNotificationSetting(enState: enState)
			},
			onRiskCellTap: { [weak self] homeState in
				self?.showExposureDetection(state: homeState)
			},
			onFamilyTestResultsCellTap: { [weak self] in
				self?.showFamilyMemberCoronaTests()
			},
			onInactiveCellButtonTap: { [weak self] enState in
				self?.showExposureNotificationSetting(enState: enState)
			},
			onTestRegistrationCellTap: { [weak self] in
				self?.showExposureSubmission()
			},
			onStatisticsInfoButtonTap: { [weak self] in
				self?.showStatisticsInfo()
			},
			onTraceLocationsCellTap: { [weak self] in
				self?.showTraceLocations()
			},
			onInviteFriendsCellTap: { [weak self] in
				self?.showInviteFriends()
			},
			onFAQCellTap: { [weak self] in
				guard let self = self else { return }
				self.showWebPage(urlString: AppStrings.SafariView.targetURL)
			},
			onSocialMediaCellTap: { [weak self] in
				guard let self = self else { return }
				self.showWebPage(urlString: AppStrings.SafariView.socialMedia)
			},
			onAppInformationCellTap: { [weak self] in
				self?.showAppInformation()
			},
			onSettingsCellTap: { [weak self] enState in
				self?.showSettings(enState: enState)
			},
			onRecycleBinCellTap: { [weak self] in
				self?.showRecycleBin()
			},
			showTestInformationResult: { [weak self] testInformationResult in
				self?.showExposureSubmission(testInformationResult: testInformationResult)
			},
			showUserTestResultFromNotification: { [weak self] coronaTestType in
				self?.showTestResultFromNotification(with: coronaTestType)
			},
			showFamilyMemberCoronaTestsFromNotification: { [weak self] in
				self?.showFamilyMemberTestsFromNotification()
			},
			onAddLocalStatisticsTap: { [weak self] selectValueViewController in
				self?.rootViewController.present(
					UINavigationController(rootViewController: selectValueViewController),
					animated: true
				)
			},
			onAddDistrict: { [weak self] selectValueViewController in
				guard let navigationController = self?.rootViewController.presentedViewController as? UINavigationController else {
					Log.error("add statistics Navigation controller should be presented")
					return
				}
				navigationController.pushViewController(selectValueViewController, animated: true)
			},
			onDismissState: { [weak self] in
				self?.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
			},
			onDismissDistrict: { [weak self] dismissToRoot in
				if dismissToRoot {
					self?.rootViewController.dismiss(animated: true, completion: nil)
				} else {
					self?.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
				}
			}
		)

		self.homeController = homeController
		addToEnStateUpdateList(homeState)
		setupHomeBadgeCount()

		UIView.transition(with: rootViewController.view, duration: CATransaction.animationDuration(), options: [.transitionCrossDissolve], animations: {
			self.rootViewController.setViewControllers([homeController], animated: false)
			#if !RELEASE
			self.enableDeveloperMenuIfAllowed(in: homeController)
			#endif
		})
	}

	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeState.updateDetectionMode(detectionMode)
	}

	// MARK: - Private
	
	private let ppacService: PrivacyPreservingAccessControl
	private let otpService: OTPServiceProviding
	private let eventStore: EventStoringProviding
	private let coronaTestService: CoronaTestServiceProviding
	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private let elsService: ErrorLogSubmissionProviding
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let exposureSubmissionService: ExposureSubmissionService
	private let srsService: SRSServiceProviding
	private let qrScannerCoordinator: QRScannerCoordinator
	private let recycleBin: RecycleBin
	private let restServiceProvider: RestServiceProviding
	private let badgeWrapper: HomeBadgeWrapper
	private let cache: KeyValueCaching
	private let cclService: CCLServable

	private var homeController: HomeTableViewController?
	private var homeState: HomeState
	private var settingsController: SettingsViewController?
	private var familyMemberCoronaTestsCoordinator: FamilyMemberCoronaTestsCoordinator?
	private var traceLocationsCoordinator: TraceLocationsCoordinator?
	private var settingsCoordinator: SettingsCoordinator?
	private var exposureDetectionCoordinator: ExposureDetectionCoordinator?

	private var enStateUpdateList = NSHashTable<AnyObject>.weakObjects()
	private var subscriptions = Set<AnyCancellable>()

	private weak var delegate: CoordinatorDelegate?

	private lazy var qrCodePosterTemplateProvider: QRCodePosterTemplateProvider = {
		return QRCodePosterTemplateProvider(
			client: CachingHTTPClient(),
			store: store
		)
	}()
	
	private lazy var vaccinationValueSetsProvider: VaccinationValueSetsProvider = {
		return VaccinationValueSetsProvider(
			client: CachingHTTPClient(),
			store: store
		)
	}()

	private lazy var healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProvider = {
		return HealthCertificateValidationOnboardedCountriesProvider(
			restService: restServiceProvider
		)
	}()

	private func selectHomeTabSection(route: Route?) {
		DispatchQueue.main.async { [weak self] in
			guard let rootViewController = self?.rootViewController,
				let index = self?.homeController?.tabBarController?.viewControllers?.firstIndex(of: rootViewController) else {
				Log.debug("Failed to find tabBarController and select correct tab")
				return
			}
			self?.homeController?.tabBarController?.dismiss(animated: false)
			self?.homeController?.tabBarController?.selectedIndex = index
			self?.homeController?.route = route
			self?.homeController?.showDeltaOnboardingAndAlertsIfNeeded()
		}
	}

	private func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			exposureManager.enable(completion: completion)
		} else {
			exposureManager.disable(completion: completion)
		}
	}

	private func showRiskLegend() {
		let riskLegendViewController = RiskLegendViewController(
			onDismiss: { [weak rootViewController] in
				rootViewController?.dismiss(animated: true)
			},
			appConfigProvider: appConfigurationProvider
		)

		rootViewController.present(
			UINavigationController(rootViewController: riskLegendViewController),
			animated: true
		)
	}

	private func showExposureNotificationSetting(enState: ENStateHandler.State) {
		let vc = ExposureNotificationSettingViewController(
			initialEnState: enState,
			store: self.store,
			appConfigurationProvider: self.appConfigurationProvider,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, then: completion)
			}
		)
		addToEnStateUpdateList(vc)
		
		guard !rootViewController.viewControllers.contains(where: { $0 is ExposureNotificationSettingViewController }) else { return }
		
		rootViewController.pushViewController(vc, animated: true)
	}

	private func showExposureDetection(state: HomeState) {
		exposureDetectionCoordinator = ExposureDetectionCoordinator(
			rootViewController: rootViewController,
			store: store,
			homeState: homeState,
			exposureManager: exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			otpService: otpService,
			ppacService: ppacService
		)
		exposureDetectionCoordinator?.start()
	}

	private func showExposureSubmission(testType: CoronaTestType? = nil, testInformationResult: Result<CoronaTestRegistrationInformation, QRCodeError>? = nil) {
		// A strong reference to the coordinator is passed to the exposure submission navigation controller
		// when .start() is called. The coordinator is then bound to the lifecycle of this navigation controller
		// which is managed by UIKit.
		let coordinator = ExposureSubmissionCoordinator(
			parentViewController: rootViewController,
			exposureSubmissionService: exposureSubmissionService,
			coronaTestService: coronaTestService,
			srsService: srsService,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			eventProvider: eventStore,
			antigenTestProfileStore: store,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			qrScannerCoordinator: qrScannerCoordinator,
			recycleBin: recycleBin
		)

		if let testInformationResult = testInformationResult {
			coordinator.start(with: testInformationResult)
		} else {
			coordinator.start(with: .registeredTest(testType))
		}
	}

	private func showFamilyMemberCoronaTests() {
		familyMemberCoronaTestsCoordinator = FamilyMemberCoronaTestsCoordinator(
			parentNavigationController: rootViewController,
			familyMemberCoronaTestService: familyMemberCoronaTestService,
			appConfigurationProvider: appConfigurationProvider,
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider
		)

		familyMemberCoronaTestsCoordinator?.start()
	}

	private func showStatisticsInfo() {
		let statisticsInfoController = StatisticsInfoViewController(
			onDismiss: { [weak rootViewController] in
				rootViewController?.dismiss(animated: true)
			}
		)

		rootViewController.present(
			UINavigationController(rootViewController: statisticsInfoController),
			animated: true
		)
	}

	private func showTraceLocations() {
		traceLocationsCoordinator = TraceLocationsCoordinator(
			store: store,
			restServiceProvider: restServiceProvider,
			appConfig: appConfigurationProvider,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
			eventStore: eventStore,
			parentNavigationController: rootViewController,
			qrScannerCoordinator: qrScannerCoordinator
		)

		traceLocationsCoordinator?.start()
	}

	private func showInviteFriends() {
		rootViewController.pushViewController(
			InviteFriendsViewController(),
			animated: true
		)
	}

	private func showWebPage(urlString: String) {
		LinkHelper.open(urlString: urlString)
	}

	private func showAppInformation() {
		rootViewController.pushViewController(
			AppInformationViewController(
				elsService: elsService,
				finishedDeltaOnboardings: store.finishedDeltaOnboardings,
				cclService: cclService
			),
			animated: true
		)
	}

	private func showSettings(enState: ENStateHandler.State) {
		settingsCoordinator = SettingsCoordinator(
			store: store,
			initialEnState: enState,
			appConfigurationProvider: appConfigurationProvider,
			parentNavigationController: rootViewController,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, then: completion)
			},
			onResetRequest: { [weak self] in
				guard let self = self else { return }

				self.delegate?.coordinatorUserDidRequestReset(exposureSubmissionService: self.exposureSubmissionService)
			}
		)

		settingsCoordinator?.start()

		addToEnStateUpdateList(settingsCoordinator)
	}

	private func showRecycleBin() {
		let recycleBinViewController = RecycleBinViewController(
			viewModel: RecycleBinViewModel(
				store: store,
				recycleBin: recycleBin,
				onOverwrite: { [weak self] in
					self?.showTestOverwriteNotice(recycleBinItem: $0)
				}
			)
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.RecycleBin.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .systemRed
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: recycleBinViewController,
			bottomController: footerViewController
		)

		rootViewController.pushViewController(
			topBottomContainerViewController,
			animated: true
		)
	}

	private func showTestOverwriteNotice(
		recycleBinItem: RecycleBinItem
	) {
		guard case let .userCoronaTest(coronaTest) = recycleBinItem.item else {
			return
		}

		let footerViewModel = FooterViewModel(
			primaryButtonName: AppStrings.ExposureSubmission.OverwriteNotice.primaryButton,
			isSecondaryButtonHidden: true
		)

		let overwriteNoticeViewController = TestOverwriteNoticeViewController(
			testType: coronaTest.type,
			didTapPrimaryButton: { [weak self] in
				self?.recycleBin.restore(recycleBinItem)
				self?.rootViewController.dismiss(animated: true)
			},
			didTapCloseButton: { [weak self] in
				self?.rootViewController.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(footerViewModel)
		let topBottomViewController = TopBottomContainerViewController(
			topController: overwriteNoticeViewController,
			bottomController: footerViewController
		)

		rootViewController.present(
			NavigationControllerWithLargeTitle(rootViewController: topBottomViewController),
			animated: true
		)
	}

	private func showTestResultFromNotification(with testType: CoronaTestType) {
		rootViewController.popToRootViewController(animated: false)

		if let presentedViewController = rootViewController.presentedViewController {
			presentedViewController.dismiss(animated: true) {
				self.showExposureSubmission(testType: testType)
			}
		} else {
			self.showExposureSubmission(testType: testType)
		}
	}

	private func showFamilyMemberTestsFromNotification() {
		rootViewController.popToRootViewController(animated: false)

		if let presentedViewController = rootViewController.presentedViewController {
			presentedViewController.dismiss(animated: true) {
				self.showFamilyMemberCoronaTests()
			}
		} else {
			self.showFamilyMemberCoronaTests()
		}
	}

	private func addToEnStateUpdateList(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
		   anyObject is ENStateHandlerUpdating {
			enStateUpdateList.add(anyObject)
		}
	}

	private func setupHomeBadgeCount() {
		// risk change might update the badge count string
		homeState.$riskState
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] riskState in
				// check if risk level changed and if home screen tab is not selected
				guard case let .risk(risk) = riskState,
					  risk.riskLevelHasChanged,
					  self?.rootViewController.tabBarController?.selectedViewController != self?.rootViewController
				else {
					Log.info("home screen tab is active - skipped to set tab bar badge")
					return
				}
				self?.badgeWrapper.update(.riskStateChanged, value: 1)
			}
			.store(in: &subscriptions)

		// badge count string updates gets shown inside UI
		badgeWrapper.$stringValue
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] badgeStringValue in
				self?.rootViewController.tabBarItem.badgeValue = badgeStringValue
			}
			.store(in: &subscriptions)
	}

	// MARK: - HealthCertificate

	#if !RELEASE
	private var developerMenu: DMDeveloperMenu?
	private func enableDeveloperMenuIfAllowed(in controller: UIViewController) {
		developerMenu = DMDeveloperMenu(
			presentingViewController: controller,
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			exposureManager: exposureManager,
			developerStore: UserDefaults.standard,
			exposureSubmissionService: exposureSubmissionService,
			environmentProvider: Environments(),
			otpService: otpService,
			coronaTestService: coronaTestService,
			eventStore: eventStore,
			qrCodePosterTemplateProvider: qrCodePosterTemplateProvider,
			ppacService: ppacService,
			healthCertificateService: healthCertificateService,
			cache: cache
		)
		developerMenu?.enableIfAllowed()
	}
	#endif
}

extension HomeCoordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeState.updateExposureManagerState(state)
		settingsController?.updateExposureState(state)
	}
}

extension HomeCoordinator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeState.updateEnState(state)
		updateAllState(state)
	}

	private func updateAllState(_ state: ENStateHandler.State) {
		enStateUpdateList.allObjects.forEach { anyObject in
			if let updating = anyObject as? ENStateHandlerUpdating {
				updating.updateEnState(state)
			}
		}
	}
}
