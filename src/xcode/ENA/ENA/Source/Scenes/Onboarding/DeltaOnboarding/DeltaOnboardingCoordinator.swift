//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingCoordinator {

	// MARK: - Attributes

	private weak var rootViewController: UIViewController?
	private let onboardings: [DeltaOnboarding]

	var finished: (() -> Void)?

	// MARK: - Initializers

	init(rootViewController: UIViewController, onboardings: [DeltaOnboarding]) {
		self.rootViewController = rootViewController
		self.onboardings = onboardings
	}

	// MARK: - Internal API

	func startOnboarding() {
		showNextOnboardingViewController()
	}

	// MARK: - Private API

	private func showNextOnboardingViewController() {
		guard let onboarding = nextOnboarding() else {
			finished?()
			return
		}

		let onboardingViewController = onboarding.makeViewController()

		onboardingViewController.finished = { [weak self] in
			self?.rootViewController?.dismiss(animated: true)
			onboarding.finish()
			self?.showNextOnboardingViewController()
		}

		self.rootViewController?.present(onboardingViewController, animated: true)
	}

	private func nextOnboarding() -> DeltaOnboarding? {
		return onboardings.first(where: { !$0.isFinished })
	}
	
}
