//
// 🦠 Corona-Warn-App
//

import Foundation

enum SubmissionTestType: Equatable {
	case registeredTest(CoronaTestType?)
	case srs(SRSSubmissionType)
}

enum SRSSubmissionType: Equatable {
	case srsRegisteredRat
	case srsSelfTest
	case srsRegisteredPcr
	case srsUnregisteredPcr
	case srsRapidPcr
	case srsOther
	
	var protobufType: SAP_Internal_SubmissionPayload.SubmissionType {
		switch self {
		case .srsRegisteredRat:
			return .srsRegisteredRat
		case .srsSelfTest:
			return .srsSelfTest
		case .srsRegisteredPcr:
			return .srsRegisteredPcr
		case .srsUnregisteredPcr:
			return .srsUnregisteredPcr
		case .srsRapidPcr:
			return .srsRapidPcr
		case .srsOther:
			return .srsOther
		}
	}
}
