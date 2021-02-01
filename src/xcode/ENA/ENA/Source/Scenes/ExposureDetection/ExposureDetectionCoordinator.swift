////
// 🦠 Corona-Warn-App
//

import UIKit

final class ExposureDetectionCoordinator {

	private let rootViewController: UIViewController
	private var navigationController: UINavigationController?
	private let store: Store
	private let homeState: HomeState
	private let exposureManager: ExposureManager

	init(
		rootViewController: UIViewController,
		store: Store,
		homeState: HomeState,
		exposureManager: ExposureManager
	) {
		self.rootViewController = rootViewController
		self.store = store
		self.homeState = homeState
		self.exposureManager = exposureManager
	}

	func start() {
		let exposureDetectionController = ExposureDetectionViewController(
			viewModel: ExposureDetectionViewModel(
				homeState: homeState,
				onInactiveButtonTap: { [weak self] completion in
					self?.setExposureManagerEnabled(true, then: completion)
				},
				onSurveyTap: { [weak self] in
					self?.showSurveyConsent()
				}
			),
			store: store
		)

		let _navigationController = UINavigationController(rootViewController: exposureDetectionController)
		navigationController = _navigationController
		setNavigationBarHidden(true)
		
		rootViewController.present(_navigationController, animated: true)
	}

	private func showSurveyConsent() {
		setNavigationBarHidden(false)

		let surveyConsentViewController = SurveyConsentViewController(viewModel: SurveyConsentViewModel()) { [weak self] url in
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
