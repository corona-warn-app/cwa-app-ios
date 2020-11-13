//
// 🦠 Corona-Warn-App
//

import Foundation

extension Bundle {

	var unwrappedBundleIdentifier: String {
		guard let identifier = bundleIdentifier else {
			let errorMessage = "Could no read bundle identifier."
			Log.error(errorMessage, log: .api)
			fatalError(errorMessage)
		}
		return identifier
	}
}
