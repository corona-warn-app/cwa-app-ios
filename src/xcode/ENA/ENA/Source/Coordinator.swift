//
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
//

import UIKit
import Connectivity

protocol CoordinatorDelegate: AnyObject {
	func coordinatorUserDidRequestReset()
}

class Coordinator: RequiresAppDependencies {
	private weak var delegate: CoordinatorDelegate?

	private let rootViewController: UINavigationController

	private var homeController: HomeViewController?
	private var settingsController: SettingsViewController?
	private var exposureDetectionController: ExposureDetectionViewController?

	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		ExposureSubmissionServiceFactory.create(
			diagnosiskeyRetrieval: self.exposureManager,
			client: self.client,
			store: self.store
		)
	}()

	private var enStateUpdatingSet = NSHashTable<AnyObject>.weakObjects()

	init(_ delegate: CoordinatorDelegate, _ rootViewController: UINavigationController) {
		self.delegate = delegate
		self.rootViewController = rootViewController
	}

	deinit {
		enStateUpdatingSet.removeAllObjects()
	}

	func showHome(enStateHandler: ENStateHandler, state: SceneDelegate.State) {
		let vc = AppStoryboard.home.initiate(viewControllerType: HomeViewController.self) { [unowned self] coder in
			HomeViewController(
				coder: coder,
				delegate: self,
				detectionMode: state.detectionMode,
				exposureManagerState: state.exposureManager,
				initialEnState: enStateHandler.state,
				risk: state.risk,
				exposureSubmissionService: self.exposureSubmissionService
			)
		}

		homeController = vc // strong ref needed

		UIView.transition(with: rootViewController.view, duration: CATransaction.animationDuration(), options: [.transitionCrossDissolve], animations: {
			self.rootViewController.setViewControllers([vc], animated: false)
		})

		#if !RELEASE
		enableDeveloperMenuIfAllowed(in: vc)
		#endif
	}

	func showOnboarding() {
		rootViewController.navigationBar.prefersLargeTitles = false
		rootViewController.setViewControllers(
			[
				AppStoryboard.onboarding.initiateInitial { [unowned self] coder in
					OnboardingInfoViewController(
						coder: coder,
						pageType: .togetherAgainstCoronaPage,
						exposureManager: self.exposureManager,
						store: self.store
					)
				}
			],
			animated: false
		)
	}

	func updateState(detectionMode: DetectionMode, exposureManagerState: ExposureManagerState, risk: Risk?) {
		homeController?.updateState(detectionMode: detectionMode, exposureManagerState: exposureManagerState, risk: risk)
	}

	#if !RELEASE
	private var developerMenu: DMDeveloperMenu?
	private func enableDeveloperMenuIfAllowed(in controller: UIViewController) {
		developerMenu = DMDeveloperMenu(
			presentingViewController: controller,
			client: client,
			store: store,
			exposureManager: exposureManager
		)
		developerMenu?.enableIfAllowed()
	}
	#endif

	private func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			exposureManager.enable(completion: completion)
		} else {
			exposureManager.disable(completion: completion)
		}
	}
}

extension Coordinator: HomeViewControllerDelegate {
	func showRiskLegend() {
		rootViewController.present(
			AppStoryboard.riskLegend.initiateInitial(),
			animated: true,
			completion: nil
		)
	}

	func showExposureNotificationSetting(enState: ENStateHandler.State) {
		let storyboard = AppStoryboard.exposureNotificationSetting.instance
		let vc = storyboard.instantiateViewController(identifier: "ExposureNotificationSettingViewController") { coder in
			ExposureNotificationSettingViewController(
					coder: coder,
					initialEnState: enState,
					store: self.store,
					delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
		rootViewController.pushViewController(vc, animated: true)
	}

	func showExposureDetection(state: HomeInteractor.State, isRequestRiskRunning: Bool) {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: state.exposureManagerState,
			detectionMode: state.detectionMode,
			isLoading: isRequestRiskRunning,
			risk: state.risk
		)
		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				delegate: self
			)
		}
//		delegate?.addToUpdatingSetIfNeeded(vc)
		exposureDetectionController = vc as? ExposureDetectionViewController
		rootViewController.present(vc, animated: true)
	}

	func setExposureDetectionState(state: HomeInteractor.State, isRequestRiskRunning: Bool) {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: state.exposureManagerState,
			detectionMode: state.detectionMode,
			isLoading: isRequestRiskRunning,
			risk: state.risk
		)
		exposureDetectionController?.state = state
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		rootViewController.present(
			AppStoryboard.exposureSubmission.initiateInitial { coder in
				ExposureSubmissionNavigationController(
					coder: coder,
					exposureSubmissionService: self.exposureSubmissionService,
					submissionDelegate: self,
					testResult: result
				)
			},
			animated: true
		)
	}

	func showInviteFriends() {
		rootViewController.pushViewController(
			FriendsInviteController.initiate(for: .inviteFriends),
			animated: true
		)
	}

	func showWebPage(from viewController: UIViewController, urlString: String) {
		WebPageHelper.showWebPage(from: viewController, urlString: urlString)
	}

	func showAppInformation() {
		rootViewController.pushViewController(
			AppInformationViewController(),
			animated: true
		)
	}

	func showSettings(enState: ENStateHandler.State) {
		let storyboard = AppStoryboard.settings.instance
		let vc = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
			SettingsViewController(
				coder: coder,
				store: self.store,
				initialEnState: enState,
				delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
		settingsController = vc
		rootViewController.pushViewController(vc, animated: true)
	}

	func addToUpdatingSetIfNeeded(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
		   anyObject is ENStateHandlerUpdating {
			enStateUpdatingSet.add(anyObject)
		}
	}
}

extension Coordinator: ExposureNotificationSettingViewControllerDelegate {
	func exposureNotificationSettingViewController(_ controller: ExposureNotificationSettingViewController, setExposureManagerEnabled enabled: Bool, then completion: @escaping Completion) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension Coordinator: ExposureDetectionViewControllerDelegate {
	func didStartLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		homeController?.updateAndReloadRiskLoading(isRequestRiskRunning: true)
	}

	func didFinishLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		homeController?.updateAndReloadRiskLoading(isRequestRiskRunning: false)
	}

	func exposureDetectionViewController(
		_: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension Coordinator: ExposureSubmissionNavigationControllerDelegate {
	func exposureSubmissionNavigationControllerWillDisappear(_ controller: ExposureSubmissionNavigationController) {
		homeController?.updateTestResultState()
	}
}

extension Coordinator: SettingsViewControllerDelegate {
	func settingsViewController(_ controller: SettingsViewController, setExposureManagerEnabled enabled: Bool, then completion: @escaping Completion) {
		setExposureManagerEnabled(enabled, then: completion)
	}

	func settingsViewControllerUserDidRequestReset(_ controller: SettingsViewController) {
		delegate?.coordinatorUserDidRequestReset()
	}
}

extension Coordinator: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeController?.updateExposureState(state)
		settingsController?.updateExposureState(state)
		exposureDetectionController?.updateUI()
	}
}

extension Coordinator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeController?.updateEnState(state)
		updateAllState(state)
	}

	private func updateAllState(_ state: ENStateHandler.State) {
		enStateUpdatingSet.allObjects.forEach { anyObject in
			if let updating = anyObject as? ENStateHandlerUpdating {
				updating.updateEnState(state)
			}
		}
	}
}
