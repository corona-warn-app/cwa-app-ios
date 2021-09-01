//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

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

	func urlRequest(environmentData: EnvironmentData) -> URLRequest {
		let endpointURL = endpoint.url(environmentData)
		let url = paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		return URLRequest(url: url)
	}
}

enum Endpoint {
	case distribution
	case submission
	case verification
	case dataDonation
	case errorLogSubmission
	case dcc

	func url(_ environmentData: EnvironmentData) -> URL {
		switch self {
		case .distribution:
			return environmentData.distributionURL
		case .submission:
			return environmentData.submissionURL
		case .verification:
			return environmentData.verificationURL
		case .errorLogSubmission:
			return environmentData.errorLogSubmissionURL
		case .dcc:
			return environmentData.dccURL
		case .dataDonation:
			return environmentData.dataDonationURL
		}
	}

}
