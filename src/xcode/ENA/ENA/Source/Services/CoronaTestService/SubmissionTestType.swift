//
// 🦠 Corona-Warn-App
//

import Foundation

enum SubmissionTestType: Equatable {
	case registeredTest(CoronaTestType?)
	case srs(SRSSubmissionType)
}

// Wrapping SAP_Internal_SubmissionPayload.SubmissionType with SRSSubmissionType
// as it does not conform to protocol equatable
enum SRSSubmissionType: Equatable, Codable {
	case srsSelfTest
	case srsRegisteredRat
	case srsUnregisterdRat
	case srsRegisteredPcr
	case srsUnregisteredPcr
	case srsRapidPcr
	case srsOther
	
	var protobufType: SAP_Internal_SubmissionPayload.SubmissionType {
		switch self {
		case .srsSelfTest:
			return .srsSelfTest
		case .srsRegisteredRat:
			return .srsRegisteredRat
		case .srsUnregisterdRat:
			return .srsUnregisteredRat
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
	
	var keySubmissionProtobuf: SAP_Internal_Ppdd_PPAKeySubmissionType {
		switch self {
		case .srsSelfTest:
			return .submissionTypeSrsSelfTest
		case .srsRegisteredRat:
			return .submissionTypeSrsRegisteredRat
		case .srsUnregisterdRat:
			return .submissionTypeSrsUnregisteredRat
		case .srsRegisteredPcr:
			return .submissionTypeSrsRegisteredPcr
		case .srsUnregisteredPcr:
			return .submissionTypeSrsUnregisteredPcr
		case .srsRapidPcr:
			return .submissionTypeSrsRapidPcr
		case .srsOther:
			return .submissionTypeSrsOther
		}
	}
}
