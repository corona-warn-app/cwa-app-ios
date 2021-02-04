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
	var id: String { get }
	var isFinished: Bool { get }

	func finish()
	func makeViewController() -> DeltaOnboardingViewControllerProtocol
}

extension DeltaOnboarding {
	var isFinished: Bool {
		
		// [KGA]
		let presented = store.finishedDeltaOnboardings[version] != nil && ((store.finishedDeltaOnboardings[version]?.contains(id)) != nil)
		
		if store.onboardingVersion.numericGreaterOrEqual(then: version) && !presented {
			return false
		}
		return true
	}
	
	// [KGA] Documentation
	var id: String {
		return version + String(describing: self)
	}
	
	func finish() {
		store.onboardingVersion = version
		
		// [KGA]
		if var finishedDeltaOnboardingVersion = store.finishedDeltaOnboardings[version] {
			if !finishedDeltaOnboardingVersion.contains(id) {
				finishedDeltaOnboardingVersion.append(id)
			}
		} else {
			store.finishedDeltaOnboardings[version] = [id]
		}
		
//		if(store.finishedDeltaOnboardings[version] != nil && !store.finishedDeltaOnboardings[version]?.contains(id)) {
//			store.finishedDeltaOnboardings[version]?.append(id)
//		}
	}

}
