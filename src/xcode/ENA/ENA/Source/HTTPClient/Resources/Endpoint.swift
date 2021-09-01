//
// 🦠 Corona-Warn-App
//

import Foundation

enum Endpoint {
	case distribution
	case submission
	case verification
	case dataDonation
	case errorLogSubmission
	case dcc

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
		}
	}

}
