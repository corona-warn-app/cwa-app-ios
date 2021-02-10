//
// 🦠 Corona-Warn-App
//

import Foundation

enum AgeGroup: Int, Codable {

	case ageBelow29 = 1
	case ageBetween30And59 = 2
	case age60OrAbove = 3

	// MARK: - Init

	init(from ageGroup: AgeGroup) {
		switch ageGroup {
		case .ageBelow29:
			self = .ageBelow29
		case .ageBetween30And59:
			self = .ageBetween30And59
		case .age60OrAbove:
			self = .age60OrAbove
		}
	}

	var protobuf: SAP_Internal_Ppdd_PPAAgeGroup {
		switch self {
		case .ageBelow29:
			return .ageGroup0To29
		case .ageBetween30And59:
			return .ageGroup30To59
		case .age60OrAbove:
			return .ageGroupFrom60
		}
	}

}
