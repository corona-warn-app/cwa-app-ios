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
		Log.debug("Check, if \(id) is already finished...")
		// [KGA]
		let presented = store.finishedDeltaOnboardings[version] != nil && ((store.finishedDeltaOnboardings[version]?.contains(id)) == true)
		Log.debug("DeltaOnboarding \(id) already presented: \(presented).")
		if !store.onboardingVersion.numericGreater(then: version) && !presented {
			Log.debug("isFinished will return: false")
			return false
		}
		Log.debug("isFinished will return: true")
		return true
		
	}
	
	// [KGA] Documentation
	var id: String {
		Log.debug("DeltaOnboarding ID: \(version + String(describing: self))")
		return version + String(describing: self)
	}
	
	func finish() {
		Log.debug("DeltaOnboarding finished...")
		if !store.onboardingVersion.numericGreaterOrEqual(then: version) {
			store.onboardingVersion = version
		}
				
		// [KGA]
		if var finishedDeltaOnboardingVersion = store.finishedDeltaOnboardings[version] {
			if !finishedDeltaOnboardingVersion.contains(id) {
				finishedDeltaOnboardingVersion.append(id)
				store.finishedDeltaOnboardings[version] = finishedDeltaOnboardingVersion
				Log.debug("Finished DeltaOnboarding for Version \(version): \(id)")
			}
		} else {
			store.finishedDeltaOnboardings[version] = [id]
			Log.debug("First finished DeltaOnboarding for Version \(version): \(id)")
		}

	}

}
