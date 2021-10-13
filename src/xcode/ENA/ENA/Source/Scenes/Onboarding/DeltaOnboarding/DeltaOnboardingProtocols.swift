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
		Log.debug("Check, if \(id) is already finished or not needed (current onboarding version = \(store.onboardingVersion)...", log: .onboarding)
		let presented = store.finishedDeltaOnboardings[version] != nil && (store.finishedDeltaOnboardings[version]?.contains(id)) == true
		
		Log.debug("DeltaOnboarding \(id) already presented? \(presented).", log: .onboarding)
		if !store.onboardingVersion.numericGreaterOrEqual(then: version) && !presented {
			Log.debug("Will return isFinished() = false", log: .onboarding)
			return false
		}
		Log.debug("Will return isFinished() = true", log: .onboarding)
		return true
	}
	
	/// The `id` is a identifier generated out of the version of the concrete delta onboarding implementation and the corresponding class name
	/// This ensures that we
	/// a) can have multiple delta onboardings for the same version
	/// b) can reuse existing protocol implementation (e. g. new features) by just changing the version.
	var id: String {
		return version + String(describing: self)
	}
	
	func finish() {
		Log.debug("DeltaOnboarding finished...", log: .onboarding)

		if var finishedDeltaOnboardingVersion = store.finishedDeltaOnboardings[version] {
			if !finishedDeltaOnboardingVersion.contains(id) {
				finishedDeltaOnboardingVersion.append(id)
				store.finishedDeltaOnboardings[version] = finishedDeltaOnboardingVersion
				Log.debug("Another DeltaOnboarding finished for Version \(version): \(id)", log: .onboarding)
			}
		} else {
			store.finishedDeltaOnboardings[version] = [id]
			Log.debug("First finished DeltaOnboarding for Version \(version): \(id)", log: .onboarding)
		}
	}
}
