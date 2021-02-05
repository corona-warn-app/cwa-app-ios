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
		let presented = store.finishedDeltaOnboardings[version] != nil && ((store.finishedDeltaOnboardings[version]?.contains(id)) == true)
		
		Log.debug("DeltaOnboarding \(id) already presented? \(presented).")
		if !store.onboardingVersion.numericGreater(then: version) && !presented {
			Log.debug("isFinished -> false")
			return false
		}
		Log.debug("isFinished -> true")
		return true
		
	}
	
	/// The `id` is a identifier generated out of the version of the concrete delta onboarding implementation and the corresponding class name
	/// This ensures that we
	/// a) can have multiple delta onboardings for the same version
	/// b) can reuse existing prodotocl implementation (e. g. new features) by just changing the version.
	var id: String {
		return version + String(describing: self)
	}
	
	func finish() {
		Log.debug("DeltaOnboarding finished...")
		if !store.onboardingVersion.numericGreaterOrEqual(then: version) {
			store.onboardingVersion = version
		}
				
		if var finishedDeltaOnboardingVersion = store.finishedDeltaOnboardings[version] {
			if !finishedDeltaOnboardingVersion.contains(id) {
				finishedDeltaOnboardingVersion.append(id)
				store.finishedDeltaOnboardings[version] = finishedDeltaOnboardingVersion
				Log.debug("Another DeltaOnboarding finished for Version \(version): \(id)")
			}
		} else {
			store.finishedDeltaOnboardings[version] = [id]
			Log.debug("First finished DeltaOnboarding for Version \(version): \(id)")
		}
	}
}
