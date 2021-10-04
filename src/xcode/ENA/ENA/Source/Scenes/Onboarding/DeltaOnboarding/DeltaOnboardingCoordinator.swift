//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingCoordinator {

	// MARK: - Attributes

	private weak var rootViewController: UIViewController?
	private let onboardings: [DeltaOnboarding]
	private let store: Store

	var finished: (() -> Void)?

	// MARK: - Initializers

	init(
		rootViewController: UIViewController,
		onboardings: [DeltaOnboarding],
		store: Store
	) {
		self.rootViewController = rootViewController
		self.onboardings = onboardings
		self.store = store
	}

	// MARK: - Internal API

	func startOnboarding() {
		showNextOnboardingViewController()
	}

	// MARK: - Private API

	private func showNextOnboardingViewController() {
		guard let onboarding = nextOnboarding() else {
			let appVersion = Bundle.main.appVersion
			if !store.onboardingVersion.numericGreaterOrEqual(then: appVersion) {
				store.onboardingVersion = appVersion
			}
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
	
	// Migrates the "old" finished and saved delta onboardings where only the version number is saved to the "new" one, where we save the name of the onboarding.
	
	
}
