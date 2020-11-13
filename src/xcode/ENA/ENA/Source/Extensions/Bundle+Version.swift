//
// 🦠 Corona-Warn-App
//

import Foundation

extension Bundle {

	var appVersion: String {
		guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
			fatalError("Could not read CFBundleShortVersionString from Bundle.")
		}
		return version
	}

	var appBuildNumber: String {
		guard let buildNumber = infoDictionary?[kCFBundleVersionKey as String] as? String else {
			fatalError("Could not read CFBundleVersion from Bundle.")
		}
		return buildNumber
	}
}
