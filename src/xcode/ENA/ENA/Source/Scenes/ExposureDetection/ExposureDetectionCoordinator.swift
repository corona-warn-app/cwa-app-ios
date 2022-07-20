////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class ExposureDetectionCoordinator {
	
	// MARK: - Init
	
	init(
		rootViewController: UIViewController,
		store: Store,
		homeState: HomeState,
		exposureManager: ExposureManager,
		appConfigurationProvider: AppConfigurationProviding,
		otpService: OTPServiceProviding,
		ppacService: PrivacyPreservingAccessControl
	) {
		self.rootViewController = rootViewController
		self.store = store
		self.homeState = homeState
		self.exposureManager = exposureManager
		self.appConfigurationProvider = appConfigurationProvider
		self.otpService = otpService
		
		self.surveyURLProvider = SurveyURLProvider(
			configurationProvider: appConfigurationProvider,
			ppacService: ppacService,
			otpService: otpService
		)
	}
	
	// MARK: - Internal
	
	func start() {
		let exposureDetectionController = ExposureDetectionViewController(
			viewModel: ExposureDetectionViewModel(
				homeState: homeState,
				appConfigurationProvider: appConfigurationProvider,
				onSurveyTap: { [weak self] in
					guard let self = self else {
						return
					}

					if self.otpService.isOTPEdusAvailable {
						self.showSurveyWebpage()
					} else {
						self.showSurveyConsent()
					}
				},
				onInactiveButtonTap: { [weak self] in
					self?.showExposureNotificationSettingsScreen()
				},
				onHygieneRulesInfoButtonTap: { [weak self] in
					self?.showHygieneRulesInfoScreen()
				},
				onRiskOfContagionInfoButtonTap: { [weak self] in
					self?.showRiskOfContagionInfoScreen()
				}
			),
			store: store
		)

		let _navigationController = ENANavigationControllerWithFooter(rootViewController: exposureDetectionController)
		navigationController = _navigationController
		setNavigationBarHidden(true)
		
		rootViewController.present(_navigationController, animated: true)
	}
	
	// MARK: - Private
	
	private let appConfigurationProvider: AppConfigurationProviding
	private let rootViewController: UIViewController
	private var navigationController: ENANavigationControllerWithFooter?
	private let store: Store
	private let homeState: HomeState
	private let exposureManager: ExposureManager
	private let otpService: OTPServiceProviding
	private let surveyURLProvider: SurveyURLProviding

	private var subscriptions = [AnyCancellable]()
	
	private func showExposureNotificationSettingsScreen() {
		let viewController = ExposureNotificationSettingViewController(
			initialEnState: homeState.enState,
			store: store,
			appConfigurationProvider: appConfigurationProvider,
			setExposureManagerEnabled: { [weak self] newState, completion in
				self?.setExposureManagerEnabled(newState, then: completion)
			}
		)
		
		homeState.$enState
			.sink { viewController.updateEnState($0) }
			.store(in: &subscriptions)
		
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func showHygieneRulesInfoScreen() {
		let viewController = HygieneRulesInfoViewController(
			dismiss: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
		)
		let infoNavigationController = UINavigationController(rootViewController: viewController)
		navigationController?.present(infoNavigationController, animated: true)
	}
	
	private func showRiskOfContagionInfoScreen() {
		let viewController = ContagionInfoViewController(
			dismiss: { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
		)
		let infoNavigationController = UINavigationController(rootViewController: viewController)
		navigationController?.present(infoNavigationController, animated: true)
	}
	
	private func showSurveyConsent() {
		setNavigationBarHidden(false)

		let viewModel = SurveyConsentViewModel(
			surveyURLProvider: surveyURLProvider
		)

		let surveyConsentViewController = SurveyConsentViewController(viewModel: viewModel) { [weak self] url in
			self?.showSurveyWebpage(with: url)
		}
		navigationController?.pushViewController(surveyConsentViewController, animated: true)
	}

	private func showSurveyWebpage() {
		surveyURLProvider.getURL { [weak self] result in
			switch result {
			case .success(let url):
				self?.showSurveyWebpage(with: url)
			case .failure(let error):
				self?.showSurveyErrorAlert(with: error)
			}
		}
	}

	private func showSurveyErrorAlert(with error: SurveyError) {
		let errorAlert = UIAlertController.errorAlert(
			title: AppStrings.SurveyConsent.errorTitle,
			message: error.description
		)
		navigationController?.present(errorAlert, animated: true)
	}

	private func showSurveyWebpage(with url: URL) {
		LinkHelper.open(url: url)
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
