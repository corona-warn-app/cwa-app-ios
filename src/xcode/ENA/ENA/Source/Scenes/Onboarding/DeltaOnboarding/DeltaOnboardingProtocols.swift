//
// 🦠 Corona-Warn-App
//

import UIKit

protocol DeltaOnboardingViewControllerProtocol: UIViewController {
	var finished: (() -> Void)? { get set }
}

protocol DeltaOnboarding {
	var version: String { get }
	var store: Store { get }
	var isFinished: Bool { get }

	func finish()
	func makeViewController() -> DeltaOnboardingViewControllerProtocol
}

extension DeltaOnboarding {
	var isFinished: Bool {
		return store.onboardingVersion.numericGreaterOrEqual(then: version)
	}
	
	func finish() {
		store.onboardingVersion = version
	}

}
