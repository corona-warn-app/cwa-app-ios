////
// 🦠 Corona-Warn-App
//

import UIKit

final class ExposureDetectionCoordinator {

	private let appConfigurationProvider: AppConfigurationProviding
	private let rootViewController: UIViewController
	private var navigationController: ENANavigationControllerWithFooter?
	private let store: Store
	private let homeState: HomeState
	private let exposureManager: ExposureManager
	private let client: Client

	init(
		rootViewController: UIViewController,
		store: Store,
		homeState: HomeState,
		exposureManager: ExposureManager,
		client: Client,
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.rootViewController = rootViewController
		self.store = store
		self.homeState = homeState
		self.exposureManager = exposureManager
		self.client = client
		self.appConfigurationProvider = appConfigurationProvider
	}

	func start() {
		let exposureDetectionController = ExposureDetectionViewController(
			viewModel: ExposureDetectionViewModel(
				homeState: homeState,
				appConfigurationProvider: appConfigurationProvider,
				onSurveyTap: { [weak self] urlString in
					self?.showSurveyConsent(for: urlString)
				},
				onInactiveButtonTap: { [weak self] completion in
					self?.setExposureManagerEnabled(true, then: completion)
				}
			),
			store: store
		)

		let _navigationController = ENANavigationControllerWithFooter(rootViewController: exposureDetectionController)
		navigationController = _navigationController
		setNavigationBarHidden(true)
		
		rootViewController.present(_navigationController, animated: true)
	}

	private func showSurveyConsent(for surveyURL: String?) {
		setNavigationBarHidden(false)

		// ToDo: Replace with real services

		let deviceCheckMock = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		guard let ppacService = try? PPACService(
			store: store,
			deviceCheck: deviceCheckMock
		) else {
			return
		}

		let otpService = OTPService(store: store, client: client)

		let surveyURLProvider = SurveyURLProvider(
			configurationProvider: appConfigurationProvider,
			ppacService: ppacService,
			otpService: otpService
		)

		let viewModel = SurveyConsentViewModel(
			surveyURLProvider: surveyURLProvider
		)

		let surveyConsentViewController = SurveyConsentViewController(viewModel: viewModel) { [weak self] url in
			self?.showSurveyWebpage(url: url)
		}
		navigationController?.pushViewController(surveyConsentViewController, animated: true)
	}

	private func showSurveyWebpage(url: URL) {
		UIApplication.shared.open(url)
	}

	private func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			exposureManager.enable(completion: completion)
		} else {
			exposureManager.disable(completion: completion)
		}
	}

	private func setNavigationBarHidden(_ hidden: Bool) {
		navigationController?.setNavigationBarHidden(hidden, animated: false)
	}
}
