//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryCoordinator {

	// MARK: - Attributes

	private weak var rootViewController: UIViewController?

	var finished: (() -> Void)?

	// MARK: - Initializers

	init(rootViewController: UIViewController, onboardings: [DeltaOnboarding]) {
		self.rootViewController = rootViewController
	}

	// MARK: - Internal API

	func start() {
		showInitalViewController()
	}

	// MARK: - Private API

	private func showInitalViewController() {

	}
	
}
