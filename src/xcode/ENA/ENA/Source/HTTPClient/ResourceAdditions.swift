//
// 🦠 Corona-Warn-App
//

import Foundation

struct ResourceLocator {

	let endpoint: Endpoint
	let paths: [String]
	let method: HTTP.Method
	let headers: [String: String]

	
	static func appConfiguration(eTag: String? = nil) -> ResourceLocator {
		if let eTag = eTag {
			return ResourceLocator(
				endpoint: .distribution,
				paths: ["version", "v2", "app_config_ios"],
				method: .get,
				headers: ["If-None-Match": eTag]
			)
		} else {
			return ResourceLocator(
				endpoint: .distribution,
				paths: ["version", "v2", "app_config_ios"],
				method: .get,
				headers: [:]
			)
		}
	}

}

enum Endpoint {
	case distribution
	case submission
	case verification
	case dataDonation
	case errorLogSubmission
	case dcc
}
