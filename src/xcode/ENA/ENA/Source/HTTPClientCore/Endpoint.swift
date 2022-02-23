//
// 🦠 Corona-Warn-App
//

import Foundation
/**
Wraps the different endpoints for the different resources
*/

enum Endpoint: Equatable, CustomStringConvertible {
	case distribution
	case submission
	case verification
	case dataDonation
	case errorLogSubmission
	case dcc
	case dynamic(URL)

	// MARK: - CustomStringConvertible
	var description: String {
		switch self {
		case .distribution:
			return "distribution"
		case .submission:
			return "submission"
		case .verification:
			return "verification"
		case .dataDonation:
			return "dataDonation"
		case .errorLogSubmission:
			return "errorLogSubmission"
		case .dcc:
			return "dcc"
		case let .dynamic(url):
			return "dynamic" + url.absoluteString
		}
	}

	// MARK: - Internal

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
		case .dynamic(let url):
			return url
		}
	}
}
